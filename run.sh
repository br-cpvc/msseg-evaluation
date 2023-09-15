#!/usr/bin/env bash
set -e
#set -x

python3=python3

dataverse_dir=../wmh-sc/dataverse_files
start=`date +%s`
ts=`date +%Y%m%d-%H%M%S`
echo "START TIME: $ts"

itr=0
for d in $dataverse_dir/test/{S,U}*/*/ $dataverse_dir/test/Amsterdam/*/*/; do
#for d in $dataverse_dir/test/Amsterdam/P*/{160,164}/; do
  logfile="$d/stdout.log"
  echo "WRITING TO: $logfile"

  itrstart=`date +%s`

  cmd="./segment-wml.sh \"$d\" > \"$logfile\""
  #echo "$cmd"
  eval "$cmd"

  echo "program(step),duration" > "$d/timing_in_seconds.csv"
  cat "$logfile" | grep "It took roughly" | cut -d ":" -f2 | sed "s/It took roughly /),/" | sed "s/...Done! //" | sed "s/ done! //" | sed "s/  R/ r/" | sed "s/ seconds//" | sed "s/^ /robex(/" >> "$d/timing_in_seconds.csv"
  cat "$logfile" | grep "secs." | sed "s/MSSEG: /msseg(/" | sed "s/ (/,/" | sed "s/ secs.)//" | sed "s/Re-estimate tissue /re-estimate tissue/" | sed "s/,/),/" >> "$d/timing_in_seconds.csv"
  cat "$logfile" | grep duration | sed "s/duration in seconds - //" | sed "s/: /),/" | sed "s/^/pipeline(/" >> "$d/timing_in_seconds.csv"
  $python3 reverse_csv_axis.py -i "$d/timing_in_seconds.csv" -c "program(step)" -o "$d/timing_record_in_seconds.csv"

  end=`date +%s`
  ts=`date +%Y%m%d-%H%M%S`
  let itr=itr+1
  echo "[$ts] itr#: $itr, duration: $((end-itrstart)) seconds, elapsed: $((end-start)) seconds"
done

outdir=report/output/data
mkdir -p $outdir

echo "STEP: generating: wmh-sc_measurements_all.csv"
$python3 concat_csv_files.py -i $dataverse_dir/test/*/*/wmh-sc_measurements.csv $dataverse_dir/test/*/*/*/wmh-sc_measurements.csv -o $outdir/wmh-sc_measurements_all.csv

echo "STEP: generating: c3d_overlap1_all.csv"
$python3 concat_csv_files.py -i $dataverse_dir/test/*/*/c3d_overlap1.csv $dataverse_dir/test/*/*/*/c3d_overlap1.csv -o $outdir/c3d_overlap1_all.csv

echo "STEP: generating: timing_in_seconds_all.csv"
$python3 concat_csv_files.py -i $dataverse_dir/test/*/*/*/timing_record_in_seconds.csv $dataverse_dir/test/*/*/timing_record_in_seconds.csv  -o $outdir/timing_record_in_seconds_all.csv

echo "STEP: generating: measurements.csv"
$python3 merge_csv_files.py -m image_id -i $outdir/c3d_overlap1_all.csv $outdir/wmh-sc_measurements_all.csv -o $outdir/measurements.csv

echo "STEP: generating: measurements_summery.csv"
$python3 describe_data.py -i $outdir/measurements.csv -t -o $outdir/measurements_summery.csv

echo "STEP: generating: timing_record_in_seconds_summery.csv"
$python3 describe_data.py -i $outdir/timing_record_in_seconds_all.csv -t -o $outdir/timing_record_in_seconds_summery.csv

ts=`date +%Y%m%d-%H%M%S`
echo "END TIME: $ts"
