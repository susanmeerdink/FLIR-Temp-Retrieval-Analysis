%******Calculating Accurate temp and Exitance******
% Written by Saleem Ullah, Date April 02, 2015
unCorTem=temp_sub;% Raw temperature image.
emiss=emiss; % emissivity image

sig=(5.670373*1e-08); % Stefen boltzmen constant

%dwr=292.52; % Down welling radiance. It should be change according to the Radiometer reading at time of Image aquizition

%% Uncorrected temperature and calculate the Scene average
f1=figure (1)
subplot(1,2,1)
imshow(temp_sub,[]);
colormap 'hot'
h=colorbar;
title('Thermal Image without any correction (E=1)','fontsize',14);
subplot(1,2,2)
imshow(fileInfo.overlayDefaultVisible,[]);
title('Visible Image')
Avg_unCorTem=mean(mean(unCorTem)); %Scene average temperature assuming BB

%% Exitance calculated from Temperature at BlactBody
Exit_at_BB = (sig*((unCorTem).^4)); % Calculating Exitance at Balack Body(BB)

%writing Exitance Images
f2=figure(2)
imshow(Exit_at_BB,[]);
title('Exitance Image without any correction(Assuming BB)', 'fontsize',12')
colormap 'hot'
h=colorbar;
% Scene Temperature calculated from average Exitance at BB 
Avg_Exit_at_BB =mean(mean(Exit_at_BB)); %Scene average Exitance at BB
Scene_temp_calcul_from_Avg_exit_at_BB=((Avg_Exit_at_BB)/sig)^0.25; % calculate scene temperature from Avg_exitance

%% Exitance after correcting down welling Radiance and assuming emissivity of 0.95.

Surf_exit=Exit_at_BB-((1-0.95)*dwr); % the 'DWR' may be varing with time of day and with atmospheric condition.  
Avg_Surf_exit=mean(mean(Surf_exit));
Scene_temp_calcul_from_Avg_Surf_exit=(Avg_Surf_exit/(sig*0.95))^0.25;
f3=figure(3)
subplot(1,2,1)
imshow(Surf_exit,[])
colormap 'hot'
h=colorbar;
title('Exitance at Surface, corrected for L_D_W_R(emissivity=0.95)', 'fontsize',12)
%% Temperature after corecting for DWR and assuming emissivity 0.95
Temp_calcul_from_Surf_exit=(Surf_exit/(sig*0.95)).^0.25;
Scene_temp_at_Emiss_95=mean(mean(Temp_calcul_from_Surf_exit));
f3=figure(3)
subplot(1,2,2)
imshow(Temp_calcul_from_Surf_exit,[])
colormap 'hot'
h=colorbar;
title('Surface Temperature , corrected for L_D_W_R(emissivity=0.95)', 'fontsize',12)

%% Retriving surface Exitance using pixel based emissivity and correcting for DWR 
Scene_emiss=mean(mean(emiss)); % average (scene) emissivity
Surf_exit_using_class_emiss=(Exit_at_BB -((1-emiss).*dwr));
f4=figure(4)
imshow(Surf_exit_using_class_emiss,[])
title('Exitance at Surface corrected for L_D_W_R(emissivity=NPV,GV,SOIL)', 'fontsize',12)
colormap 'hot'
h=colorbar;
Avg_Surf_exit_using_class_emiss=mean(mean(Surf_exit_using_class_emiss));
Scene_emiss=mean(mean(emiss));
Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss=(Avg_Surf_exit_using_class_emiss/(Scene_emiss*sig))^0.25;


%% Surface Temperature using pixel based emissivity and  applying DWR corrections
Surf_temp_using_class_emiss=(Surf_exit_using_class_emiss./(emiss.*sig)).^0.25;
Avg_Surf_temp_using_class_emiss=mean(mean(Surf_temp_using_class_emiss));
f5=figure(5);
imshow(Surf_temp_using_class_emiss,[])
title('Temperature at Surface corrected for L_D_W_R(emissivity=NPV,GV,SOIL)', 'fontsize',12)
colormap 'hot'
h=colorbar;
