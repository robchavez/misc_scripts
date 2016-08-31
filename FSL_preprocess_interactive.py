#!/usr/bin/env python
# Author: Rob Chavez (chavez.95@osu.edu)

"""Master interactive script for running preprocessing for DTI, fieldmap, and anatomical data.
This script will be most useful for use with FSL, though not exclusively."""

import os
import shutil
import numpy as np


# Enter subject IDs.
in_subs = raw_input('Enter subject IDs separated by commas (no spaces): ')
subs = in_subs.split(',')

# Enter study root directory.
studydir = raw_input('Enter study root directory: ')

# Loop through each subject's fieldmap data and process.
"""Performs fieldmap calculations for use with FSL (may or may not be compatible with SPM) """
for subID in subs:
    
    print 'Running fieldmap preprocessing on ' + subID
    
    # Assign input and output directories.
    indir = studydir + '/raw/' + subID
    outdir = studydir + '/prep/dti/' + subID + '/fieldmap'
    if os.path.isdir(outdir) == False:
        os.makedirs(outdir)
    
    # Copy fieldmap files for processing.
    shutil.copy(indir + '/epi_fieldmap.nii.gz' , outdir + '/epi_fieldmap.nii.gz')
    shutil.copy(indir + '/epi_fieldmap_phase.nii.gz' , outdir + '/epi_fieldmap_phase.nii.gz')
    os.chdir(outdir)
    
    # Run brain extraction and mask.
    os.system('standard_space_roi epi_fieldmap.nii.gz fmap_ssroi -b')
    os.system('bet2 fmap_ssroi.nii.gz epi_fieldmap_brain -f .3 -m')
    os.system('fslmaths epi_fieldmap.nii.gz -mas epi_fieldmap_brain_mask.nii.gz epi_fieldmap_brain')
    
    # Calculate fieldmap.
    os.system('fsl_prepare_fieldmap SIEMENS epi_fieldmap_phase.nii.gz \
    epi_fieldmap_brain.nii.gz fmap_rads 2.46')


# Loop through each subject's anatomical data and process.
"""Performs preprocessing steps for anatomical (MPRAGE) data for use with
various tools in FSL. """

for subID in subs:
    
    print 'Running anatomical BET on ' + subID
    
    # Assign input and output directories.
    indir = studydir + '/raw/' + subID
    outdir = studydir + '/prep/dti/' + subID + '/anat'
    if os.path.isdir(outdir) == False:
        os.makedirs(outdir)
    
    # Copy raw diffusion files for processing.
    shutil.copy(indir + '/anat.nii.gz' , outdir + '/anat.nii.gz')
    os.chdir(outdir)
    
    # Run brain extraction (i.e. skull strip) and save mask.
    os.system('bet2 anat.nii.gz anat_brain -f .25 -m')
    
    # Run FLIRT to 2mm and 3mm MNI brains
    print 'Running FLIRT on ' + subID

    os.system('flirt -ref /lab/neurodata/rsc/templates/MNI152_T1_2mm_brain.nii.gz \
    -in anat_brain.nii.gz -o flirt_anat_2_MNI2mm -omat flirt_anat_2_MNI2mm.mat')
    
    os.system('flirt -ref /lab/neurodata/rsc/templates/MNI152_T1_3mm_brain.nii.gz \
    -in anat_brain.nii.gz -o flirt_anat_2_MNI3mm -omat flirt_anat_2_MNI3mm.mat')
    
    
    # Run FNIRT to 2mm MNI brains
    print 'Running 2mm FNIRT on ' + subID
    os.system('fnirt --in=anat.nii.gz \
    --aff=flirt_anat_2_MNI2mm.mat \
    --cout=anat_2_MNI2mm_warp \
    --iout=anat_2_MNI2mm \
    --jout=anat_2_MNI2mm_jac \
    --config=T1_2_MNI152_2mm \
    --ref=/lab/neurodata/rsc/templates/MNI152_T1_2mm.nii.gz \
    --refmask=/lab/neurodata/rsc/templates/MNI152_T1_2mm_brain_mask_dil.nii.gz \
    --warpres=10,10,10')
    
    os.system('applywarp -i anat_brain.nii.gz -o fnirt_anat_2_MNI2mm_brain \
    -r /lab/neurodata/rsc/templates/MNI152_T1_2mm_brain.nii.gz \
    -w anat_2_MNI2mm_warp.nii.gz')
    
    os.system('invwarp -w anat_2_MNI2mm_warp.nii.gz -o anat_2_MNI2mm_warp_inv -r anat.nii.gz')
    
    # Run FNIRT to 3mm MNI brain
    print 'Running 3mm FNIRT on ' + subID
    os.system('fnirt --in=anat.nii.gz \
    --aff=flirt_anat_2_MNI3mm.mat \
    --cout=anat_2_MNI3mm_warp \
    --iout=anat_2_MNI3mm \
    --jout=anat_2_MNI3mm_jac \
    --config=/lab/neurodata/rsc/templates/T1_2_MNI152_3mm \
    --ref=/lab/neurodata/rsc/templates/MNI152_T1_3mm.nii.gz \
    --refmask=/lab/neurodata/rsc/templates/MNI152_T1_3mm_brain_mask_dil.nii.gz \
    --warpres=10,10,10')
    
    os.system('applywarp -i anat_brain.nii.gz -o fnirt_anat_2_MNI3mm_brain \
    -r /lab/neurodata/rsc/templates/MNI152_T1_3mm_brain.nii.gz \
    -w anat_2_MNI3mm_warp.nii.gz')
    
    os.system('invwarp -w anat_2_MNI3mm_warp.nii.gz -o anat_2_MNI3mm_warp_inv -r anat.nii.gz')


# Loop through each subject's DTI data and process
"""Performs preprocessing steps on dMRI data from the Ohio State University CCBBI. 
The current version is suited for the a 64 direction scan with one b0 image.
Runs eddy current and motion correction, brain extraction, tensor fits, 
and betpostx (for later use with probtrackx).This script will also save information 
about each subject's motion and write a PNG plot for later inspection."""

for subID in subs:
    
    print 'Running %s' % (subID)
    
    # Assign input and output directories
    indir = studydir + '/raw/' + subID
    outdir = studydir + '/prep/dti/' + subID
    if os.path.isdir(outdir) == False:
        os.makedirs(outdir)
    
    # Copy raw diffusion files for processing
    shutil.copy(indir + '/dti.nii.gz', outdir + '/raw_dwi.nii.gz')
    shutil.copy(indir + '/dti.bvec', outdir + '/bvecs')
    shutil.copy(indir + '/dti.bval', outdir + '/bvals')
    os.chdir(outdir)
    
    """The BET command below should be run on the B0 diffusion volume. 
    The -m options creates a binary mask used later.eddy_correct corrects for 
    motion and eddy current distortions. Makes the reference number a b0 volume 
    (in this case volume 0)."""
    
    # Extract b0 image and brain extract (i.e. skull strip) and save mask
    os.system('fslroi raw_dwi.nii.gz b0 0 1')
    os.system('bet %s/b0.nii.gz %s/nodif_brain.nii.gz -f .1 -m' % (outdir, outdir))
    
    # Create motion directory and run eddy current/motion correction
    motiondir = outdir + '/motion'
    os.makedirs(motiondir)
    
    os.system('/lab/neurodata/psynet/scripts/dti/eddy_correct_motion \
    %s/raw_dwi.nii.gz %s/motioncheck 0' % (outdir, motiondir))
    
    shutil.move(motiondir + '/motioncheck.nii.gz', outdir +'/data.nii.gz')
    
    # Compute RMS differences for each consecutive pairs of diffusion weighted volumes 
    for i in range(1,65):
        if i < 9:
            temp1 = 'motioncheck_tmp000%s' % (i)
            temp1_plus1 = i+1
            temp2 = 'motioncheck_tmp000%s' % (temp1_plus1)
        
            os.system('rmsdiff %s/%s \
            %s/%s %s/b0.nii.gz >> \
            %s/rms_motion.txt' % (motiondir, temp1, motiondir, temp2, outdir, motiondir))
    
        elif i == 9:
            os.system('rmsdiff %s/motioncheck_tmp0009 \
            %s/motioncheck_tmp0010 %s/b0.nii.gz >> \
            %s/rms_motion.txt' % (motiondir, motiondir, outdir, motiondir))   
        
        elif i > 9:
            temp1 = 'motioncheck_tmp00%s' % (i)
            temp1_plus1 = i+1
            temp2 = 'motioncheck_tmp00%s' % (temp1_plus1)
        
            os.system('rmsdiff %s/%s \
            %s/%s %s/b0.nii.gz >> \
            %s/rms_motion.txt' % (motiondir, temp1, motiondir, temp2, outdir, motiondir))
    
    rms_txt = motiondir + '/rms_motion.txt'
    rms_vals = np.loadtxt(rms_txt, dtype = float)
    mean_rms = np.mean(rms_vals)
    mean_rms.tofile(file='%s/mean_rms.txt'%(motiondir),format='%.6f',sep=';')
    
    # Create motion plot
    shutil.copy(motiondir + '/rms_motion.txt', motiondir + '/rms_motion.rms')
    
    os.system("fsl_tsplot -i %s/rms_motion.rms  \
    -t 'eddy_correct FLIRT estimated mean displacement (mm)' \
    -u 1 -w 640 -h 144 -a relative -o %s/motion_plot.png" % (motiondir, motiondir))
    
    # Run FSL's dtifit to calculate tensors
    os.system("dtifit -k %s/data.nii.gz -o %s/rdti \
    -m %s/nodif_brain_mask.nii.gz -r %s/bvecs \
    -b %s/bvals" % (outdir,outdir,outdir,outdir,outdir))
    
    # Create RD image
    os.system("fslmaths %s/rdti_L2.nii.gz -add %s/rdti_L3.nii.gz \
    -div 2 %s/rdit_RD" % (outdir,outdir,outdir))          

    # Run bedpostx
    print "Running bedpostx on %s" % (subID)
    os.system("bedpostx %s" % (outdir))


