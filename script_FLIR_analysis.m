%% FLIR Temp Retrieval Script
% This code uses the same process as the GUI, but does it as a batch script
% for easy processing of large number of files.
% Susan Meerdink
% 4/7/18
%% Set up images to be read

% Set directory that holds images for processing
dirImage = 'C:\Users\Susan\Dropbox\Field Work\Paul Gader Field work\COPR Field Work Data\FLIR Data (COPR Field Work)\Varied_Emissivity\';

% Set file that contains correction factors (aka longwave downwelling)
fileCor = strcat(dirImage, 'AllDates_Longwave_Downwelling_Radiance.csv');
corVal = readtable(fileCor,'Delimiter',','); % Skip the first row

% Set Emissivity
em_npv = [0.93, 0.94, 0.95];
em_gv  = [0.97, 0.98, 0.99];
em_s   = [0.99, 1];
em_list = [];
for i = 1:size(em_npv,2)
    for j = 1:size(em_gv,2)
        for k = 1:size(em_s,2)
            em_list = vertcat(em_list, [em_npv(i), em_gv(j), em_s(k)]);
        end
    end
end

% Get files to process
fileInfo = dir(strcat(dirImage, '*.jpg'));

% Set up variables for other processing
tempStats = zeros(size(fileInfo,1)*size(em_list,1), 21);
tempStatsName = {};
count = 1;

for img = 1: size(fileInfo,1) %loop through images
    
    % 0. Open File
    tempFile = irFileOpen(fileInfo(img).folder,fileInfo(img).name,'jpg','false'); %Opens each image
    
    % 1. Calculate Fractional Cover for RGB (Visible) Image
    if isfield(tempFile, 'overlayDefaultVisible') == 0 || isfield(tempFile, 'overlayDefaultThermal') == 0
        continue
    end
    I = tempFile.overlayDefaultVisible;  %This is were the images data is stored into I
    for j = 1:3 %loop through RGB bands and reshape
        RowS = I(:,:,j);
        all_rgb(:,j) = double(RowS(:));
    end
    ratioGR = all_rgb(:,2)./all_rgb(:,1); %Calculate
    sumRGB = sum(all_rgb,2);
    data = [all_rgb,ratioGR,sumRGB];
    
    versionTest = version('-release');
    load('treeUpdated.mat')
    if str2num(versionTest(1:4)) < 2016
        treeOut_x_0 = treeval(t0,data);
        %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead.
    else
        treeOut_x_0 = predict(tree,data);
    end
    
    R=all_rgb(:,1);
    G=all_rgb(:,2);
    B=all_rgb(:,3);
    treeOut_x_0(B > G + 40 & R > 160) = 4; %Blue Flowers
    treeOut_x_0(R./B > 1.8 & G./B > 1.8 & R + G > 400) = 5; %YELLOW FLOWERS
    fractions(img,:) = horzcat(img,hist(treeOut_x_0,1:5)/length(sumRGB));
    %Column Organization: index of fileInfo, Percentages of NPV, Shade, GV, Blue Flowers, Yellow Flowers    
    
    %Create Figure
    szImg = size(RowS);
    m = szImg(1);
    n = szImg(2);
    imgFrac = reshape(treeOut_x_0,m,n);
    
%     %Save Classification file
%     cflder = strcat(dirImage, 'Classification\');
%     if isdir(cflder)== 0 %If the directory doesn't exist make it
%         mkdir(cflder)
%     end
%     
%     % Save Fractional File
%     fname = strcat(cflder,fileInfo(img).name(1:end-4),'_Classification');
%     csvwrite(strcat(fname,'.csv'),imgFrac)
    
    % Step 2: Assigning emissivity values to classified image and Downwelling Radiance
    for i = 1:size(em_list,1)
        imgEmis = imgFrac;
        imgEmis(imgEmis == 1) = em_list(i,1); % Assigning emissivity values to class 'NPV'
        imgEmis(imgEmis == 2) = em_list(i,3); % Assigning emissivity values to class 'Shade'
        imgEmis(imgEmis == 3) = em_list(i,2); % Assigning emissivity values to class 'GV'
        imgEmis(imgEmis > 3) = 0.95; % Assigning emissivity value of 0.95 for Blue and Yellow Flowers
        sig = (5.670373*1e-08); % Stefen boltzmen constant
        
        % Step 2: Get correction factors from table
        ldw = corVal.LDW(find(strcmp(fileInfo(img).name(1:end-4), corVal.Filename)));
        
        % Step 3: Calculate Exitance of image (assuming blackbody aka emissivity of 1)
        % Code for Dar's Exitance Images and Intermediate Temperature Products
        imgTempUnCor = (tempFile.B./log(tempFile.R1./(tempFile.R2.*(tempFile.overlayDefaultThermal + tempFile.O))+tempFile.F));
        imgExitBB = (sig*((imgTempUnCor).^4)); % Exitance calculated from Temperature at BlackBody
        imgExit95Emiss = imgExitBB - ((1-0.95)*ldw); % Exitance calculated from Temperature at 0.95 Emissivity
        imgExitSurfEmiss = (imgExitBB -((1-imgEmis).*ldw)); % Retriving surface Exitance using pixel based emissivity and correcting for DWR
        imgTemp95Emiss = (imgExitBB/(sig*0.95)).^0.25; % Retriving surface temperature using 0.95 Emissivity
        imgTempSurfEmiss = (imgExitSurfEmiss./(imgEmis.*sig)).^0.25; % Surface Temperature using pixel based emissivity and applying DWR corrections
        
        %Get Temperature Stats
        tempStats(count,:) = [em_list(i,:), mean(mean(imgTempSurfEmiss)),min(min(imgTempSurfEmiss)),max(max(imgTempSurfEmiss)), ...
            mean(mean(imgExitBB)),min(min(imgExitBB)),max(max(imgExitBB)), ...
            mean(mean(imgExit95Emiss)),min(min(imgExit95Emiss)),max(max(imgExit95Emiss)), ...
            mean(mean(imgExitSurfEmiss)),min(min(imgExitSurfEmiss)),max(max(imgExitSurfEmiss)), ...
            mean(mean(imgTempUnCor)),min(min(imgTempUnCor)),max(max(imgTempUnCor)), ...
            mean(mean(imgTemp95Emiss)),min(min(imgTemp95Emiss)),max(max(imgTemp95Emiss))];
        tempStatsName(count) = {fileInfo(img).name};
        count = count + 1;
        
%         %Save Temperature file TO Temp Folder
%         cflder = strcat(dirImage, 'Temp_Correction\');
%         if isdir(cflder)== 0 %If the directory doesn't exist make it
%             mkdir(cflder)
%         end
%         
%         % Save Temperature File
%         npv = num2str(em_list(i,1));
%         gv  = num2str(em_list(i,2));
%         s   = num2str(em_list(i,3));
%         if size(s,2) > 1
%             s = s(3:end);
%         else
%             s = s(1);
%         end
%         fname = strcat(cflder,fileInfo(img).name(1:end-4),'_Temp_NPV',npv(3:end),'_GV',gv(3:end),'_S',s);
%         csvwrite(strcat(fname,'.csv'),imgTempSurfEmiss)
     end

end

%Output Classification Results
outputFile = strcat(dirImage, 'fractional_cover_stats_',datestr(now,'ddmmmyy'),'.csv');
fid = fopen(outputFile,'w');
fprintf(fid,'Filename,NPV,Shade,GV,Flower Blue, Flower Yellow\n');
for i = 1:size(fileInfo,1)
    fprintf(fid,'%s%s',char(fileInfo(i).name),',');
    fprintf(fid,'%f,%f,%f,%f,%f,',fractions(i,(2:6))); %Classification Values (5 vals, cell 5)
    fprintf(fid,'\n');
end
fclose(fid);

%Output Temperature Results
outputFile = strcat(dirImage,'temperature_correction_stats_',datestr(now,'ddmmmyy'),'.csv');
fid = fopen(outputFile,'w');
fprintf(fid,['Filename, NPV, GV, Shade, Avg Temperature for Corrected Image, Min Temperature for Corrected Image, Max Temperature for Corrected Image,' ...
    'Avg Exitance for BB, Min Exitance for BB, Max Exitance for BB,' ...
    'Avg Exitance for 0.95 Emissivity, Min Exitance for 0.95 Emissivity, Max Exitance for 0.95 Emissivity,' ...
    'Avg Exitance for Class Emissivity, Min Exitance for Class Emissivity, Max Exitance for Class Emissivity,' ...
    'Avg Temperature for BB, Min Temperature for BB, Max Temperature for BB,'...
    'Avg Temperature for 0.95 Emissivity, Min Temperature for 0.95 Emissivity, Max Temperature for 0.95 Emissivity \n']);
for i = 1:size(tempStatsName,2)
    fprintf(fid,'%s%s',char(tempStatsName(i)),',');
    fprintf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f',tempStats(i,:));
    fprintf(fid,'\n');
end
fclose(fid);
