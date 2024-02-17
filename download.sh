set -x

MIN_X=$1
MAX_X=$2
MIN_Y=$3
MAX_Y=$4
DOWNLOADDIR=$5
TIFDIR=$6

for x in $(seq -f "%02g" $MIN_X $MAX_X) ; do
    for y in $(seq -f "%02g" $MIN_Y $MAX_Y) ; do
        if ! [ -f $DOWNLOADDIR/srtm_${x}_${y}.zip ]; then
            curl -o $DOWNLOADDIR/srtm_${x}_${y}.zip https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_${x}_${y}.zip
        else
            echo "skipping srtm_${x}_${y}.zip because it already exists"
        fi
        if ! [ -f $TIFDIR/srtm_${x}_${y}.tif ]; then
            unzip -v -p $DOWNLOADDIR/srtm_${x}_${y}.zip "*.tif" > $TIFDIR/srtm_${x}_${y}.tif
        fi
    done;
done
