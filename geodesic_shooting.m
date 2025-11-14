% Add SPM to the path
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','fmri');
spm_jobman('initcfg');

% Get SLURM array index
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% load in the directory
base_dir = '/scratch/j90161ms/';

% Load valid subject IDs from the .txt file that I have already made in a previous step
fid = fopen(fullfile(base_dir, 'valid_subject_IDs.txt'));
valid_subjects = textscan(fid, '%s');
fclose(fid);
valid_subjects = valid_subjects{1};

% create a variable to state this specific participant's subject ID to load into the code below
this_id = valid_subjects{SUB_ID};

% FIND rc1 FILES FOR THIS SUBJECT (all 3 timepoints), EXCLUDING _avg files <-- this can be skipped if you have not already created these previously
% 
rc1_pattern = fullfile(base_dir, ['rc1' this_id '*.nii']);
rc1_files = dir(rc1_pattern);

% Remove *_avg*
rc1_files = rc1_files(~contains({rc1_files.name}, 'avg'));

% Convert to full paths
rc1_paths = fullfile({rc1_files.folder}, {rc1_files.name});

% Add ,1 indexing for SPM
rc1_paths = cellfun(@(x) [x ',1'], rc1_paths, 'UniformOutput', false);

%
% Construct the batch
matlabbatch{1}.spm.tools.shoot.warp.images = {rc1_paths};

% run the job
spm_jobman('run', matlabbatch);

