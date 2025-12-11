% Add SPM to the path
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','fmri');
spm_jobman('initcfg');

% load in the directory
base_dir = '/scratch/j90161ms/';

% List all rc1 niftis, excluding avg files (this is done because I did a cross-sectional VBM before the longitudinal)
rc1_files_struct = dir(fullfile(base_dir, 'rc1*.nii'));
rc1_files = fullfile({rc1_files_struct.folder}, {rc1_files_struct.name});
rc1_files = rc1_files(~contains(lower(rc1_files), 'avg')); % remove *_avg*

% sanity check to ensure that the rc1 files are in the directory
if isempty(rc1_files)
    error('No rc1 files found in %s', base_dir);
end

% Add ,1 indexing for SPM
rc1_paths = cellfun(@(x) [x ',1'], rc1_files, 'UniformOutput', false);

% Ensure column cell array (SPM expects n×1)
rc1_paths = rc1_paths(:);

% starting to build the SPM batch
matlabbatch = {};
matlabbatch{1}.spm.tools.shoot.warp.images = {rc1_paths};


% Run the shooting job
disp('Starting geodesic shooting on all subjects...');
spm_jobman('run', matlabbatch);
disp('Geodesic shooting completed successfully.');











