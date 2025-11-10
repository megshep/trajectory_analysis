% 1. Add SPM to the path
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','fmri');
spm_jobman('initcfg');

% 2. Get SLURM array index
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% 3. Find all rc1 and rc2 images
base_dir = '/scratch/j90161ms/';

% -- rc1 files (exclude rc1_avg*) --
rc1_all = dir(fullfile(base_dir, 'rc1_*.nii'));
rc1_all = rc1_all(~startsWith({rc1_all.name}, 'rc1_avg'));
rc1_files = sort(fullfile({rc1_all.folder}, {rc1_all.name}));

% -- rc2 files (exclude rc2_avg*) --
rc2_all = dir(fullfile(base_dir, 'rc2_*.nii'));
rc2_all = rc2_all(~startsWith({rc2_all.name}, 'rc2_avg'));
rc2_files = sort(fullfile({rc2_all.folder}, {rc2_all.name}));

% 4. Select images for this SLURM job
this_rc1 = rc1_files{SUB_ID};
this_rc2 = rc2_files{SUB_ID};

fprintf('Processing GM: %s\n', this_rc1);
fprintf('Processing WM: %s\n', this_rc2);

% 5. Set up the geodesic shooting batch
matlabbatch{1}.spm.tools.shoot.warp.images = {{
    [this_rc1 ',1']
    [this_rc2 ',1']
}};

% 6. Run the SPM job
spm_jobman('run', matlabbatch);

fprintf('Completed shooting for array index %d\n', SUB_ID);
