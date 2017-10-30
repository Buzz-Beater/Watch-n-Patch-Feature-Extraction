## Align skeleton for each class for Watch-n-Patch
####1. Function purpose
- body2matrix.m (Helper Function) : pass in the body struct given in body.mat in WnP dataset, return the skeleton matrix M (frame_cnt * joint_cnt * 3d)

- getAlignedSkeletonsWNP.m : the main process logic script, please modify the 'root' variable in this file to the root directory of your dataset (e.g. If your office data is in '/a/b/c/office', then change root to 'root' to be '/a/b/c')
  - action_index (1 * 59) : the merged index2string list of office class label and kitchen class label, first 43 strings are for office class, the rest are for kitchen class. Returned from <font color="#ff0000">getSkeleton</font>. 
  - skeleton_mat :
- getSkeleton.m

####2. Setup: clone or download the codes in /kinect directory
####
