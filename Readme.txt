=========== Setup: ===========

Installation steps:

1) Download
2) Add the path where this Readme-file is located to Matlab's search path, e.g. via addpath.m
3) Execute OmicsInit.m



=========== Folders: ===========
@OmicsData	     The class functions which might overload other matlab functions, function which necessarily have to access properties via "." instead of get.
Advanced	     Advanced analyses which are not of primary interest for routine analyes
Data		     Data sets, put your data-library here. The github repository does not contain data due to publication issues.
Development	     Functions which are not fully finished or require extensions
MatlabTools	     Matlab functions which are general and not directly linked to the OmicsData project
Subfunctions	     Functions which are usually not called by the user but implement recurrent task called by partent functions
Tools		     Non-Matlab software tools 
user		     This folder is for placing custom own functions which are not intended to be synchronized via github. 
		     The folder, however, automatically added on OmicsInit.m



=========== Programming guidelines: ===========

Description of the fields of the @OmicsData Object:
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


Try to provide error messages which explains the problem and hints a most likeli solution.

Try to stick to previously chosen way of naming, abbreviations, upper/lower cases, ...

Use get and set instead of directly accessing the fields whenever possible.








