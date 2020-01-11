# declass_stereo
- Repository containing notes and workflows for photogrammetric processing of declassified images
 
## Background 
KeyHole-9 (Hexagon-9) referred by many as an "Engineering Marvel" was one of the last spy satellites launched during the cold war era. KH9 contained a frame mapping pinhole and a pair of stereoscopic panoramic cameras (opticalbar). The ground sampling distance was comparable to the modern day WorldView images (~30 cm, ah!). However, these images were captured on physical films rather than a digital format which have suffered film distorttion in time during storage. Very limited camera model information exists for these images, making direct stereo reconstruction difficult. After declassification, several images were scanned and digitally archived by the National Archive and USGS. The scanned images are available freely on USGS Earthexplorer, with approximate geolocation information (correct to 100s of m) provided as corner coordinates.

## Optical Bar Camera Model
- Optical bar "stereoscopic" cameras onboard the KH-9 mission consisted of 2 rotating cylinders which swept over the ground simultanoeusly giving 2 panaromic snapshots at different perspectives with an overlap of ~x%, swath of x... km. Once the films in the rolling cylinders were full, they were released to the Earth as capsules which were collected by the US Airforce. 
## Challenges and opportunities
- Even after declasification, several camera parameters (eg. scan rate ... ) which are crucial for accurate stereo reconstruction are not fully known. Also, these parameters are expected to change from mission to mission and even for same missions due to changing mechanical properties of the imaging assembly. These difficulties have largely prohibted the use of these images for stereoscopic and general purpose photogrammetric purposes. 
- In its current form and volume, these images sits as an untapped resoursce for historical earth observation and quantifying change detection. 

## Workflow
We have implemented a semi-automatic workflow to process the KH-9 stereoscopic images using the NASA Ames Stereopipeline (ASP). We initialise initial optical bar camera models and iteretively refine them using Bundle adjustment and 3D Coregistration to a reference DEM. The workflow is implemented without the need of manual Ground Control Points incorporation. The main steps are outlined below, with specific commands commented in the shell script (link:) and the ASP user manual.

- Image Preprocessing
  The images from 1 collect were scanned in parts of 2 to 4 owing to their large size (x * x) cm. We mosaic the sub images into 1 frames using tie-point matching in the adjacent overlapping parts and then crop the mosaiced image to remove the ancillary frame.
 - Camera initalisation
 Using the corner coordinates information provided by USGS, we initialise draft camera model for the images making up a stereo pair.  
 
 - Initial Stero and Geolocation Refinement:
 
 -----
 
 - Coarse Extrinsics optimization:
 
 -----
 - Intrinsics Optmization:

-----

 ## Software Requirements
- NASA AMES Stereo Pipeline
- to be added.

## Referemces/Links

## Workflow Development Team
- David Shean (UW) (Design and Technical Direction)
- Oleg Alexandrov, Scott McMichael (NASA AMES) (Software and Workflow Development, Prototyping)
- Shashank Bhushan (UW) (Prototyping and workflow implementation)

#TODO: Fill content, add images, add bash script wrapper.

