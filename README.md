# FLIR-Temp-Retrieval-Analysis

Project that reads in imagery from a FLIR camera and retrieves accurate pixel temperature based on various correction factors including camera height, relative humidity, upwelling longwave radation, and air temperature.
The concept and original code was created by Donald M. Aubrecht, Saleem Ullah, and GUI was originally created by Samuel W. Fall.
This project's PI is Dar A. Roberts.

### Background:
This code was written for the IDEAS (Innovative Datasets for Environmental Analysis by Students) project run by Dr. Dar Roberts in the University of California Santa Barbara Geography Department.
See http://geog.ucsb.edu/ideas/ for more information.
As part of this project, students lay transects at our various field sites to take measurements that relate to environmental variables. One of these measurements is taking a photo with an FLIR camera and using the resulting image to determine land surface temperature. This code corrects the imagery so that it retrieves accurate pixel temperatures based on appropriate emissivities and other correction factors.

### Dependencies/ Requirements:
This code was designed for a FLIR model T450sc (T62101). It may work on other FLIR imagery, but needs to be tested. Developed on MATLAB 2015, but code has been updated to support MATLAB 2016.

### Steps:
#### STARTING PROGRAM:
1. Open MATLAB and naviagate to folder with the FLIR-Temp-Retrieval-Analysis source code. 
2. Open gui_FLIR_analysis.m into the MATLAB editor.
3. In the editor tab, hit Run which will result in a GUI appearing.

#### STEP 1: LOADING IMAGES:
1. Click the "Load Images" button in the Step 1: Load Images. 
2. A dialog box will open where you can navigate to the location that contains the thermal fusion images you want to process. 
3. Select the photo or photos that you want to load into the program. Once selected hit Open. The program will then load in the photos and display the names on the left. It can take a while to load the images.

#### STEP 2: LOAD CORRECTION FACTORS:
1. Create a .csv file that contains correction factors. The format of the csv file follows (see example correction_factor_example.csv):
	* Header: The first row should contains the column names: Filename, Downwelling Longwave.
	* First Column: Filename of images must match the images that you load. Optional: You do not have to add .jpg, but you can add it to the filename. 
	* Fourth Column: Downwelling Longwave Radiation (Can be obtained from the IDEAS meterological station (geog.ucsb.edu/ideas) which updates every 15 minutes.)
2. Click the "Step2: Load Correction Factors" button. A dialog box will open where you can navigate to the location that contains the .csv file that contains the correction factors.  
3. The values will populate the table in the gui. You can edit or type in correction factors into the gui. 

#### STEP 3: EDIT EMISSIVITY VALUES:
1. The program will automatically load emissivity values for non-photosynthetic vegetatation (NPV), green vegetation (GV), and shade. If the user has measured their own emissivity values or would like to alter the emissivity, type in the values into the appropriate boxes. 

#### STEP 4: DESIGNATE OUTPUTS:
1. The program will automatically output an image file and .csv file of the corrected temperature (which can be corrected for longwave upwelling radiance, pixel class emissivities, relative humidity, and camera height). If you want the intermediate products, such as blackbody exitance image, click the text box next to that name. 
2. The products will be output with the following names:
	* Blackbody Exitance: originalfilename_BBExit.jpg and originalfilename_BBExit.csv
	* 0.95 Emissivity Exitance: originalfilename_95Exit.jpg and originalfilename_95Exit.csv
	* Blackbody Temperature: originalfilename_BBTemp.jpg and originalfilename_BBTemp.csv
	* 0.95 Emissivity Temperature: originalfilename_95Temp.jpg and originalfilename_95Temp.csv

#### STEP 5: RUN ANALYSIS:
1. Click "Step 5: Run Analysis" button to start going through your images 
2. The first part of the analysis is to classify the visible image using a pre-defined decision tree.This decision tree was built for the Coal Oil Point Reserve site. Use caution if using in a different area.
	1. A figure will pop up with the original visible image, classified image, and a colorbar. The colorbar includes the percentages for each of the classes present in the image. 
	2. The program will automatically save two classified images. An additional folder will be added to the directory containing the original folders titled "Classification" and the images will be saved in this new folder. The first image is the classified image and will be saved as originalname_class.jpg. The second image is from gui figure that includes the cropped image, classified image, and fractional results. This image will be saved as originalname_class_fractions.jpg.
3. The second part of the analysis is to calculate the corrected temperature product. See Analysis Steps and Equations section for details on calculations.
	1. A figure will pop up with the original thermal image and the corrected temperature image. 
	2. The program will automatically save the corrected temperature and exitance images. An additional folder will be added to the directory containing the original folders titled "Temp_Correction". The image will be saved into this new Classification folder with the 4 files: originalfilename_Temp.jpg, originalfilename_Temp.csv, originalfilename_Exitance.jpg, and originalfilename_Exitance.csv
	3. Additional file will be saved to this folder if any of the additional outputs were selected in Step 4: Designate Outputs.
4. A dialog window will appear saying "Classify next image?". To move on to the next image, hit yes. If you are done, hit no. If you select no, and start the program over, it will reclassify and reanalyze the images listed.
5. After the program has looped through all the images, the last part of the analysis will output the classification results and the temperature correction results into two separate csv files.
	1. A dialog box will appear for the user to select the output and name for the classification results.  Click "Output to *.csv" button to output this current sessions classification results. The program will not output results from images that were classified outside of the matlab session. 
	2. A second dialog box will for the user to select the output and name for the temperature correction results.  Click "Output to *.csv" button to output this current sessions temperature correction results. The program will not output results from images that were run outside of the matlab session. 
4. When the saving is complete a dialog box will appear saying "Completed Processing."

#### RESET & START OVER
1. When done running the images, the 'Reset & Start Over' button will clear the workspace and gui so that the user can load new images and correction factors.