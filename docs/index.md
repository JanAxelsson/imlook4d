imlook4d
========

Introduction
------------

Imlook4d started as a viewer for 4-dimensional viewer for medical PET, CT, MRI
images, but has for more than a decade evolved to include tools typically not
available. The most important feature is the easy method to extend functionality
by adding a single matlab script into a folder (resulting in it becoming an
integrated menu in imlook4d).  

![](Imlook4d_PET_MRI_screenshot.png)

*Figure: imlook4d PET/MRI with applied temporal Hotelling filter*

Install
-------

Easy method:  Download from the imlook4d web site
([https://sites.google.com/site/imlook4d](https://sites.google.com/site/imlook4d))



Features
--------

The program is developed in Matlab and works on all platforms

Some features of imlook4d:

-   Full 4D Viewer.  

-   VOI analysis, using brush tool (easier than polygons), and thresholded brushing.
    
-   PET pharmaco-kinetic modelling (9 models, both on ROIs and parametric images)

-   DICOM, Nifti, Analyze, ECAT (very fast compared to Matlabs routines), and
    reads binary, interfile

-   Handles time-information in DICOM-converted Niftis, and reads PMOD-Nifti format.

-   Export/Import to Matlab, gives full access to data in Matlab workspace

-   Drop-in SCRIPTS (written in Matlab)  makes it easy to add matlab code to imlook4d menues

-   Some 70 useful scripts for Matrix and ROI processing

-   Integrated with SPM (align, co-register, fit to atlas, ...)

-   Integrated with ImageJ (move data back and forth between imlook4d and ImageJ)

-   Interactive help, click on the GUI or menu, and a detailed help opens


**Requirements:** Windows, Linux or MacOS, and Matlab with no extra toolboxes.  A few features are nicer with imaging toolbox
