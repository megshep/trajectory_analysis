%load in SPM and initialise it
addpath('/mnt/iusers01/nm01/j90161ms/scratch/spm25');  
spm('defaults','FMRI');
spm_jobman('initcfg');

%get the subjectID for the Slurm array (this is only needed if using job arrays on an HPC)
%I've also included a sanity check - if there are issues with the array rather than the MATLAB code itself, it will produce an error message.
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));
if isnan(SUB_ID)
    error('SLURM_ARRAY_TASK_ID not found');
end

%setting the working directories
rc1_dir   = '/scratch/j90161ms/rc1_clean';        %all preprocessed images are here (post-dartel template creation)
flow_dir  = '/net/scratch/j90161ms/double_prec';  % flowfields + template are here
output_dir = '/scratch/j90161ms/dartel_norm_smoothed';  % output to be stored here

%create a loop to make a directory if it doesn't exist (so when I keep rerunning after errors, it doesn't keep making new directories)
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

%searches inside the directory to find any rc1 files (all 3 timepoints)
rc1_struct = dir(fullfile(rc1_dir,'rc1*.nii*'));
rc1_struct = rc1_struct(~contains(lower({rc1_struct.name}),'avg'));  % exclude avg files - these are produced from a previous analysis, so if you haven't done an additional crossectional VBM, this can be omitted
rc1_files  = fullfile({rc1_struct.folder},{rc1_struct.name}); %converts the structrual information from aboce into full file paths
rc1_files  = sort(rc1_files(:));  %alphabetically sorts the files to ensure that they're in the correct order

%again, another sanity check built in so I can identify where my code is failing if I get an error message
if isempty(rc1_files)
    error('No rc1 images found in %s', rc1_dir);
end

%Flow fields - each participant at each timepoint also has a flowfield associated, to normalise, we need their rc1 + flowfield information (map of how to deform a subject’s brain to match the template)
%
urc1_struct = dir(fullfile(flow_dir,'u_rc1d*_Template*.nii*'));
urc1_files  = fullfile({urc1_struct.folder},{urc1_struct.name});
urc1_files  = sort(urc1_files(:));

% This is another sanity check built in to let me know if the job fails because the directory doesn't store the files 
% I've built these in throughout because I'm using the CSF3 so I can't always manually check each folder before running due to the number and size of the files (it takes ages!)
if isempty(urc1_files)
    error('No flowfields found in %s', flow_dir);
end

%how many scans per subject
scans_per_sub = 3;
%how many scans come before the subject, plus one is the index of the first scan for the subject
start_idx = (SUB_ID - 1) * scans_per_sub + 1;
% This indexes the last scan for the subject, allowing for all 3 scans per subject to be selected
end_idx   = start_idx + scans_per_sub - 1;

% Built in sanity check -- ensures that scans and flowfields exist (if error, can work out it at this stage)
if end_idx > numel(rc1_files) || end_idx > numel(urc1_files)
    error('SUB_ID %d exceeds available scans', SUB_ID);
end


%this selects all files and the singular flowfields for each participant
sub_rc1  = rc1_files(start_idx:end_idx);
sub_flow = urc1_files(start_id;


% BATCH - this builds the actual batch script now we've set up the files to be input into the batch
matlabbatch = [];

%this defines the scans and flowfields into the batch
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).images    = sub_rc1(:);
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).flowfield = sub_flow(:);

% defines the DARTEL template 
matlabbatch{1}.spm.tools.dartel.mni_norm.template = ...
    {fullfile(flow_dir,'Template_6.nii')};

% Normalisation settings
%default voxel size
matlabbatch{1}.spm.tools.dartel.mni_norm.vox        = [NaN NaN NaN];
%default bounding box
matlabbatch{1}.spm.tools.dartel.mni_norm.bb         = [NaN NaN NaN; NaN NaN NaN];
% modulation is on (keeps volume information on the normalised images to reflect concentration)
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve   = 1;
%define smoothing kernel
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm       = [8 8 8];

%Run job
disp('Starting longitudinal DARTEL normalisation and smoothing...');
spm_jobman('run', matlabbatch);
disp('Finished normalisation and smoothing.');

%move outputs
w_files   = dir(fullfile(rc1_dir,'wrc1d*.nii*'));
smw_files = dir(fullfile(rc1_dir,'smwrc1d*.nii*'));

for f = [w_files; smw_files]'
    movefile(fullfile(f.folder,f.name), output_dir);
end

fprintf('All outputs for SUB_ID %d moved to %s\n', SUB_ID, output_dir);

