% Add SPM to the path
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','fmri');
spm_jobman('initcfg');

% Get SLURM array index - this is specific for the fact I'm running this in job arrays on the CSF
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% define the directory
base_dir = '/scratch/j90161ms/';

% Load list of valid subject IDs from the .txt file that I have already generated
fid = fopen(fullfile(base_dir, 'valid_subject_IDs.txt'));
valid_subjects = textscan(fid, '%s');
fclose(fid);
valid_subjects = valid_subjects{1};

% Pick the current subject ID
this_id = valid_subjects{SUB_ID};

% Define rc1 and rc2 file paths
this_rc1 = fullfile(base_dir, ['rc1' this_id '.nii']);
this_rc2 = fullfile(base_dir, ['rc2' this_id '.nii']);

% Set up the batch and run SPM 
matlabbatch{1}.spm.tools.shoot.warp.images = {{
    [this_rc1 ',1']
    [this_rc2 ',1']
}};
spm_jobman('run', matlabbatch);

