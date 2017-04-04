%****************Assigning emissivity values to classified image*************
% This script read the output of "gui_image_intro_batch_flir" and 
% assign emissivities to each pixel of different classes
% date April 01, 2015; Written by Saleem Ullah; Version 01****
em=yout;
em(em==1)=0.94; % Assigning emissivity values to class 'NPV'
em(em==2)=1.00; % Assigning emissivity values to class 'Shade'
em(em==3)=0.98; % Assigning emissivity values to class 'GV'
emiss=em;

                            
%*******************************end******************************