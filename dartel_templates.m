%% Initiate  SPM
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','FMRI');
spm_jobman('initcfg');

% Base directory
base_dir = '/scratch/j90161ms';% identify the files that are rc1 and then remove  any files that contain avg (as I have previously created avg files and done a separate analysis, so can skip this if it does not apply)
rc1_struct = dir(fullfile(base_dir, 'rc1*.nii'));
rc1_files  = fullfile({rc1_struct.folder}, {rc1_struct.name});
rc1_files  = rc1_files(~contains(lower(rc1_files), 'avg'));

% identify rc2 files (WM) – exclude avg again
rc2_struct = dir(fullfile(base_dir, 'rc2*.nii'));
rc2_files  = fullfile({rc2_struct.folder}, {rc2_struct.name});
rc2_files  = rc2_files(~contains(lower(rc2_files), 'avg'));

% Sanity check to ensure that we have the same number of rc1 and rc2 files and introduce an error message to be produced if they do not correspond
if numel(rc1_files) ~= numel(rc2_files)
    error('Number of rc1 and rc2 files does not match!');
end

fprintf('Found %d rc1 and %d rc2 images\n', numel(rc1_files), numel(rc2_files));

% Convert to double precision (required for DARTEL)
disp('Converting rc1 images to double precision...');
for i = 1:numel(rc1_files)
    V = spm_vol(rc1_files{i});
    Y = spm_read_vols(V);
    V.dt = [spm_type('float64') spm_platform('bigend')];
    spm_write_vol(V, double(Y));
end

disp('Converting rc2 images to double precision...');
for i = 1:numel(rc2_files)
    V = spm_vol(rc2_files{i});
    Y = spm_read_vols(V);
    V.dt = [spm_type('float64') spm_platform('bigend')];
    spm_write_vol(V, double(Y));
end


% Add volume index, required for the  batch
rc1_files = cellfun(@(x) [x ',1'], rc1_files, 'UniformOutput', false);
rc2_files = cellfun(@(x) [x ',1'], rc2_files, 'UniformOutput', false);

% Column vectors (SPM requirement for the batch)
rc1_files = rc1_files(:);
rc2_files = rc2_files(:);

%% 
% DARTEL batch
matlabbatch = [];

matlabbatch{1}.spm.tools.dartel.warp.images = {
    rc1_files
    rc2_files
    };

matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
% Parameters (standard SPM defaults)
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;

matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;

matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;

matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;

matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;

matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;

matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc   = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its   = 3;

%% 
% Run batch
disp('Starting DARTEL template creation...');
spm_jobman('run', matlabbatch);
disp('DARTEL completed successfully.');


