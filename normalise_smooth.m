% Get subject index from SLURM array
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% Define your scratch directory
scratchDir = '/scratch/j90161ms';

% Find all rc1 and y_rc1 files
rc1_files = dir(fullfile(scratchDir, 'rc1*.nii'));
yrc1_files = dir(fullfile(scratchDir, 'y_rc1*.nii'));

% Convert to full file paths
rc1_files = fullfile({rc1_files.folder}, {rc1_files.name});
yrc1_files = fullfile({yrc1_files.folder}, {yrc1_files.name});

% Exclude any files that contain 'avg' in their name
rc1_files = rc1_files(~contains(rc1_files, 'avg'));
yrc1_files = yrc1_files(~contains(yrc1_files, 'avg'));

% Sort lists to maintain consistent order
rc1_files = sort(rc1_files);
yrc1_files = sort(yrc1_files);


% Build batch for the normalisation
matlabbatch{1}.spm.tools.shoot.norm.template = {fullfile(scratchDir, 'Template_4.nii')};

matlabbatch{1}.spm.tools.shoot.norm.data.subjs.deformations = {yrc1_files{SUB_ID}};
matlabbatch{1}.spm.tools.shoot.norm.data.subjs.images = {{rc1_files{SUB_ID}}};

matlabbatch{1}.spm.tools.shoot.norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.shoot.norm.bb = [NaN NaN NaN; NaN NaN NaN];
matlabbatch{1}.spm.tools.shoot.norm.preserve = 1;
matlabbatch{1}.spm.tools.shoot.norm.fwhm = 8;

% Run the job
spm('defaults','FMRI');
spm_jobman('run', matlabbatch);
