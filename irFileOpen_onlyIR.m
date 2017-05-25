function [fileInfo] = irFileOpen(analysisDir,name,fType,savedat)
%IRFILEOPEN Reads files produced by infrared cameras. Acceptable file types
%   are *.SEQ, *.FFF, and radiometric *.JPG.  This code should be OS
%   independent. ANALYSISDIR is the full path to the directory containing
%   the infrared image and is allowed to contain spaces. The path must not
%   end with a '/' or '\'. NAME is the full file name of the image to be 
%   opened. FTYPE is the infrared image type, either 'seq', 'fff', or 'jpg'.
%   SAVEDAT is a logical value that indicates whether or not to save the
%   image pixel raw integer counts from the infrared sensor to a CSV
%   name.data file. FILEINFO is a structure containing the image name,
%   pixel integer data, and all radiometric information contained in the
%   infrared image header.  If the NAME is for a radiometric  JPG, FILEINFO
%   will NOT contain the visible image stored in the file (only for image
%   NOT thermal fusion mode).
%
%   Example:
%       aDir = '/Users/usr1/Documents';
%       fn = 'Rec-test-000001-103_12_15_02_153.seq';
%       ft = 'seq';
%       sDAT = false;
%       info = irFileOpen(eDir,aDir,fn,ft,sDAT);
%
% ------------------------------------------------------------------------
%   Written by Donald M. Aubrecht
%   version 7
%   3 September 2014
%
%   Notes
%       v1 (13 March 2014)
%           - compatible with ExifTool v9.45
%       v2 (13 March 2014)
%           - compatible with ExifTool v9.54
%           - added capability to read atmospheric correction constants
%       v3 (30 April 2014)
%           - replaced calls to ExifTool with direct read of file header to
%           get image coefficients and atmospheric constants
%           - replaced calls to ExifTool for reading raw data from
%           radiometric JPG images; now read raw data directly from JPG
%           file (currently only tested with 240x320 image from T450sc)
%       v4 (8 July 2014)
%           - added capability to read FFF images
%       v5 (21 August 2014)
%           - streamlined reading radiometric JPG images to enable
%           registration of vis/therm data for PIP images
%           - ensure all varieties of radiometric JPG images can be opened
%       v6 (28 August 2014)
%           - updated code for FFF images to make sure first image in
%           series could be opened since extra information is appended to
%           first image in recording series
%       v7 (3 September 2014)
%           - update to improve how PNG images stored in radiometric JPGs
%           are "found"
% ------------------------------------------------------------------------


% radiometric constants
h = 6.62606957e-34; % Planck's constant
kB = 1.3806488e-23; % Boltzman's constant
c = 299792458; % speed of light


% set filename
fname = strcat(analysisDir,filesep,name);
fnameOut = strcat(analysisDir,filesep,'output',filesep,name(1:end-3),'data');


% read information from file header
fileInfo = readIRheader(fname);
if isfield(fileInfo,'width')
    width = fileInfo.width;
end
if isfield(fileInfo,'height')
    height = fileInfo.height;
end


% open the thermal file and output array of raw value integers
if strcmp(fType,'seq') % for .seq files
    
    fid = fopen(fname, 'r'); % open the file
    dataA = fread(fid); % read it in as a long string of bytes.
    fclose(fid); % close the file
    
    % Determine where the image data begins (accounts for varying size and
    % location of file headers)
    dataStartIndicator = fileInfo.magicSeq;
    dataStartIdx = findstr(dataStartIndicator.',dataA.');
    fileInfo = rmfield(fileInfo,'magicSeq');
    
    % Determine which index is for the data
    if (numel(dataA)-dataStartIdx(2)) > width*height*2 % data is stored at end of file
        dataA1 = dataA(dataStartIdx(2)+32:dataStartIdx(2)+32+(width*height*2)-1); % grab all image data
        dataB = reshape(dataA1, width*2,height); % each pixel has 2 bytes, so the image will be twice as tall
        dataB1 = dataB(1:2:end,:); % grab all the odd rows
        dataB2 = dataB(2:2:end,:); % grab all the even rows
        dataC = dataB1 + 256*dataB2; % generate array of 16-bit integer values
        integerImg = dataC'; % transpose arry to get normal image
    else % data is stored in the middle of the file, with header information appended to the end
        dataA1 = dataA(dataStartIdx(1)+32:dataStartIdx(1)+32+(width*height*2)-1); % grab all image data
        dataB = reshape(dataA1, width*2,height); % each pixel has 2 bytes, so the image will be twice as tall
        dataB1 = dataB(1:2:end,:); % grab all the odd rows
        dataB2 = dataB(2:2:end,:); % grab all the even rows
        dataC = dataB1 + 256*dataB2; % generate array of 16-bit integer values
        integerImg = dataC'; % transpose arry to get normal image
    end
    clear headerStartIndicator headerStartIdx
    
elseif strcmp(fType,'fff') % for .fff files
    
    fid = fopen(fname, 'r'); % open the file
    dataA = fread(fid); % read it in as a long string of bytes.
    fclose(fid); % close the file
    
    % Determine where the image data begins (accounts for varying size and
    % location of file headers)
    dataStartIndicator = fileInfo.magicSeq;
    dataStartIdx = findstr(dataStartIndicator.',dataA.');
    fileInfo = rmfield(fileInfo,'magicSeq');
    
    % Determine which index is for the data
    if (numel(dataA)-dataStartIdx(2)) > width*height*2 % data is stored at end of file
        dataA1 = dataA(dataStartIdx(2)+32:dataStartIdx(2)+32+(width*height*2)-1); % grab all image data
        dataB = reshape(dataA1, width*2,height); % each pixel has 2 bytes, so the image will be twice as tall
        dataB1 = dataB(1:2:end,:); % grab all the odd rows
        dataB2 = dataB(2:2:end,:); % grab all the even rows
        dataC = dataB1 + 256*dataB2; % generate array of 16-bit integer values
        integerImg = dataC'; % transpose arry to get normal image
    else % data is stored in the middle of the file, with header information appended to the end
        dataA1 = dataA(dataStartIdx(1)+32:dataStartIdx(1)+32+(width*height*2)-1); % grab all image data
        dataB = reshape(dataA1, width*2,height); % each pixel has 2 bytes, so the image will be twice as tall
        dataB1 = dataB(1:2:end,:); % grab all the odd rows
        dataB2 = dataB(2:2:end,:); % grab all the even rows
        dataC = dataB1 + 256*dataB2; % generate array of 16-bit integer values
        integerImg = dataC'; % transpose arry to get normal image
    end
    clear headerStartIndicator headerStartIdx
    

    
elseif strcmp(fType,'jpg') % for radiometric .jpg files
    
    if strcmp(fileInfo.thermalFormat,'RAW') % image containing just radiometric data
        
        fid = fopen(fname, 'r'); % open the file
        dataA = fread(fid); % read it in as a long string of bytes.
        fclose(fid); % close the file
        
        allChar = char(dataA); % convert interger values to ASCII
        dataStart = findstr('FFF',allChar.'); % find beginning of data
        offset = dataStart(1) + 3860; % set correct offset from begininning of radiometric data
        clear dataChar dataStart
        
        gapLocations = strfind(dataA.',[70 76 73 82]); % find locations where 'FLIR' is inserted into data
        gapLocations(gapLocations < offset) = []; % get rid of locations found in the header
        remainingBytes = width*height*2 - (gapLocations(1)-5-offset+1) - (gapLocations(2)-5-(gapLocations(1)+8)+1); % calculate bytes remaining after last interruption location
        dataA1 = [dataA(offset:gapLocations(1)-5).' dataA(gapLocations(1)+8:gapLocations(2)-5).' dataA(gapLocations(2)+8:gapLocations(2)+8+remainingBytes-1).'].'; % get data
        dataB = reshape(dataA1, width*2,height); % each pixel has 2 bytes, so the image will be twice as tall
        dataB1 = dataB(1:2:end,:); % grab all the odd rows
        dataB2 = dataB(2:2:end,:); % grab all the even rows
        dataC = dataB1 + 256*dataB2; % generate array of 16-bit integer values
        integerImg = dataC'; % transpose arry to get normal image
        
    elseif strcmp(fileInfo.thermalFormat,'JPG') % image containing only visible data
        
        fid = fopen(fname,'r'); % open the file
        allData = fread(fid); % read it in as a long string of bytes
        fclose(fid); % close the file
        
        allChar = char(allData); % convert interger values to ASCII
        jpgChar = ['J';'F';'I';'F'];
        jpgStart = findstr(jpgChar.',allChar.'); % find beginning of JPG files
        jpgEnd = findstr(char([255; 217]).',allChar.'); % find end of files
        flirPatternChar = char([70;76;73;82]);
        
        startLoc = jpgStart(2)-6; % find beginning of JPG file
        eofLoc = find((jpgEnd > startLoc) & ((jpgEnd - startLoc) > 5000),1); % find end of file
        stopLoc = jpgEnd(eofLoc)+1;
        
        vis = allData(startLoc:stopLoc);
        visChar = char(vis);
        idx = findstr(flirPatternChar.',visChar.'); % find locations where 'FLIR' is inserted into data and eliminate
        idx(idx < 5000) = [];
        for ii=numel(idx):-1:1
            vis(idx(ii)-4:idx(ii)+7) = [];
        end
        clear visChar idx
        
    elseif strcmp(fileInfo.thermalFormat,'PNG') % image containing both radiometric and visible data
        
        fid = fopen(fname,'r'); % open the file
        allData = fread(fid); % read it in as a long string of bytes
        fclose(fid); % close the file
        
        allChar = char(allData); % convert interger values to ASCII
        pngStart = [0;0;137;80;78;71]; % indicates beginning of PNG file
        hdrChar = ['I';'H';'D';'R'];
        endChar = ['I';'E';'N';'D'];
        idxStart = findstr(pngStart.',allData.')+2;
        idxHdr = findstr(hdrChar.',allChar.');
        idxEnd = findstr(endChar.',allChar.')+7;
        
        flirPattern = [70;76;73;82]; 
        flirPatternChar = char(flirPattern);
        for ii = 1:numel(idxStart)
            
            if ii == 1 % thermal image stored first
                therm = allData(idxStart(ii):idxEnd(ii));
                thermChar = char(therm);
                idx = findstr(flirPatternChar.',thermChar.'); % find locations where 'FLIR' is inserted into data and eliminate
                for ii = numel(idx):-1:1
                    therm(idx(ii)-4:idx(ii)+7) = [];
                end
                clear thermChar idx
                
                fid = fopen('temporaryTherm.png','w'); % write thermal PNG to temporary file
                fwrite(fid,therm);
                fclose(fid);
                clear therm
                
                therm = imread('temporaryTherm.png'); % read in temporary file and then delete file
                if ispc
                    fullFileName = strcat('"',pwd,'\temporaryTherm.png"');
                    system(horzcat('DEL ',fullFileName));
                elseif isunix
                    fullFileName = strcat(pwd,'/temporaryTherm.png');
                    fullFileName = unixFN(fullFileName);
                    system(horzcat('rm ',fullFileName));
                end
                pause(0.0001); % let system catch up with itself
                
                thermBin = dec2bin(therm); % convert each pixel value to binary string
                t1 = thermBin(:,1:8); t2 = thermBin(:,9:16); % values were written as LSB by camera but written as MSB by Matlab, so need to rearrange bytes
                integerImg = reshape(bin2dec([t2 t1]),fileInfo.height,fileInfo.width); % create thermal image
                clear fullFileName therm thermBin t1 t2
                
            elseif ii == 2 % visible image stored second
                
                vis = allData(idxStart(ii):idxEnd(ii));
                visChar = char(vis);
                idx = findstr(flirPatternChar.',visChar.'); % find locations where 'FLIR' is inserted into data and eliminate
                for ii=numel(idx):-1:1
                    vis(idx(ii)-4:idx(ii)+7) = [];
                end
                clear visChar idx
                
                fid = fopen('temporaryVis.png','w'); % write visible PNG to temporary file
                fwrite(fid,vis);
                fclose(fid);
                clear vis
                
                vis = imread('temporaryVis.png'); % read in temporary file and then delete file
                if ispc
                    fullFileName = strcat('"',pwd,'\temporaryVis.png"');
                    system(horzcat('DEL ',fullFileName));
                elseif isunix
                    fullFileName = strcat(pwd,'/temporaryVis.png');
                    fullFileName = unixFN(fullFileName);
                    system(horzcat('rm ',fullFileName));
                end
                pause(0.0001);% let system catch up with itself
                
                fileInfo.visImage = ycbcr2rgb(vis); % store visible image
                clear fullFileName vis
                
            end
            
        end % end cycling through thermal and visible images
        
    end % end RAW vs PNG data conditionals for JPG images
    
end




% load image raw data in structure
if ~strcmp(fileInfo.thermalFormat,'JPG')
    fileInfo.data = integerImg; %integer counts from camera sensor
end




% if thermal/visible overlay is possible, produce aligned+cropped images
if strcmp(fType,'jpg') && ~strcmp(fileInfo.thermalFormat,'JPG') && isfield(fileInfo,'visImage')
    % get full size images
    therm = fileInfo.data;
    vis = fileInfo.visImage;
    
    % get image sizes (read from file, not from stored matrices)
    visW = fileInfo.visImageWidth;
    visH = fileInfo.visImageHeight;
    thermW = fileInfo.width;
    thermH = fileInfo.height;
    
    % get image registration values from file
    scale = fileInfo.real2ir;
    xOff = fileInfo.offsetX;
    yOff = fileInfo.offsetY;
    x1 = fileInfo.pipX1; 
    x2 = fileInfo.pipX2;
    y1 = fileInfo.pipY1;
    y2 = fileInfo.pipY2;
    
    % render default alignment
    X1 = visW/2+xOff-round((visW/2)/scale*((x2-x1+1)/thermW));
    X2 = X1 + round((visW/2)/scale);
    Y1 = visH/2+yOff-round((visH/2)/scale*((y2-y1+1)/thermH));
    Y2 = Y1 + round(visH/scale/2);
    thermCrop = therm(y1:y2,x1:x2);
    visCrop = imresize(vis(Y1:Y2,X1:X2,:),[size(thermCrop,1) size(thermCrop,2)]);
    
    % store default aligned images in fileInfo structure
    fileInfo.overlayDefaultThermal = thermCrop;
    fileInfo.overlayDefaultVisible = visCrop;
    
    % create array of pixel offset values
    xOff = xOff-5:1:xOff+5;
    yOff = yOff-5:1:yOff+5;
    
    % find best fit offset values using 2D image correlation
    for ii = 1:numel(xOff)
        for jj = 1:numel(yOff)
            
            X1 = visW/2+xOff(ii)-round((visW/2)/scale*((x2-x1+1)/thermW));
            X2 = X1 + round((visW/2)/scale);
            Y1 = visH/2+yOff(jj)-round((visH/2)/scale*((y2-y1+1)/thermH));
            Y2 = Y1 + round(visH/scale/2);
            thermCrop = therm(y1:y2,x1:x2);
            visCrop = imresize(vis(Y1:Y2,X1:X2,:),[size(thermCrop,1) size(thermCrop,2)]);
            
            cArray = jet(128);
            lCArray = size(cArray,1);
            thermScale = round(interp1(linspace(min(thermCrop(:)),max(thermCrop(:)),lCArray),1:lCArray,thermCrop));
            thermColor = uint8(reshape(cArray(thermScale,:),[size(thermScale) 3]).*255);
            combine = round(0.7.*visCrop + 0.3.*thermColor);
            
            grayVis = rgb2gray(visCrop);
            grayTherm = rgb2gray(thermColor);
            
            correlate(ii,jj) = corr2(grayVis,grayTherm);
            
        end
    end
    
    % render best alignment
    [idxII,idxJJ] = find(correlate == max(correlate(:)));
    xOff = xOff(idxII);
    yOff = yOff(idxJJ);
    X1 = visW/2+xOff-round((visW/2)/scale*((x2-x1+1)/thermW));
    X2 = X1 + round((visW/2)/scale);
    Y1 = visH/2+yOff-round((visH/2)/scale*((y2-y1+1)/thermH));
    Y2 = Y1 + round(visH/scale/2);
    thermCrop = therm(y1:y2,x1:x2);
    visCrop = imresize(vis(Y1:Y2,X1:X2,:),[size(thermCrop,1) size(thermCrop,2)]);
    
    % store best aligned images in fileInfo structure
    fileInfo.overlayCorrelatedThermal = thermCrop;
    fileInfo.overlayCorrelatedVisible = visCrop;

end

% save file as CSV .data
if savedat
    [s,message,messageID] = mkdir(analysisDir,'output');
    dlmwrite(fnameOut,integerImg,'precision',6,'delimiter',',');
end
