%% Get SLURM job array index
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% Read all file paths from your existing .txt list
% Assumes one file path per line, BL, FU1, FU2 for each participant
fid = fopen('/scratch/j90161ms/all_files.txt','r');
all_files = textscan(fid, '%s');
fclose(fid);
all_files = all_files{1};  % convert nested cell

%%Each participant has 3 scans, compute indices
start_idx = (SUB_ID-1)*3 + 1;
end_idx   = start_idx + 2;

%%Select the three scans for this participant
this_files = all_files(start_idx:end_idx);

% Assign scans to SPM batch
matlabbatch{1}.spm.spatial.preproc.channel.vols = this_files;

% Batch options
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];

% Tissue probability maps (cluster-accessible paths)
tpm_path = '/scratch/j90161ms/spm25/spm/tpm/TPM.nii';
for i = 1:6
    matlabbatch{1}.spm.spatial.preproc.tissue(i).tpm = {[tpm_path ',' num2str(i)]};
end

matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1; matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1]; matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1; matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1]; matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2; matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0]; matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3; matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0]; matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4; matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0]; matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2; matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0]; matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

% Warp settings
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN; NaN NaN NaN];

% Run segmentation
spm_jobman('run', matlabbatch);
