# declass_stereo
- Repository containing notes and workflows for photogrammetric processing of declassified images
 
## Background 
During the cold-war era, the US Government had several spy satellites in orbit, obtaining images all around the globe. There were several generations of the mission, such as Corona (KH-4A,4B) from around 1960s to xxxx, the Hexagon KH-9 from the 1970s to xxxx. These satellites contained contained a frame mapping “pinhole” and a pair of stereoscopic panoramic cameras (opticalbar cameras on board the KH-4A,4B, KH-9). The ground sampling distance for the frame camera images is around 5-8 m/px, while that for the panoramic camera images is ~30 to 50 cm/px (comparable to the modern day commercial DigitalGlobe images). During the operational period, the images were captured/stored on physical films which after declassification are being scanned and digitally archived by the National Archive and USGS. The scanned images are available freely on USGS Earth Explorer, with approximate geolocation information (correct to 100s of m) provided as corner coordinates. The archive on USGS is not exhaustive, and a bulk of imagery still needs to digitally scanned and archived. Several teams have utilised the low resolution frame camera images available on the spacecraft, but the high-resolution panoramic stereo imagery is widely untapped. 

** Figure ** 

Figure 1 Credits (National Reconnaissance Office).

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
We have implemented a semi-automatic workflow to process the Corona (KH-4A,B) and KH-9 panoramic stereoscopic images using the NASA Ames Stereo Pipeline (ASP). We initialise initial optical bar camera models and iteratively refine them using Bundle adjustment and 3D Co-registration to a reference DEM. The workflow is implemented without the requirement of manual Ground Control Points. The main steps are outlined below for a KH-9 sample stereo pair over Mt. St. Helens, WA, USA (July 1982), however it is similar in practice for the KH-4 A,B optical bar imagery. The specific commands are commented in the shell script (link:) and in the ASP user manual.

- Image Preprocessing
1 image is generally scanned in 2 to 4 sub parts owing to the large size (x * x) cm of the film. We mosaic the sub images into 1 frames using tie-point matching in the adjacent overlapping parts and then crop the mosaiced image to remove the ancillary frame information.
 ** Figure **
 - Camera initalisation
Using the corner coordinates information provided by USGS, we initialise draft camera model for the images making up a stereo pair.  
 
 - Initial Stereo and Geolocation Refinement:
We implement stereo reconstruction on the image pair and the initial draft camera, after which the point cloud is aligned to accurate external control source (in this case being TanDEM-X global DEM) using 3D Co-registration (translation, rotation and scale transform). The resultant point cloud/DEM height values are still off, but the orientation and rough geolocation of the DEM is close to the external DEM. This transform to external DEM is carried forward in the next bundle adjustment step.
 ** Figure **
 
 -----
 
- Coarse Extrinsics optimization:
We use the technique of bundle adjustment, in which feature matches between the two images are used to refine the camera extrinsic (position and pose) making the cameras consistent with each other. We incorporate external DEM values during bundle adjustment, which essentially serve as Ground Control Points. The updated camera result in improved stereo reconstruction and the resultant DEM is further co-registered to TanDEM-X DEM. 
** Figure ** 
 -----
- Intrinsics Optmization:
Once the camera position and orientation have been optimised, we optimise the camera intrinsic values by allowing them to float during the bundle adjustment step. The resultant DEM from the intrinsic optimised cameras is already aligned to the external control DEM (TanDEM-X). The updated cameras and the DEM is then used to generate orthoimages from the input image scenes.
** Figure **
** Figure with orthoimage **
 -----

 ## Software Requirements
- NASA AMES Stereo Pipeline
- demcoreg, pygeotools.

## Referemces/Links

## Workflow Development Team
- David Shean (UW) (Design and Technical Direction)
- Oleg Alexandrov, Scott McMichael (NASA AMES) (Software and Workflow Development, Prototyping)
- Shashank Bhushan (UW) (Prototyping and workflow implementation)

#TODO: Add images,links,references, dates of mission, add bash script wrapper.

