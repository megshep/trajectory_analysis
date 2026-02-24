% This provides a subject ID with a SLURM array ID to allow for multiple job arrays to be submitted at the same time on the CSF
SUB_ID = str2double(getenv('SLURM_ARRAY_TASK_ID'));

% Defining the directory where the seg8.mat files are saved - this is the .mat file that contains the segmentation parameters of the avg templates made
segDir = '/scratch/j90161ms';

% Find and sort all seg8.mat files -- this code removes avg_*_.seg8.mat files because these were created in a previous analysis. If you haven't actively created these, then you don't need to exclude them!
seg_files_all = dir(fullfile(segDir, '*._seg8.mat'));
names = {seg_files_all.name};
keep_idx = ~startsWith(names, 'avg_');
seg_files = fullfile({seg_files_all(keep_idx).folder}, {seg_files_all(keep_idx).name});
seg_files = sort(seg_files);

%checks subject_IDs 
if SUB_ID < 1 || SUB_ID > numel(seg_files)
    error('Invalid SUB_ID');
end

% Select this subject’s file and tell me which subject is running when I check the .out file - also defines subject_name to help save the TCVs later
this_seg = seg_files{SUB_ID};
[~, subj_name] = fileparts(this_seg);
subj_name = strrep(subj_name,' ','_');

%
% Capture all console output - this is necessary as SPM25 doesn't load in the TCVs as a variable, simply as output, so we need to save the numbers generated in the console rather than saving them as variables through MATLAB
diary_file = fullfile(segDir, ['diary_' subj_name '.txt']);
diary(diary_file);

% Build SPM batch
% This inputs the segmentation parameters for each ID into the model and compares to the ICV mask from SPMs directory and produces a .txt file of the TCVs for each ID. 
matlabbatch{1}.spm.util.tvol.matfiles = {this_seg};
matlabbatch{1}.spm.util.tvol.tmax = 3;
matlabbatch{1}.spm.util.tvol.mask = {'/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm/tpm/mask_ICV.nii,1'};
matlabbatch{1}.spm.util.tvol.outf = 'TCV';

% Give each subject a unique output file name associated with their subject ID
matlabbatch{1}.spm.util.tvol.outf = fullfile(segDir, ['TCV_' subj_name]);

% Run job on spm within CSF
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

% Stop capturing console output
diary off


% Read volumes from diary - this opens the diary, reads all of the lines, separates them into separate lines and then closes the diary
fid = fopen(diary_file,'r');
txt = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
lines = txt{1};

% Find lines within the diary which contain the cranial volumes for grey, white and CSFf for each subject, with an in-built sanity check to identify if there is an error at this step
idx = find(contains(lines,'Volumes:'));
if isempty(idx)
    error('Could not find volumes in diary for %s', subj_name);
end

% This extracts the volumes for the different tissue classes and converts them into numerical values from previous string variables
vol_line = strtrim(lines{idx+1});
vol_values = sscanf(vol_line,'%f');

%in built sanity check -- error detection step
if numel(vol_values) ~= 3
    error('Expected 3 volumes (GM, WM, CSF), got %d', numel(vol_values));
end

% Save file
outFile = fullfile(segDir, ['TCV_' subj_name '.txt']);
fid = fopen(outFile,'w');
fprintf(fid,'%f\t%f\t%f\n', vol_values(1), vol_values(2), vol_values(3));
fclose(fid);

disp(['Saved TCV for subject: ', subj_name]);
disp(['Check: ', outFile]);
