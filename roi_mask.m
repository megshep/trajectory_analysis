%defines the path of where spm is located on the CSF
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25');  
spm('defaults','FMRI');
spm_jobman('initcfg');

%set working directory
base_dir = '/scratch/j90161ms/final_sample';

%reads in the csv with the IDs 
T = readtable(fullfile(base_dir,'final_dataset.csv'),'TextType','string');
N = height(T);

%required to initialise the job array (HPC to send as individual jobs to
%parallelise)
i = str2double(getenv('SLURM_ARRAY_TASK_ID'));

%sanity check - make sure IDs match number of scans available
if i > N
    error('Job index exceeds number of subjects');
end

fprintf('Processing subject %d of %d\n', i, N);

%this reads in the IDs as a string rather than as a number
%this is needed as the IDs are automatically loaded in as scientific
%notation and so the filenames won't be read approprialtely without this
id_num = T.ID(i);
id = sprintf('%.0f', id_num);


% INPUTS (3 images per subject) -- these are change maps comparing the
% timepoints
img1 = fullfile(base_dir, ['change' id 'FU3minusFU2.nii']);
img2 = fullfile(base_dir, ['change' id 'FU3minusBL.nii']);
img3 = fullfile(base_dir, ['change' id 'FU2minusBL.nii']);


% AMYGDALA MASK (same for all)
amy_mask = fullfile(base_dir, 'bilateral_amygdala.nii');
left_amy_mask = fullfile(base_dir, 'left_amy_bin.nii');
right_amy_mask = fullfile(base_dir, 'right_amy_bin.nii');

%
% OUTPUTS - define output names
out1 = fullfile(base_dir, ['amy_FU3minusFU2_' id '.nii']);
out2 = fullfile(base_dir, ['amy_FU3minusBL_' id '.nii']);
out3 = fullfile(base_dir, ['amy_FU2minusBL_' id '.nii']);
out4 = fullfile(base_dir, ['left_amy_FU3minusFU2_' id '.nii']);
out5 = fullfile(base_dir, ['left_amy_FU3minusBL_' id '.nii']);
out6 = fullfile(base_dir, ['left_amy_FU2minusBL_' id '.nii']);
out7 = fullfile(base_dir, ['right_amy_FU3minusFU2_' id '.nii']);
out8 = fullfile(base_dir, ['right_amy_FU3minusBL_' id '.nii']);
out9 = fullfile(base_dir, ['right_amy_FU2minusBL_' id '.nii']);

% Batch scripts now to mask the amygdala 
% 1) FU3 - FU2 (bilateral)
matlabbatch{1}.spm.util.imcalc.input = {img1, amy_mask};
matlabbatch{1}.spm.util.imcalc.output = out1;
matlabbatch{1}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

% 2) FU3 - BL (bilateral)
matlabbatch{2}.spm.util.imcalc.input = {img2, amy_mask};
matlabbatch{2}.spm.util.imcalc.output = out2;
matlabbatch{2}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{2}.spm.util.imcalc.options.mask = 0;
matlabbatch{2}.spm.util.imcalc.options.interp = 1;
matlabbatch{2}.spm.util.imcalc.options.dtype = 16;

% 3) FU2 - BL (bilateral)
matlabbatch{3}.spm.util.imcalc.input = {img3, amy_mask};
matlabbatch{3}.spm.util.imcalc.output = out3;
matlabbatch{3}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{3}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{3}.spm.util.imcalc.options.mask = 0;
matlabbatch{3}.spm.util.imcalc.options.interp = 1;
matlabbatch{3}.spm.util.imcalc.options.dtype = 16;

% 4) FU3 - FU2 (left)
matlabbatch{4}.spm.util.imcalc.input = {img1, left_amy_mask};
matlabbatch{4}.spm.util.imcalc.output = out4;
matlabbatch{4}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{4}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{4}.spm.util.imcalc.options.mask = 0;
matlabbatch{4}.spm.util.imcalc.options.interp = 1;
matlabbatch{4}.spm.util.imcalc.options.dtype = 16;

% 5) FU3 - BL (left)
matlabbatch{5}.spm.util.imcalc.input = {img2, left_amy_mask};
matlabbatch{5}.spm.util.imcalc.output = out5;
matlabbatch{5}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{5}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{5}.spm.util.imcalc.options.mask = 0;
matlabbatch{5}.spm.util.imcalc.options.interp = 1;
matlabbatch{5}.spm.util.imcalc.options.dtype = 16;

% 6) FU2 - BL (left)
matlabbatch{6}.spm.util.imcalc.input = {img3, left_amy_mask};
matlabbatch{6}.spm.util.imcalc.output = out6;
matlabbatch{6}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{6}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{6}.spm.util.imcalc.options.mask = 0;
matlabbatch{6}.spm.util.imcalc.options.interp = 1;
matlabbatch{6}.spm.util.imcalc.options.dtype = 16;

% 7) FU3 - FU2 (right)
matlabbatch{7}.spm.util.imcalc.input = {img1, right_amy_mask};
matlabbatch{7}.spm.util.imcalc.output = out7;
matlabbatch{7}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{7}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{7}.spm.util.imcalc.options.mask = 0;
matlabbatch{7}.spm.util.imcalc.options.interp = 1;
matlabbatch{7}.spm.util.imcalc.options.dtype = 16;

% 8) FU3 - BL (right)
matlabbatch{8}.spm.util.imcalc.input = {img2, right_amy_mask};
matlabbatch{8}.spm.util.imcalc.output = out8;
matlabbatch{8}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{8}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{8}.spm.util.imcalc.options.mask = 0;
matlabbatch{8}.spm.util.imcalc.options.interp = 1;
matlabbatch{8}.spm.util.imcalc.options.dtype = 16;

% 9) FU2 - BL (right)
matlabbatch{9}.spm.util.imcalc.input = {img3, right_amy_mask};
matlabbatch{9}.spm.util.imcalc.output = out9;
matlabbatch{9}.spm.util.imcalc.expression = 'i1 .* (i2 > 0)';

matlabbatch{9}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{9}.spm.util.imcalc.options.mask = 0;
matlabbatch{9}.spm.util.imcalc.options.interp = 1;
matlabbatch{9}.spm.util.imcalc.options.dtype = 16;


% RUN
spm_jobman('run', matlabbatch);
