# declass_stereo

Repo containing early tools, documentation and results on pilot study using ASP to process declassified spy satellite images from Corona and Hexagon programs.
See README and [overview slides from March 2019 presentation](doc/shean_declass_20190306_trim.pdf). We hope to improve ASP support for these historical datasets in the coming years - please reach out to discuss potential opportunities, especially funding options to support ASP developer time.

## Background 
Between the late 1950s and early 1980s, the US Government launched hundreds of reconaissance satellites with optical camera systems. 

Corona (KH-4A,4B) around 1960s.
Hexagon KH-9 from the 1970s to late 1980s. 

These satellites contained contained a frame camera intended for terrain mapping and two high-resolution panoramic stereo cameras (Optical Bar Camera). The ground sampling distance for the mapping camera was around 5-8 m, while the panoramic cameras offered ~0.3-2.0 m (comparable to the modern day very-high-resolution commercial imagery). 

Each mission captured images on film which after declassification are being scanned and digitally archived by the National Archive and USGS. The scanned images are available freely on USGS Earth Explorer, with approximate geolocation information (correct to 100s of m) provided as corner coordinates. The archive on USGS is not exhaustive, and a bulk of imagery still needs to digitally scanned and archived. Several teams have utilised the low resolution frame camera images available on the spacecraft, but the high-resolution panoramic stereo imagery is widely untapped. 

![hexagon sample](/doc/img/Hexagon_Sample.gif)

Figure 1: a) Hexagon Satellite layout, b) film retrieval by US Airforce. Credits: National Reconnaissance Office.

## Optical Bar Camera Model
- Optical bar "panoramic" camera assembly onboard the KH-9 mission consisted of moving physical films in 2 rotating cylinders which swept over a common portion on the ground simultaneously giving 2 wide swath (60 to 90 km) panoramic snapshots at different perspectives with an overlap of ~60 to 70 %.  Once the films in the rolling cylinders were full, they were released to the Earth as capsules which were collected by the US Airforce. 

## Opportunity
- The images can be processed using modern day photogrammetry tools to produce orthoimages and Digital Elevation Models (DEMs) which can be utilised to **quantify** historical landform evolution (glacier dynamics, landslides, mass wasting (eg. mudflow), volcanic eruptions etc.) at unprecedented sub meter resolution.
- Currently, majority of the images remain underutilized, sitting in film-cans.

## Challenges
- Modeling optical bar camera models for stereo reconstruction requires the knowledge of several camera specific parameters such as  camera tilt value, scan rate (rate at which films were moving in the imaging cylinders), scan direction etc.
Even after declassification, these values are not accurately known. These parameters are expected to be essentially mission specific, changing from mission to mission and even during the same mission due to mechanical changes in the imaging system (system heating, wear and tear of parts), owing to its dynamic mode of image collection.
- Physical storage in film-cans results in film distortion through time, which needs to be accounted for in the camera models for accurate stereo reconstruction.

## Workflow
We implemented a semi-automated workflow to process the Corona (KH-4A/4B) and Hexagon (KH-9) panoramic stereoscopic images using the NASA Ames Stereo Pipeline (ASP). We initialise [optical bar camera models](https://github.com/NeoGeographyToolkit/StereoPipeline/blob/master/src/asp/Camera/OpticalBarModel.cc) and iteratively refine using bundle adjustment and 3-D co-registration to a reference DEM. The workflow does not require manual identification of ground control points (GCPs). The main steps are outlined below for a KH-9 sample stereo pair over Mt. St. Helens, WA, USA, acquired in July 1982.  A similar workflow has also been prototyped for a KH-4B sample. The specific commands are commented in the shell scripts [declass_preproc.sh](https://github.com/uw-cryo/declass_stereo/blob/master/scripts/declass_preproc.sh), [declass_stereo.sh](https://github.com/uw-cryo/declass_stereo/blob/master/scripts/declass_stereo.sh) and in the ASP user manual.

- Image Preprocessing
1 image is generally scanned in 2 to 4 sub parts owing to the large size of the film. We mosaic the sub images into 1 frames using tie-point matching in the adjacent overlapping parts and then crop the mosaiced image to remove the ancillary frame information.
 
![preprocess](/doc/img/preprocess.jpg)
Figure 2: Preprocessing involves mosaicing input image subset, cropping the external frame and the orienting the image.

 - Camera initalisation
Using the corner coordinates information provided by USGS, we initialise draft camera model for the images making up a stereo pair.  
 
 - Initial Stereo and Geolocation Refinement:
We implement stereo reconstruction on the image pair and the initial draft camera, after which the point cloud is aligned to accurate external control source (in this case being TanDEM-X global DEM) using 3D Co-registration (translation, rotation and scale transform). The resultant point cloud/DEM height values are still off, but the orientation and rough geolocation of the DEM is close to the external DEM. This transform to external DEM is carried forward in the next bundle adjustment step.

![init_stereo](/doc/img/initial_stereo.jpg)
Figure 3: Initial stereo DEM, before and after co-registration to external control DEM (TanDEM-X). Note the approximately correct orientation but "off" height values for the DEM.

 -----
 
- Coarse Extrinsics optimization:
We use the technique of bundle adjustment, in which feature matches between the two images are used to refine the camera extrinsic (position and pose) making the cameras consistent with each other. We incorporate external DEM values during bundle adjustment, which essentially serve as Ground Control Points. The updated camera result in improved stereo reconstruction and the resultant DEM is further co-registered to TanDEM-X DEM. 

![extrinsic_optimise](/doc/img/extrinsics.jpg)
Figure 4: Bundle adjustment to optimise extrinsics. Note the reduction in the mean pixel residuals for feature matches after bundle adjustment. Co-regitration of DEM from updated cameras results in height values expected within the range of control DEM (TanDEM-X).

 -----
- Intrinsics Optmization:
Once the camera position and orientation have been optimised, we optimise the camera intrinsic values by allowing them to float during the bundle adjustment step. The resultant DEM from the intrinsic optimised cameras is already aligned to the external control DEM (TanDEM-X). The updated cameras and the DEM is then used to generate orthoimages from the input image scenes.
![intrinsic_optimise](/doc/img/intrinsics.jpg)
Figure 5: Bundle adjustment for optimising the intrinsics parameter. DEM from updated cameras is in place, with expected height values, without any coregistration requirement.

 -----

 ## Software Requirements
- [NASA Ames Stereo Pipeline](https://github.com/NeoGeographyToolkit/StereoPipeline)
- [demcoreg](https://github.com/dshean/demcoreg), [pygeotools](https://github.com/dshean/pygeotools).

## Referemces/Links

## Development Team
- David Shean (UW) - Project management and technical direction
- Oleg Alexandrov, Scott McMichael (NASA ARC) - Software and workflow development, testing
- Shashank Bhushan (UW) - Workflow implementation, prototyping
- Amaury Dehecq (NASA JPL, now IGE) - Advising, development of mapping camera workflow
