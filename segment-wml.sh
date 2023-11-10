#!/usr/bin/env bash
set -e
#set -x

#dir=../wmh-sc/dataverse_files/training/Amsterdam/GE3T/104
dir="$1"

T1="$dir/pre/T1"
FLAIR="$dir/pre/FLAIR"

T1_LPI="${T1}_LPI"
FLAIR_LPI="${FLAIR}_LPI"

c3d=c3d
python3=python

overwrite=true
#overwrite=false

if [[ $overwrite = true || ! -f "${T1_LPI}.nii.gz" ]]; then
$c3d "$T1.nii.gz" -swapdim LPI -o "${T1_LPI}.nii.gz"
fi
if [[ $overwrite = true || ! -f "${FLAIR_LPI}.nii.gz" ]]; then
$c3d "$FLAIR.nii.gz" -swapdim LPI -o "${FLAIR_LPI}.nii.gz"
fi

MASK="${T1_LPI}_mask"

# wget https://github.com/muschellij2/robex/releases/download/v1.2.3.0/robex_1.2.3_R_x86_64-pc-linux-gnu.tar.gz
# tar xzf robex_1.2.3_R_x86_64-pc-linux-gnu.tar.gz robex
if [[ $overwrite = true || ! -f "${MASK}.nii.gz" ]]; then
start=`date +%s`
cd robex
# remove temporary directory to avoid warnings in output
rm -rf ./temp_T1_LPI_mask.nii.gz/nwlrbbmq ./temp_T1_LPI_mask.nii.gz/
# Note: copying files into robex dir because ROBEX
# does not support paths which include spaces
cp -a "../$T1_LPI.nii.gz" T1_LPI.nii.gz
./ROBEX T1_LPI.nii.gz T1_LPI_mask.nii.gz
cp -a T1_LPI_mask.nii.gz "../$MASK.nii.gz"
rm T1_LPI.nii.gz T1_LPI_mask.nii.gz
cd ..
#cwd="$(pwd)"
#rm -f "$dir/pre/ref_vols" "$dir/pre/dat"
#ln -s "$cwd/robex/ref_vols" "$dir/pre/ref_vols"
#ln -s "$cwd/robex/dat" "$dir/pre/dat"
#cd "$dir/pre"
#$cwd/robex/ROBEX "T1_LPI.nii.gz" "T1_LPI_mask.nii.gz"
#rm -f ref_vols dat
#cd $cwd
end=`date +%s`
runtime=$((end-start))
echo "duration in seconds - robex: $runtime"
fi

overwrite=true

if [[ $overwrite = true || ! -f "$dir/result_LPI.nii.gz" ]]; then
start=`date +%s`
./msseg-cli "../../$T1_LPI" "../../$MASK" "../../$FLAIR_LPI"
cp -a "$dir/pre/.run/T1_LPI_MSSEG_refilled_candidates.nii.gz" "$dir/result_LPI.nii.gz"
end=`date +%s`
runtime=$((end-start))
echo "duration in seconds - msseg: $runtime"
fi

if [[ $overwrite = true || ! -f "$dir/result.nii.gz" ]]; then
$c3d "$dir/result_LPI.nii.gz" -swapdim RAI -type uchar -o "$dir/result.nii.gz"
fi
if [[ $overwrite = true || ! -f "$dir/c3d_overlap1.csv" ]]; then
echo "Matching voxels in first image,Matching voxels in second image,overlap,Dice,Intersection ratio" > "$dir/c3d_overlap1.csv"
$c3d "$dir/wmh.nii.gz" "$dir/result.nii.gz" -overlap 1 | tr -d " " | cut -d, -f2- >> "$dir/c3d_overlap1.csv"
fi

if [[ $overwrite = true || ! -f "$dir/wmh-sc_measurements.csv" ]]; then
PYTHONPATH=deps/wmhchallenge/ $python3 calculate_measurements.py -t "$dir/wmh.nii.gz" -r "$dir/result.nii.gz" > "$dir/wmh-sc_measurements.csv"
fi
