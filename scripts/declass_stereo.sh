#! /bin/bash

#Wrapper shell script for sample Hexagon (KH-9) stereo processing workflow 
#Shashank Bhushan, David Shean

#Requires command-line utilities from the NASA Ames Stereo Pipeline

#Input images and camera models (output from preprocessing script)
img1=$(realpath $1)
img2=$(realpath $2)
cam1=$(realpath $3)
cam2=$(realpath $4)

#Reference DEM
refdem=$(realpath $5)
outdir=$(realpath $6)

#EPSG code for output projection should be of form "EPSG:32610"
#TODO: extract from reference DEM
epsg=$7

#Coarse DEM resolution for intermediate steps
coarse_tr=120
#Fine DEM grid resolutoin for final products
fine_tr=4

echo "Input images and cameras: $img1 $img2 $cam1 $cam2"
echo "Reference DEM: $refdem"

# Run stereo with initial camera models
init_stereo_dir=$outdir/init_stereo
stereo $img1 $img2 $cam1 $cam2 --alignment-method affineepipolar --unalign-disparity $init_stereo_dir/run

#Identify output point clound (PC) and unalign disparity map 
pc_init=$(realpath $init_stereo_dir/*-PC.tif)
un_disp_1=$(realpath $init_stereo_dir/*unaligned-D.tif)

#Create coarse gridded DEM from point cloud
point2dem $pc_init --t_srs $epsg --tr $coarse_tr -errorimage
dem_1=$(realpath $init_stereo_dir/*-DEM.tif)

#Align coarse DEM to reference DEM
pc_align $refdem $dem_1 --max-displacement -1 --initial-transform-from-hillshading similarity --save-transformed-source-points -o $init_stereo_dir/run
# the DEM/point cloud alignment are saved in the DEM output folder
transform_1=$(realpath $init_stereo_dir/*-transform.txt)

# Update camera model extrinsics
ba_dir_1=$outdir/ba_extrinsic
# need to migrate these calls to "eval" structure
# Use reference DEM 
bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --reference-terrain-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --disparity-list $un_disp_1 --reference-terrain $refdem --initial-transform $transform_1 -o $ba_dir_1/run
# Use heights from reference DEM
#bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --heights-from-dem-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --heights-from-dem $refdem --initial-transform $transform_1 -o $ba_dir_1/run
# Use both reference DEM and heights from reference DEM
#bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --heights-from-dem-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --heights-from-dem $refdem --disparity-list $un_disp_1 --reference-terrain $refdem --initial-transform $transform_1 -o $ba_dir_1/run

# Run second round of stereo with updated camera models
cam1_ex=$ba_dir_1/run-*$cam1
cam2_ex=$ba_dir_1/run-*$cam2
stereo_dir_2=$outdir/stereo_extrinsic
# using affineepipolar might not make sense here, is there an epipolar line existing in first place ?
stereo $img1 $img2 $cam1_ex $cam2_ex --alignment-method affineepipolar --unalign-disparity $stereo_dir_2/run 

#Create updated coarse gridded DEM
pc_ex=$(realpath $stereo_dir2/*-PC.tif)
un_disp_2=$(realpath $stereo_dir2/*unaligned-D.tif)
point2dem $pc_ex --t_srs $epsg --tr $coarse_tr  --errorimage 
dem_2=$(realpath $stereo_dir_2/*-DEM.tif)

#Align updated coarse DEM to reference DEM
pc_align $refdem $dem_2 --max-displacement -1 --initial-transform-from-hillshading similarity --save-transformed-source-points -o $stereo_dir_2/run
transform_2=$(realpath $stereo_dir_2/*-transform.txt)

#Optimise for camera model intrinsics
$ba_dir_2=$outdir/ba_intrinsic
bundle_adjust $img1 $img2 $cam1_ex $cam2_ex -t opticalbar --force-reuse-match-files --max-iterations 30 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 --datum WGS84 --num-passes 2 --solve-intrinsics --intrinsics-to-float "focal_length optical_center other_intrinsics" --intrinsics-to-share "focal_length optical_center" --ip-per-tile 1000 --intrinsics-limits "0.95 1.05 0.90 1.10 0.90 1.10 0.5 1.5 -5.0 5.0 0.3 2.0" --num-random-passes 2 --max-disp-error 100 --disparity-list $un_disp_2 --reference-terrain $refdem --initial-transform $transform_2 --reference-terrain-weight 1000 -o $ba_dir_2/run

#Option - do an additional round of extrinsic/intrinsic refinement

#Run final round of stereo
cam1_in=$ba_dir_2/run-*$cam1_ex
cam2_in=$ba_dir_2/run-*$cam2_ex
stereo_dir_3=$outdir/stereo_in
stereo $img1 $img2 $cam1_in $cam2_in --alignment-method affineepipolar --unalign-disparity $stereo_dir_3/run
pc_in=$(realpath $stereo_dir3/*-PC.tif)
l_img=$(realpath $stereo_dir3/*-L.tif)

#Create final gridded DEM and confirming orthoimage at fine resolution
point2dem $pc_in $l_img --t_srs $epsg --tr $fine_tr --orthoimage -errorimage
dem_fin=$(realpath $stereo_dir3/*-DEM.tif)
ortho_fin=$(realpath $stereo_dir3/*-DRG.tif)
#At this stage, since our cameras still do not confirm to the reference DEM 100%, our best shot at orthoimage is one from point2dem

#Create ortho image from left image
#TODO: create orthoimages from both inputs, use original filenames, not "left/right"
#ortho=$outdir/${img1%.*}_ortho.tif
ortho=$outdir/left_ortho.tif
ortho_dem=$refdem
#ortho_dem=$dem_fin
mapproject -t opticalbar $ortho_dem --t_srs $epsg $img1 $cam1_in $ortho
