%% Initialise SPM
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm');
spm('defaults','FMRI');
spm_jobman('initcfg');

%% 
% The rc1 and rc2 files are saved in a different folder to ensure that they're kept separately from the rc1avg and rc2avg files from a previous analysis
rc1_dir = '/scratch/j90161ms/rc1_clean';
rc2_dir = '/scratch/j90161ms/rc2_clean';

%% That being said, better safe than sorry, I've included this section to ensure we're only using rc1 and rc2 files and not accidentally including avg files.
% Collect rc1 (GM), exclude avg
rc1_struct = dir(fullfile(rc1_dir,'rc1*.nii'));
rc1_struct = rc1_struct(~contains(lower({rc1_struct.name}),'avg'));
rc1 = fullfile({rc1_struct.folder},{rc1_struct.name});

% Collect rc2 (WM), exclude avg
rc2_struct = dir(fullfile(rc2_dir,'rc2*.nii'));
rc2_struct = rc2_struct(~contains(lower({rc2_struct.name}),'avg'));
rc2 = fullfile({rc2_struct.folder},{rc2_struct.name});

% Sort to ensure subject alignment as they need to be in the correct order for Dartel templates to be made. 
rc1 = sort(rc1);
rc2 = sort(rc2);

% Sanity checks  - these are built in to ensure the files are in the correct place (I've had this problem so many times lol)
if isempty(rc1) || isempty(rc2)
    error('No rc1 or rc2 files found — check directories');
end

if numel(rc1) ~= numel(rc2)
    error('rc1 (%d) and rc2 (%d) counts do not match', numel(rc1), numel(rc2));
end

fprintf('Found %d subjects\n', numel(rc1));

% Add volume index (SPM requirement to set up the files appropriately to make the templates)
rc1 = strcat(rc1, ',1');
rc2 = strcat(rc2, ',1');

% Column vectors - required to be in this format to be analysed
rc1 = rc1(:);
rc2 = rc2(:);

%% 
% DARTEL batch as designed in the GUI
matlabbatch = [];

matlabbatch{1}.spm.tools.dartel.warp.images = {
    rc1
    rc2
};

matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;

% Standard SPM parameters
params = [
    3 4   2    1e-6 0 16
    3 2   1    1e-6 0 8
    3 1   0.5  1e-6 1 4
    3 0.5 0.25 1e-6 2 2
    3 0.25 0.125 1e-6 4 1
    3 0.25 0.125 1e-6 6 0.5
];

for i = 1:6
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(i).its    = params(i,1);
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(i).rparam = params(i,2:4);
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(i).K      = params(i,5);
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(i).slam   = params(i,6);
end

matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc   = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its   = 3;

%% run the job and display a message to tell me this was successful
disp('Starting DARTEL template creation...');
spm_jobman('run', matlabbatch);
