% ImCalc - change images being created for all timepoints 

addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25');  
spm('defaults','FMRI');
spm_jobman('initcfg');

base_dir = '/scratch/j90161ms/final_sample';

% Load the excel sheet that has the list of IDs in 
T = readtable(fullfile(base_dir,'final_demographics_traj.csv'));
N = height(T);

% this is the slurm job arrays as this was conducted on the HPC/CSF 
i = str2double(getenv('SLURM_ARRAY_TASK_ID'));

%built in sanity check to ensure that the scans meet the number of subject
%IDs
if i > N
    error('Job index exceeds number of subjects');
end

fprintf('Processing subject %d of %d\n', i, N);

% this extracts one subject from the table
id = T.ID{i};

%this defines the BL,FU2/3 images for individual participants 
bl_img  = fullfile(base_dir, ['smwrc' id '.nii']);
fu2_img = fullfile(base_dir, ['smwrc' id '_FU2.nii']);
fu3_img = fullfile(base_dir, ['smwrc' id '_FU3.nii']);


% BL vs FU2 (voxelwise subtraction) - this was created in the GUI with the
% default settings
matlabbatch{1}.spm.util.imcalc.input = {bl_img; fu2_img};
matlabbatch{1}.spm.util.imcalc.output = fullfile(base_dir, ['change_' id '_FU2minusBL.nii']);
matlabbatch{1}.spm.util.imcalc.expression = 'i2 - i1';
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

spm_jobman('run', matlabbatch);

% BL vs FU3 (voxelwise subtraction)
clear matlabbatch
matlabbatch{1}.spm.util.imcalc.input = {bl_img; fu3_img};
matlabbatch{1}.spm.util.imcalc.output = fullfile(base_dir, ['change_' id '_FU3minusBL.nii']);
matlabbatch{1}.spm.util.imcalc.expression = 'i2 - i1';
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

spm_jobman('run', matlabbatch);

% FU2 vs FU3 (voxelwise subtraction)
clear matlabbatch
matlabbatch{1}.spm.util.imcalc.input = {fu2_img; fu3_img};
matlabbatch{1}.spm.util.imcalc.output = fullfile(base_dir, ['change_' id '_FU3minusFU2.nii']);
matlabbatch{1}.spm.util.imcalc.expression = 'i2 - i1';
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

spm_jobman('run', matlabbatch);
