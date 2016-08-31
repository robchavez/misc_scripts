#!/usr/bin/env python
# Author: Rob Chavez (chavez.95@osu.edu)

"""Performs preprocessing steps on dMRI data for NKI Rockland data. 
Runs eddy current and motion correction, brain extraction, tensor fits, 
and betpostx (for later use with probtrackx).This script will also save information 
about each subject's motion and write a PNG plot for later inspection."""

import os
import shutil
import numpy as np
from joblib import Parallel, delayed
import multiprocessing

# Enter subject IDs.
subs = ['0103872','0105290','0105488','0105521','0106057','0106780','0108355','0109459','0109727','0109819','0111282','0112249','0112347','0112828','0113013','0113030','0114232','0115321','0115454','0115564']

# Loop through each subject's data and process
def dtiProcess(subID):
    
    print 'Running %s' % (subID)
    
    # Enter study root directory.
    studydir = '/lab/neurodata/nki_rockland/release1/'
    
    # Assign input and output directories
    indir = studydir + subID + '/session_1/DTI_mx_137'
    outdir = studydir + subID + '/session_1/DTI_mx_137'


    """The BET command below should be run on the B0 diffusion volume. 
    The -m options creates a binary mask used later.eddy_correct corrects for 
    motion and eddy current distortions. Makes the reference number a b0 volume 
    (in this case volume 0)."""
    
    # Extract b0 image and brain extract (i.e. skull strip) and save mask
    os.chdir(outdir)
    os.system('fslroi dti.nii.gz b0 0 1')
    os.system('bet %s/b0.nii.gz %s/nodif_brain.nii.gz -f .2 -m' % (outdir, outdir))
    
    # Create motion directory and run eddy current/motion correction
    motiondir = outdir + '/motion'
    os.makedirs(motiondir)
    
    os.system('/lab/neurodata/psynet/scripts/dti/eddy_correct_motion \
    %s/dti.nii.gz %s/motioncheck 49' % (outdir, motiondir))
    
    shutil.move(motiondir + '/motioncheck.nii.gz', outdir +'/data.nii.gz')
    
    # Compute RMS differences for each consecutive pairs of diffusion weighted volumes 
    for i in range(1,137):
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
    -m %s/nodif_brain_mask.nii.gz -r %s/dti.bvec \
    -b %s/dti.bval" % (outdir,outdir,outdir,outdir,outdir))
    
    # Create RD image
    os.system("fslmaths %s/rdti_L2.nii.gz -add %s/rdti_L3.nii.gz \
    -div 2 %s/rdit_RD" % (outdir,outdir,outdir))          

    # Run bedpostx
    print "Running bedpostx on %s" % (subID)
    os.system("bedpostx %s" % (outdir))

num_cores = 20

Parallel(n_jobs = num_cores)(delayed(dtiProcess)(subID) for subID in subs)
