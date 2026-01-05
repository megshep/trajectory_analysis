%% Setup SPM
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','FMRI');
spm_jobman('initcfg');

%% Folders
rc1_in  = '/scratch/j90161ms/rc1_clean';
rc2_in  = '/scratch/j90161ms/rc2_clean';
out_dir = '/scratch/j90161ms/dartel_run';
if ~exist(out_dir,'dir'); mkdir(out_dir); end

%% Get files
rc1_files = dir(fullfile(rc1_in,'rc1*.nii'));
rc1_files = rc1_files(~contains(lower({rc1_files.name}),'avg'));
rc1_files = fullfile({rc1_files.folder},{rc1_files.name});

rc2_files = dir(fullfile(rc2_in,'rc2*.nii'));
rc2_files = rc2_files(~contains(lower({rc2_files.name}),'avg'));
rc2_files = fullfile({rc2_files.folder},{rc2_files.name});

%% Convert to double precision
for i = 1:numel(rc1_files)
    V = spm_vol(rc1_files{i});
    Y = spm_read_vols(V);
    [~,name,ext] = fileparts(rc1_files{i});
    V.fname = fullfile(out_dir,[name '_dbl' ext]);
    V.dt = [spm_type('float64') spm_platform('bigend')];
    if isfield(V,'private'); V = rmfield(V,'private'); end
    V = spm_create_vol(V);
    spm_write_vol(V,double(Y));
end

for i = 1:numel(rc2_files)
    V = spm_vol(rc2_files{i});
    Y = spm_read_vols(V);
    [~,name,ext] = fileparts(rc2_files{i});
    V.fname = fullfile(out_dir,[name '_dbl' ext]);
    V.dt = [spm_type('float64') spm_platform('bigend')];
    if isfield(V,'private'); V = rmfield(V,'private'); end
    V = spm_create_vol(V);
    spm_write_vol(V,double(Y));
end

disp('All rc1 and rc2 images converted to double precision in dartel_run.');

