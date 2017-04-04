# FLIR-Temp-Retrieval-Analysis

Project that reads in imagery from a FLIR camera and retrieves accurate pixel temperature
The concept and original code was created by Saleem Ullah, and GUI was originally created by Samuel W. Fall.
This project's PI is Dar A. Roberts.

### Background:
This code was written for the IDEAS (Innovative Datasets for Environmental Analysis by Students) project
run by Dr. Dar Roberts in the University of California Santa Barbara Geography Department.
See http://geog.ucsb.edu/ideas/ for more information
As part of this project, students lay transects at our various field sites to take measurements that
relate to environmental variables. One of these measurements is taking a photo with an FLIR camera and 
using the resulting image to determine land surface temperature. This code corrects the imagery so that it retrieves accurate pixel temperatures based on appropriate emissivities.

### Dependencies/ Requirements:
This code was designed for a FLIR model T62101 or T450sc. It may work on other FLIR imagery, but needs to be tested. Developed on MATLAB 2015, but code has been updated to support MATLAB 2016.

### Steps:
#### STARTING PROGRAM:
1. Open MATLAB and naviagate to folder with the FLIR-Temp-Retrieval-Analysis source code. 
2. Open FLIR_Proj_gui.m into the MATLAB editor.
3. In the editor tab, hit Run which will result in a GUI appearing.

#### STEP 1: LOADING IMAGES:
1. Click the "Import Images" button in the Step 1: Import Data box. 
2. A dialog box will open where you can navigate to the location that contains the images you want to process. 3. Select the photo or photos that you want to load into the program. Once selected hit Open. The program will then load in the photos and display the names on the left.

#### STEP 2: EDIT EMISSIVITY VALUES AND DOWNWELLING RADIANCE:
1. The program will automatically load emissivity values for non-photosynthetic vegetatation (NPV), green vegetation (GV), and shade. If the user has measured their own emissivity values or would like to alter the emissivity, type in the values into the appropriate boxes. 
2. The program will also automotically load downwelling radiance value (DWR). This should be changed according to a radiometer reading at time of Image acquisition. This default value is for the Coal Oil Point Reserve site. Use caution if using in a different area. If using data from the Coal Oil Point Reserve get radiance from geog.ucsb.edu/ideas at time of image collection. Units for downwelling radiance is W/m^2.

#### STEP 3: DESIGNATE OUTPUTS:
1. The program will automatically output an image file and .csv file of the corrected temperature and exitance (corrected for downwelling radiance & fractional cover class emissivities). If you want the intermediate products, such as blackbody exitance image, click the text box next to that name. 
2. The products will be output with the following names:
	* Blackbody Exitance: originalfilename_BBExit.jpg and originalfilename_BBExit.csv
	* 0.95 Emissivity Exitance: originalfilename_95Exit.jpg and originalfilename_95Exit.csv
	* Blackbody Temperature: originalfilename_BBTemp.jpg and originalfilename_BBTemp.csv
	* 0.95 Emissivity Temperature: originalfilename_95Temp.jpg and originalfilename_95Temp.csv

#### STEP 4: RUN ANALYSIS:
1. Click "Step 4: Run Analysis" button to start going through your images 
2. The first part of the analysis is to classify the visible image using a pre-defined decision tree.This decision tree was built for the Coal Oil Point Reserve site. Use caution if using in a different area.
	a. A figure will pop up with the original visible image, classified image, and a colorbar. The colorbar includes the percentages for each of the classes present in the image. 
	b. The program will automatically save the classified image. An additional folder will be added to the directory containing the original folders titled "Classification". The image will be saved into this new Classification folder with the originalname_class.jpg. 
3. The second part of the analysis is to calculate the corrected temperature product. See Analysis Steps and Equations section for details on calculations.
	a. A figure will pop up with the original thermal image and the corrected temperature image. 
	b. The program will automatically save the corrected temperature and exitance images. An additional folder will be added to the directory containing the original folders titled "Temp_Correction". The image will be saved into this new Classification folder with the 4 files: originalfilename_Temp.jpg, originalfilename_Temp.csv, originalfilename_Exitance.jpg, and originalfilename_Exitance.csv. 
	c. Additional file will be saved to this folder if any of the additional outputs were selected in Step 3: Designate Outputs.
4. A dialog window will appear saying "Classify next image?". To move on to the next image, hit yes. If you are done, hit no. If you select no, and start the program over, it will reclassify and reanalyze the images listed.
5. After the program has looped through all the images, the last part of the analysis will output the classification results and the temperature correction results into two separate csv files.
	a. A dialog box will appear for the user to select the output and name for the classification results.  Click "Output to *.csv" button to output this current sessions classification results. The program will not output results from images that were classified outside of the matlab session. 
	b. A second dialog box will for the user to select the output and name for the temperature correction results.  Click "Output to *.csv" button to output this current sessions temperature correction results. The program will not output results from images that were run outside of the matlab session. 
4. When the saving is complete a dialog box will appear saying "Completed Processing."

#### Analysis Steps and Equations:
This section describes the calculations and steps that images undergo in this analysis
1. Pixel by pixel classification of visible image into green vegetation, non-photosynthetic vegetation, Shade, Blue and Yellow Flowers.
2. Calculate exitance from temperature image with an assumed emissivity of a blackbody. This is the thermal image output from the FLIR camera.
3. Calculate exitance after correcting down welling Radiance and assuming emissivity of 0.95.
4. Calculate temperature after correcting for downwelling radiance (DWR) and assuming emissivity 0.95
5. Calculate exitance using pixel based emissivity (assigned for pixel classification of cover type) and correcting for DWR 
6. Calculate temperature using pixel based emissivity (assigned for pixel classification of cover type) and  applying DWR corrections