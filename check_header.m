
% NIfTI integrity checker for DARTEL inputs - some files are corrupted, need to identify which ones
% READ-ONLY: does NOT modify files (does not delete, simply tells me which are OK and which are corrupted)

addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','fmri');

% This is a separate folder so that only rc1 and rc2 are in here, a necessary step as I also have avg templates made for a cross-sectional VBM. If you don't have these, then base_dir could just be scratch.
base_dir = '/net/scratch/j90161ms/dartel_run';

rc1_files = dir(fullfile(base_dir,'rc1*.nii'));
rc2_files = dir(fullfile(base_dir,'rc2*.nii'));

fprintf('Checking %d rc1 files and %d rc2 files...\n', ...
        numel(rc1_files), numel(rc2_files));

% create output files to tell me which are ok and which are corrupted rc1 and rc2 files at the end
good_rc1 = fopen('good_rc1.txt','w');
bad_rc1  = fopen('bad_rc1.txt','w');
good_rc2 = fopen('good_rc2.txt','w');
bad_rc2  = fopen('bad_rc2.txt','w');

%% a loop to cycle through the rc1 files to check their header info to find out which are corrupted/too small to include in creating dartel templates
for i = 1:numel(rc1_files)
    fname = fullfile(rc1_files(i).folder, rc1_files(i).name);
    try
        V = spm_vol(fname);
        spm_slice_vol(V, spm_matrix([0 0 1]), V.dim(1:2), 0);
        fprintf(good_rc1,'%s\n', rc1_files(i).name);
    catch
        fprintf(bad_rc1,'%s\n', rc1_files(i).name);
    end
end

%% a loop to cycle through the rc2 files to check their header info to find out which are corrupted/too small to include in creating dartel templates
for i = 1:numel(rc2_files)
    fname = fullfile(rc2_files(i).folder, rc2_files(i).name);
    try
        V = spm_vol(fname);
        spm_slice_vol(V, spm_matrix([0 0 1]), V.dim(1:2), 0);
        fprintf(good_rc2,'%s\n', rc2_files(i).name);
    catch
        fprintf(bad_rc2,'%s\n', rc2_files(i).name);
    end
end

fclose('all');

% A message to tell me it's finished and produced!
disp('Finished integrity check.');
disp('Outputs: good_rc1.txt, bad_rc1.txt, good_rc2.txt, bad_rc2.txt');
