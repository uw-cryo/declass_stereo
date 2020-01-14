#! /bin/bash

#Wrapper shell script for sample Hexagon (KH-9) image pre-processing
#Shashank Bhushan, David Shean

#Requires command-line utilities from the NASA Ames Stereo Pipeline

#TODO: Improved file handling to identify unique image IDs from all scanned subscenes, and run in parallel

#Input image directory (containg *a.tif, *b.tif etc.)
img_dir=$1
#Input optical bar camera model template, in files subdir
#TODO: copy strings here and dynamically create, set scan_dir properly
sample_tsai=$(realpath $2)
#Reference DEM
refdem=$(realpath $3)
outfn=$4

#For now, assume only one image ID per directory
#Assume filenames are of the form D3C1217-200742A004_a.tif
img_list=$(ls $img_dir/*_[a-z].tif)

#Combine input images using interest point matches to create full-resolutoin mosaic
mos_opt=""
mos_opt+=" --ot Byte --overlap-width 3000"
pre_out=${outfn%.*}_pre_mos.tif
eval image_mosaic $img_list $mos_opt -o $pre_out

#Remove frame from mosaicked image
#Can accept corner coordinates and corner pixel locations as input, for now they are hardcoded
#TODO: create tool to identify frame corners 
#TODO: revisit rotation and corner coordinate order for different scan directions 
px_cor='980 1663 116553 1626 116497 23435 1038 23461'
eval historical_helper.py rotate-crop --input-path $pre_out --output-path $outfn --interest-points $px_cor

#Extract corner coordinates from USGS polygon geometry
#Hardcoded for now
cor_coord='-123.335 46.407 -122.031 46.278 -122.1 46.1 -123.368 46.25'

#Generate initial camera model for cropped full-resolution mosaic
init_camera=${outfn%.*}_init_obc.tsai
eval cam_gen --camera-type opticalbar --refine-camera --sample-file $sample_tsai --lon-lat-values $cor_coord --reference-dem $refdem $outfn -o $init_camera
