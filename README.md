# Docker files for building Python cv2 (opencv) for UNRAID
# This is WIP and currently targets building with Nvidia CUDA + cuDNN

The linuxserverio provides the ability to expose Nvidia GPU resources
on the UNRAID server. Docker has recently been updates to support
enabling this runtime to docker containers such as plex and emby.
With recent improvements in Zoneminder's Event Server to use
opencv for object detection, there is the desire to leverage the 
GPU to accelerate object detection. The files contained herein are 
a firt attempt at building the Python opencv/cv2 package for UNRAID.

**NOTE:** This is currently work in progress. Testing is being done
with a Quadra M4000 with a Nvidia CC of 5.2. This requires using a
pre-release of opencv that has enabled support of older GPUS with 
a CC of 3.0 or greater.

There may be references to local files that are not available in this
git repo. Again this is a work in progress.
