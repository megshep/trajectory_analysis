#!/bin/bash
cd /scratch/j90161ms

#find all rc1 and rc2 files in my scratch space whilst excluding rc1avg and rc2avg before geodesic shooting
rc1_list=$(find . -type f -name 'rc1*.nii' ! -name '*avg*')
rc2_list=$(find . -type f -name 'rc2*.nii' ! -name '*avg*')

#extract the IDs from the file names (remove rc1 and .nii)
rc1_ids=$(echo "$rc1_list" | sed -E 's/.*rc1([^/]*).nii/\1/')
rc2_ids=$(echo "$rc2_list" | sed -E 's/.*rc2([^/]*).nii/\1/')

#combine them into one file and save this in my scratch space
comm -12 <(echo "$rc1_ids" | sort | uniq) <(echo "$rc2_ids" | sort | uniq) > /scratch/j90161ms/valid_subject_IDs.txt
