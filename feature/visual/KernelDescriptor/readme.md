## Kernel Descriptor Extraction

This kernel descriptor implementation is mainly based on the [kdes](https://rse-lab.cs.washington.edu/projects/kdes/)(link down) released.

To generate kernel descriptors, run **seg_kernel/extract_kpca_fea.m** with different kdes names.

To generate your visual words, first config the subsampling parameters in **gen_intermediate/config.m** and generate the intermediate results for visual words clustering.

Select your specific visual words dimension by modifying **seg_kernel/config.m**