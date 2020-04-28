# OmicsData
Matlab library of methods for analyzing high-throughput data

## Installation
- Clone or download this repository
- Add the repository file path to your Matlab search path (e.g. by addpath.m)

## Some examples

To demonstrate the @OmicsData toolbox, here we give some processing, analysis and plotting examples:
![OmicsIntro](https://user-images.githubusercontent.com/30629788/80489042-90a74080-895f-11ea-82fa-f55a45ce31e4.PNG)

Furthermore, some methods published from our group can be applied via:
![OmicsAdvanced](https://user-images.githubusercontent.com/30629788/80489069-9b61d580-895f-11ea-8ca1-4a76f3a20c64.PNG)

## Description of the fields in the @OmicsData object

O.analyses     cell	  Each function changing the data should add a new cell item briefly explaining the step
O.cols	       struct	  This struct contains all data and annotation which are the same for all samples, i.e. has dimension (nfeatures x 1)
			  These columns might be used as row-names or feature-annotations.
O.config       struct	  Configuration parameters
O.container    struct	  This struct contains all other information which does not fit to data.data or data.rows or data.columns.
O.data	       struct	  This struct contains all data and annotation which are different for each feature and sample, i.e. has dimension (nfeatures x nsamples)
O.data.data    the default primary data used as default in plots and analyses
O.date	       char
O.rows	       struct	This struct contains all data and annotation which are the same for all features, i.e. has dimension (1 x nsamples). 
			These rows might be used as column-names or sample-annotations.
O.name	       char	The name of an instance, usually provided when the object (instance) is created.
O.ID	       char	A unique identifier which should be altered if the data changes. Can be used to check/compare @OmicsData instances.

## GitHub folders
@OmicsData	     The class functions which might overload other matlab functions, function which necessarily have to access properties via "." instead of get.
Advanced	     Advanced analyses which are not of primary interest for routine analyes
Data		     Data sets, put your data-library here. The github repository does not contain data due to publication issues.
Development	     Functions which are not fully finished or require extensions
Documentation	     Files for explaining the code or for demonstrating its usage.
Examples	     Code for demonstrating example analyses
MatlabTools	     Matlab functions which are general and not directly linked to the OmicsData project
Plot		     Functions for plotting purpose.
Rfunctions	     Basic Matlab inferface functions enabling functionality/usage of R functions or packages and do NOT require @OmicsData class objects.
Subfunctions	     Functions which are usually not called by the user but implement recurrent task called by partent functions
Tools		     Non-Matlab software tools 
user		     This folder is for placing custom own functions which are not intended to be synchronized via github. 

