# declass_stereo
 
## Background 
Between the late 1950s and early 1980s, the US Government launched hundreds of reconaissance satellites with optical camera systems. 

Corona (KH-4A,4B) from around 1960s to xxxx
Hexagon KH-9 from the 1970s to xxxx. 

These satellites contained contained a frame camera intended for terrain mapping and two high-resolution panoramic stereo cameras (Optical Bar Camera). The ground sampling distance for the mapping camera was around 5-8 m, while the panoramic cameras offered ~0.3-2.0 m (comparable to the modern day very-high-resolution commercial imagery). 

Each mission captured images on film which after declassification are being scanned and digitally archived by the National Archive and USGS. The scanned images are available freely on USGS Earth Explorer, with approximate geolocation information (correct to 100s of m) provided as corner coordinates. The archive on USGS is not exhaustive, and a bulk of imagery still needs to digitally scanned and archived. Several teams have utilised the low resolution frame camera images available on the spacecraft, but the high-resolution panoramic stereo imagery is widely untapped. 

** Figure ** 
[[https://github.com/uw-cryo/declass_stereo/blob/master/declass_readme_images/Hexagon_Sample.gif|alt=octocat]]

Figure 1: a) Hexagon Satellite layout, b) film retrieval by US Airforce. Credits: National Reconnaissance Office.

## Optical Bar Camera Model
- Optical bar "panoramic" camera assembly onboard the KH-9 mission consisted of moving physical films in 2 rotating cylinders which swept over a common portion on the ground simultaneously giving 2 wide swath (60 to 90 km) panoramic snapshots at different perspectives with an overlap of ~x%.  Once the films in the rolling cylinders were full, they were released to the Earth as capsules which were collected by the US Airforce. 

## Opportunity
- The images can be processed using modern day photogrammetry tools to produce orthoimages and Digital Elevation Models (DEMs) which can be utilised to **quantify** historical landform evolution (glacier dynamics, landslides, mass wasting (eg. mudflow), volcanic eruptions etc.) at unprecedented sub meter resolution.
- Currently, majority of the images remain underutilized, sitting in film-cans.

## Challenges
- Modeling optical bar camera models for stereo reconstruction requires the knowledge of several camera specific parameters such as  camera tilt value, scan rate (rate at which films were moving in the imaging cylinders), scan direction etc.
Even after declassification, these values are not accurately known. These parameters are expected to be essentially mission specific, changing from mission to mission and even during the same mission due to mechanical changes in the imaging system (system heating, wear and tear of parts), owing to its dynamic mode of image collection.
- Physical storage in film-cans results in film distortion through time, which needs to be accounted for in the camera models for accurate stereo reconstruction.

## Workflow
We implemented a semi-automated workflow to process the Corona (KH-4A/4B) and Hexagon (KH-9) panoramic stereoscopic images using the NASA Ames Stereo Pipeline (ASP). We initialise [optical bar camera models](https://github.com/NeoGeographyToolkit/StereoPipeline/blob/master/src/asp/Camera/OpticalBarModel.cc) and iteratively refine using bundle adjustment and 3-D co-registration to a reference DEM. The workflow does not require manual identification of ground control points (GCPs). The main steps are outlined below for a KH-9 sample stereo pair over Mt. St. Helens, WA, USA, acquired in July 1982.  A similar workflow has also been prototyped for a KH-4B sample. The specific commands are commented in the shell script (link:) and in the ASP user manual.

- Image Preprocessing
1 image is generally scanned in 2 to 4 sub parts owing to the large size (x * x) cm of the film. We mosaic the sub images into 1 frames using tie-point matching in the adjacent overlapping parts and then crop the mosaiced image to remove the ancillary frame information.
 ** Figure **
 
[[https://github.com/uw-cryo/declass_stereo/blob/master/declass_readme_images/preprocess.jpg|alt=octocat]]
Figure 2: Preprocessing involves mosaicing input image subset, cropping the external frame and the orienting the image.

 - Camera initalisation
Using the corner coordinates information provided by USGS, we initialise draft camera model for the images making up a stereo pair.  
 
 - Initial Stereo and Geolocation Refinement:
We implement stereo reconstruction on the image pair and the initial draft camera, after which the point cloud is aligned to accurate external control source (in this case being TanDEM-X global DEM) using 3D Co-registration (translation, rotation and scale transform). The resultant point cloud/DEM height values are still off, but the orientation and rough geolocation of the DEM is close to the external DEM. This transform to external DEM is carried forward in the next bundle adjustment step.

[[https://github.com/uw-cryo/declass_stereo/blob/master/declass_readme_images/initial_stereo.jpg|alt=octocat]]
Figure 3: Initial stereo DEM, before and after co-registration to external control DEM (TanDEM-X). Note the approximately correct orientation but "off" height values for the DEM.

 -----
 
- Coarse Extrinsics optimization:
We use the technique of bundle adjustment, in which feature matches between the two images are used to refine the camera extrinsic (position and pose) making the cameras consistent with each other. We incorporate external DEM values during bundle adjustment, which essentially serve as Ground Control Points. The updated camera result in improved stereo reconstruction and the resultant DEM is further co-registered to TanDEM-X DEM. 

[[https://github.com/uw-cryo/declass_stereo/blob/master/declass_readme_images/extrinsics.jpg|alt=octocat]]
Figure 4: Bundle adjustment to optimise extrinsics. Note the reduction in the mean pixel residuals for feature matches after bundle adjustment. Co-regitration of DEM from updated cameras results in height values expected within the range of control DEM (TanDEM-X).

 -----
- Intrinsics Optmization:
Once the camera position and orientation have been optimised, we optimise the camera intrinsic values by allowing them to float during the bundle adjustment step. The resultant DEM from the intrinsic optimised cameras is already aligned to the external control DEM (TanDEM-X). The updated cameras and the DEM is then used to generate orthoimages from the input image scenes.
[[https://github.com/uw-cryo/declass_stereo/blob/master/declass_readme_images/intrinsics.jpg|alt=octocat]]
Figure 5: Bundle adjustment for optimising the intrinsics parameter. DEM from updated cameras is in place, with expected height values, without any coregistration requirement.

** Figure with orthoimage **
 -----

 ## Software Requirements
- [NASA AMES Stereo Pipeline][https://github.com/NeoGeographyToolkit/StereoPipeline]
- [demcoreg][https://github.com/dshean/demcoreg], [pygeotools][https://github.com/dshean/pygeotools].

## Referemces/Links

## Workflow Development Team
- David Shean (UW) (Design and Technical Direction)
- Oleg Alexandrov, Scott McMichael (NASA AMES) (Software and Workflow Development, Prototyping)
- Shashank Bhushan (UW) (Prototyping and workflow implementation)

#TODO: Add images,links,references, dates of mission, add bash script wrapper.

