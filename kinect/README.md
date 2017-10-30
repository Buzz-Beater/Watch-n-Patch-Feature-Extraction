## Align skeleton for each class for Watch-n-Patch
#### 1. Function purpose
- *body2matrix.m* (Helper Function) : pass in the body struct given in body.mat in WnP dataset, return the skeleton matrix M (frame_cnt * joint_cnt * 3d)

- *getAlignedSkeletonsWNP.m* : the main process logic script, please modify the 'root' variable in this file to the root directory of your dataset (e.g. If your office data is in '/a/b/c/office', then change root to 'root' to be '/a/b/c'), for the variables generated, please check the return value discussed below.

- *getSkeleton.m* : pass in the root directory (please make sure the directory for the datasets are not modified, i.e. kitchen1 and kitchen2 are separated), and return *action_index* and *skeleton_mat*
  - *action_index* (1 * 59) : the merged index2string list of office class label and kitchen class label, first 43 strings are for office class, the rest are for kitchen class. Returned from <font color=#ff0000>*getSkeleton*</font>.
  - *skeleton_mat* : the reformated skeleton cell array. Returned from *getSkeleton*, it's structure is as follows

    - skeleton_mat          (1 * dir_num cell)
    - skeleton_mat{dir} (1 * frame_num cell)
    - skeleton_mat{dir}{frame} (1 * 3 cell)
    - skeleton_mat{dir}{frame}{i}
      - person_id (1 ~ 6)
      - joints (the raw joints for the skeleton given in WnP)
      - action_label (the action_label for this skeleton)
  - *dir_map* : the list of merged directories (1 * 458), from dir_idx, we can retrieve the correct data path.
- *getAnchorSkeleton.m* : pass in the *skeleton_mat* and *action_index* returned from *getSkeleton* and return *action2anchor* and *action2skeleton*
  - *action2skeleton* structure
    - action2skeleton (1 * action_label_num cell)
    - action2skeleton{act} (1 * skeleton_num cell)
    - action2skeleton{act}{ske} (1 * 3 cell)
      - joints raw_joints
      - frame_id
      - dir_id

  - *action2anchor* the anchor points for each action class
    - action2anchor (1 * action_label_num cell)
    - action2anchor{act} (3 * anchor_num matrix)

- **getAnchor.m** : pass in the indices of anchor points and the raw skeleton data, return the anchor point matrix
  - **anchor_point** (3 * anchor_num) anchor point matrix
  - **anchor_mask** mark if some of the anchor points are missing (currently deprecated)

- **getAlignedSkeleton.m** : pass in **action2anchor**, **action2skeleton** and **dir_map**. For each action class, align all skeletons under this class according to anchor point coordinates
  - **action2aligned** Map of action to aligned skeletons
    - action2aligned (1 * action_label_num cell)
    - action2aligned{act} (1 * skeleton_num cell)
    - action2aligned{act}{ske} (3 * 25 joints matrix)
  - if unable to align, will plot estimated coordinates in figure
- **getMeanSkeleton.m** : return the mean skeleton for each action class.
  - **action2mean** (1 * action_label_num cell), each element is (3 * 25) joint matrix

#### 2. Setup: clone or download the codes in /kinect directory
