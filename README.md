## Watch-n-Patch Data Processing

This repository contains the tools and feature extraction code described in the [CVPR 2015 Watch-n-Patch paper](http://watchnpatch.cs.cornell.edu/paper/watchnpatch_cvpr15.pdf).

The skeleton/ subdirectory mainly contains skeleton alignment and visualization codesfor Watch-n-Patch

The feature/ subdirectory mainly contains the superpixel feature extraction based on:

- Foreground mask detection: [OSTD](https://github.com/andrewssobral/ostd), 

- Edge detection and superpixel segmentation: [Structured Forests for Fast Edge Detection](Structured Forests for Fast Edge Detection)

- Modified version of [Kernel Descriptors](http://research.cs.washington.edu/istc/lfb/paper/nips10.pdf) for Watch-n-Patch
