#! /bin/bash
# Script to generate initial image and optical bar cameras 
#directory containing image subsets
img_dir=$1
#this expects the input filenames to be the same as provided by USGS
img_list=$(ls $img_dir/*.tif)
sample_tsai=$(realpath $2)
refdem=$(realpath $3)
outfn=$4
#can accept corner coordinates and corner pixel locations as input, for now they are hardcoded

# mosaic the images using interest point matching
mos_opt=""
mos_opt+=" --ot Byte --overlap-width 3000"
pre_out=${outfn%.*}_pre_mos.tif
echo "mosaicing image"
eval image_mosaic $img_list $mos_opt -o $pre_out

# hardcoded corner pixel coordinates for cropping
# can be accepted as input, or calculated by a script
px_cor='980 1663 116553 1626 116497 23435 1038 23461'
crop_op=""
crop_op+=" rotate-crop"
# Cropping image from frame
echo "cropping image from frame"
eval historical_helper.py crop_op --input-path $pre_out --output-path $outfn --interest-points $px_cor

#hardcoded corner coordinate provided by USGS
init_camera=${outfn%.*}_init_obc.tsai
cor_coord='-123.335 46.407 -122.031 46.278 -122.1 46.1 -123.368 46.25'
cam_gen_opt=""
cam_gen_opt+=" --camera-type opticalbar --refine-camera"
echo "generating initial optical bar camera"
eval cam_gen $cam_gen_opt --sample-file $sample_tsai --lon-lat-values $cor_coord --reference-dem $refdem $outfn -o $init_camera
echo "Script is complete !"
