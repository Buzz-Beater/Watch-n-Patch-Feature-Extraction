### Feature Extraction for Watch-n-Patch

To run the code, use extractFeatureWNP.m

Notices:

- The main extraction code is in different subdirectories naming with prefix *extract*. Before using, make sure to use the correct file path for different feature extraction. The file path can be modified through *extractFeatureWNP.m*, which pass in the root directory of the Watch-n-Patch dataset.

- Before running the superpixel kernel descriptors for selected pixels, we need to first use *extract_kpca_fea.m* in *visual/KernelDescriptor/seg_kernel* to generate the kernel descriptors for all segmentations first. Before generating kernel descriptors, make sure the superpixel segmentation results are generated. To change the visual words type, please check *config.m* under each directories.
	
	- For the space complexity issues, we stored the segmentation result (threshold: 0.05) instead of ucm for rgbjpg images, so you might need to change the *extractSuperpixel.m* in *visual/superpixel/* to save with the right format.