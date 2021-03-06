#!/bin/bash

data=$1

# Split the validation set
mkdir -p $data/train_background_hires_multitask_subset/valid $data/train_background_hires_multitask_subset/train

cut -d ' ' -f 1,2 $data/train_background_hires_multitask_subset/segments > $data/train_background_hires_multitask_subset/segment2utt
utils/utt2spk_to_spk2utt.pl $data/train_background_hires_multitask_subset/segment2utt > $data/train_background_hires_multitask_subset/utt2segment
awk '{print $1" "(NF-1)}' $data/train_background_hires_multitask_subset/utt2segment > $data/train_background_hires_multitask_subset/utt2num_segments
awk '{print $1" "(NF-1)}' $data/train_background_hires_multitask_subset/spk2utt > $data/train_background_hires_multitask_subset/spk2num_utts
awk '{if($2<12) print $0}' $data/train_background_hires_multitask_subset/utt2num_segments > $data/train_background_hires_multitask_subset/valid/utt2num_segments

utils/filter_scp.pl $data/train_background_hires_multitask_subset/valid/utt2num_segments $data/train_background_hires_multitask_subset/utt2segment > $data/train_background_hires_multitask_subset/valid/utt2segment
utils/spk2utt_to_utt2spk.pl $data/train_background_hires_multitask_subset/valid/utt2segment > $data/train_background_hires_multitask_subset/valid/segment2utt
utils/filter_scp.pl $data/train_background_hires_multitask_subset/valid/segment2utt $data/train_background_hires_multitask_subset/utt2spk > $data/train_background_hires_multitask_subset/valid/utt2spk
utils/utt2spk_to_spk2utt.pl $data/train_background_hires_multitask_subset/valid/utt2spk > $data/train_background_hires_multitask_subset/valid/spk2utt

awk '{print $1" "(NF-1)}' $data/train_background_hires_multitask_subset/valid/spk2utt > $data/train_background_hires_multitask_subset/valid/spk2num_utts
sort -k 2 -n $data/train_background_hires_multitask_subset/valid/spk2num_utts | tail -n 150 > $data/train_background_hires_multitask_subset/valid/spk2num_utts.new
mv $data/train_background_hires_multitask_subset/valid/spk2num_utts.new $data/train_background_hires_multitask_subset/valid/spk2num_utts

python -c "
import sys
spk2num = {}
with open(sys.argv[1], 'r') as f:
  for line in f.readlines():
    spk, num = line.strip().split(' ')
    spk2num[spk] = int(num)
fp_out = open(sys.argv[3], 'w')
with open(sys.argv[2], 'r') as f:
  for line in f.readlines():
    spk, num = line.strip().split(' ')
    if int(num) == spk2num[spk]:
      continue
    else:
      fp_out.write(line)
fp_out.close()
" $data/train_background_hires_multitask_subset/spk2num_utts $data/train_background_hires_multitask_subset/valid/spk2num_utts $data/train_background_hires_multitask_subset/valid/spk2num_utts.new
mv $data/train_background_hires_multitask_subset/valid/spk2num_utts.new $data/train_background_hires_multitask_subset/valid/spk2num_utts


utils/filter_scp.pl $data/train_background_hires_multitask_subset/valid/spk2num_utts $data/train_background_hires_multitask_subset/valid/spk2utt > $data/train_background_hires_multitask_subset/valid/spk2utt.new
mv $data/train_background_hires_multitask_subset/valid/spk2utt.new $data/train_background_hires_multitask_subset/valid/spk2utt
utils/spk2utt_to_utt2spk.pl $data/train_background_hires_multitask_subset/valid/spk2utt > $data/train_background_hires_multitask_subset/valid/utt2spk
cp $data/train_background_hires_multitask_subset/feats.scp $data/train_background_hires_multitask_subset/valid
utils/filter_scp.pl $data/train_background_hires_multitask_subset/valid/utt2spk $data/train_background_hires_multitask_subset/utt2num_frames > $data/train_background_hires_multitask_subset/valid/utt2num_frames
utils/filter_scp.pl $data/train_background_hires_multitask_subset/valid/utt2spk $data/train_background_hires_multitask_subset/vad.scp > $data/train_background_hires_multitask_subset/valid/vad.scp
utils/fix_data_dir.sh $data/train_background_hires_multitask_subset/valid
rm $data/train_background_hires_multitask_subset/valid/utt2num_segments $data/train_background_hires_multitask_subset/valid/utt2segment $data/train_background_hires_multitask_subset/valid/segment2utt

utils/filter_scp.pl --exclude $data/train_background_hires_multitask_subset/valid/utt2spk $data/train_background_hires_multitask_subset/utt2spk > $data/train_background_hires_multitask_subset/train/utt2spk
utils/utt2spk_to_spk2utt.pl $data/train_background_hires_multitask_subset/train/utt2spk > $data/train_background_hires_multitask_subset/train/spk2utt
cp $data/train_background_hires_multitask_subset/feats.scp $data/train_background_hires_multitask_subset/train
utils/filter_scp.pl $data/train_background_hires_multitask_subset/train/utt2spk $data/train_background_hires_multitask_subset/utt2num_frames > $data/train_background_hires_multitask_subset/train/utt2num_frames
utils/filter_scp.pl $data/train_background_hires_multitask_subset/train/utt2spk $data/train_background_hires_multitask_subset/vad.scp > $data/train_background_hires_multitask_subset/train/vad.scp
utils/fix_data_dir.sh $data/train_background_hires_multitask_subset/train
awk '{print $1" "(NF-1)}' $data/train_background_hires_multitask_subset/train/spk2utt > $data/train_background_hires_multitask_subset/train/spk2num_utts

# In the training, we need an additional file `spklist` to map the speakers to the indices.
awk -v id=0 '{print $1, id++}' $data/train_background_hires_multitask_subset/train/spk2utt > $data/train_background_hires_multitask_subset/train/spklist