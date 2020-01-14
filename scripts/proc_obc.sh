#! /bin/bash
img1=$(realpath $1)
img2=$(realpath $2)
cam1=$(realpath $3)
cam2=$(realpath $4)
refdem=$(realpath $5)
outdir=$(realpath $6)
epsg=$7

echo "Input images and cameras are "$img1 $img2 $cam1 $cam2
echo "Reference DEM is"$refdem

# Running initial stereo
init_stereo_dir=$outdir/init_stereo
stereo $img1 $img2 $cam1 $cam2 --alignment-method affineepipolar --unalign-disparity $init_stereo_dir/run
#use point clound and unalign disparity map 
pc_init=$(realpath $init_stereo_dir/*-PC.tif)
un_disp_1=$(realpath $init_stereo_dir/*unaligned-D.tif)
#grid point cloud to coarse DEM, here at 120 m
point2dem $pc_init --t_srs $epsg --tr 120
dem_1=$(realpath $init_stereo_dir/*-DEM.tif)
#align coarse DEM to reference DEM
pc_align $refdem $dem_1 --max-displacement -1 --initial-transform-from-hillshading similarity --save-transformed-source-points -o $init_stereo_dir/run
# the DEM/point cloud alignment are saved in the DEM output folder
transform_1=$(realpath $init_stereo_dir/*-transform.txt)
echo "Round 1 stereo and co-registration complete, now optimizing extrinsics"
ba_dir_1=$outdir/ba_extrinsic
# need to migrate these calls to "eval" structure
# use reference terrain as default, other options include to use heights from DEM and both the options in combo, provided below but commented out
echo "refining extrinsic"
bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --reference-terrain-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --disparity-list $un_disp_1 --reference-terrain $refdem --initial-transform $transform_1 -o $ba_dir_1/run
#heights from DEM
#bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --heights-from-dem-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --heights-from-dem $refdem --initial-transform $transform_1 -o $ba_dir_1/run
#bundle_adjust $img1 $img2 $cam1 $cam2 --max-iterations 50 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 -t opticalbar --datum WGS84 --force-reuse-match-files --heights-from-dem-weight 1000 --parameter-tolerance 1e-12 --max-disp-error 100 --heights-from-dem $refdem --disparity-list $un_disp_1 --reference-terrain $refdem --initial-transform $transform_1 -o $ba_dir_1/run
# Need to check some of the hard codes here, result can be potentially better
# Use the updated cameras to do stereo
cam1_ex=$ba_dir_1/run-*$cam1
cam2_ex=$ba_dir_1/run-*$cam2
stereo_dir_2=$outdir/stereo_ex
stereo $img1 $img2 $cam1_ex $cam2_ex --alignment-method affineepipolar --unalign-disparity $stereo_dir_2/run 
# using affineepipolar might not make sense here, is there an epipolar line existing in first place ?
pc_ex=$(realpath $stereo_dir2/*-PC.tif)
un_disp_2=$(realpath $stereo_dir2/*unaligned-D.tif)
point2dem $pc_ex --t_srs $epsg --tr 120
dem_2=$(realpath $stereo_dir_2/*-DEM.tif)
#align coarse DEM to reference DEM
pc_align $refdem $dem_2 --max-displacement -1 --initial-transform-from-hillshading similarity --save-transformed-source-points -o $stereo_dir_2/run
transform_2=$(realpath $stereo_dir_2/*-transform.txt)
# Optimise for intrinsics
$ba_dir_2=$outdir/ba_intrinsic
echo "refining intrinsic"
bundle_adjust $img1 $img2 $cam1_ex $cam2_ex -t opticalbar --force-reuse-match-files --max-iterations 30 --camera-weight 0 --disable-tri-ip-filter --inline-adjustments --ip-detect-method 1 --datum WGS84 --num-passes 2 --solve-intrinsics --intrinsics-to-float "focal_length optical_center other_intrinsics" --intrinsics-to-share "focal_length optical_center" --ip-per-tile 1000 --intrinsics-limits "0.95 1.05 0.90 1.10 0.90 1.10 0.5 1.5 -5.0 5.0 0.3 2.0" --num-random-passes 2 --max-disp-error 100 --disparity-list $un_disp_2 --reference-terrain $refdem --initial-transform $transform_2 --reference-terrain-weight 1000 -o $ba_dir_2/run
# Load updated cameras as variables for stereo, orthorectification
cam1_in=$ba_dir_2/run-*$cam1_ex
cam2_in=$ba_dir_2/run-*$cam2_ex
stereo_dir_3=$outdir/stereo_in
echo "performing final stereo"
stereo $img1 $img2 $cam1_in $cam2_in --alignment-method affineepipolar --unalign-disparity $stereo_dir_3/run
pc_in=$(realpath $stereo_dir3/*-PC.tif)
point2dem $pc_in --t_srs $epsg --tr 4
dem_fin=$(realpath $stereo_dir3/*-DEM.tif)
# produce ortho image from left image
ortho=$outdir/left_ortho.tif
dem=$refdem
#dem=$dem_fin
echo "generating ortho image"
mapproject -t opticalbar $dem --t_srs $epsg $img1 $cam1_in $ortho
echo "script is complete !"
