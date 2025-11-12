%
% Normalise (affine registering to MNI 152 space) three rc1 images per participant (longitudinal design), using templates made during registration/geodesic shooting

% Get participant index from SLURM array
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% Define your scratch directory
scratchDir = '/scratch/j90161ms';

% Find all rc1 and y_rc1 files (exclude 'avg' - I have to do this because I've already preprocessed avg templates for each participant, if you haven't created this template, then you can skip this step)
rc1_files = dir(fullfile(scratchDir, 'rc1*.nii'));
yrc1_files = dir(fullfile(scratchDir, 'y_rc1*.nii'));

rc1_files = fullfile({rc1_files.folder}, {rc1_files.name});
yrc1_files = fullfile({yrc1_files.folder}, {yrc1_files.name});

rc1_files = rc1_files(~contains(rc1_files, 'avg'));
yrc1_files = yrc1_files(~contains(yrc1_files, 'avg'));

rc1_files = sort(rc1_files);
yrc1_files = sort(yrc1_files);


% Get scans for this participant (3 per participant) - this is important for the slurm arrays, the number of px must match the pre-made list of subject IDs, so it needs to process all 3 scans in one array
scans_per_sub = 3;
start_idx = (SUB_ID - 1) * scans_per_sub + 1;
end_idx = start_idx + scans_per_sub - 1;


% Build SPM batch
% use the template created during shooting to normalise to
matlabbatch{1}.spm.tools.shoot.norm.template = {fullfile(scratchDir, 'Template_4.nii')};
matlabbatch{1}.spm.tools.shoot.norm.data.subjs.deformations = yrc1_files(start_idx:end_idx);
matlabbatch{1}.spm.tools.shoot.norm.data.subjs.images = rc1_files(start_idx:end_idx);
% this follows Ashburner's recommendations for preprocessing, and I chose an 8mm kernel to match previous analyses
matlabbatch{1}.spm.tools.shoot.norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.shoot.norm.bb = [NaN NaN NaN; NaN NaN NaN];
matlabbatch{1}.spm.tools.shoot.norm.preserve = 1;
matlabbatch{1}.spm.tools.shoot.norm.fwhm = 8;


% Run the job
spm('defaults','FMRI');
spm_jobman('run', matlabbatch);
