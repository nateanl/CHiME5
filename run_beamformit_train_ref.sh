. ./cmd.sh
. ./path.sh

# Config:
cmd=run.pl

. utils/parse_options.sh || exit 1;

sdir=/home/data/CHiME5/audio/train/ #The source directory eg /home/data/CHiME5/audio/train
odir=/scratch/near/temp/kaldi/egs/chime5/s5/enhan/train_beamformit_ref/ #The output directory eg /scratch/near/temp/kaldi/egs/chime5/enhan/
expdir=exp/enhan/train_stereo


# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

mkdir -p $odir
mkdir -p $expdir/log

#Get all file names and save it to channels_ref
#make show_id the same


# wavfiles.list can be used as the name of the output files
output_wavfiles=$expdir/wavfiles.list
find ${sdir} | grep -v '.*CH[0-9].*' | awk -F "/" '{print $NF}' | sed -e "s/\.wav//" | sort | uniq > $expdir/wavfiles.list
# this is an input file list of the microphones, for stereo file, just list one file
# format: show_id file.wav
input_arrays=$expdir/channels_list
for x in `cat $output_wavfiles`; do
  echo -n "$x"
  echo -n " $x.wav"
  echo ""
done > $input_arrays


echo -e "Beamforming\n"
# making a shell script for each job
for x in `cat $output_wavfiles`; do
$BEAMFORMIT/BeamformIt -s $x  -c $input_arrays \
    --config_file `pwd`/conf/beamformit.cfg \
    --source_dir $sdir \
    --result_dir $odir
done

# chmod a+x $expdir/log/beamform.sh
# $cmd $expdir/log/beamform.log \
#   $expdir/log/beamform.sh

echo "`basename $0` Done."