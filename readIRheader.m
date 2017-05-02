function fileInfo = readIRheader(fname)
%READIRHEADER Reads the entire header of a FLIR camera image file
%   (*.seq, *.fff, or *.jpg).  FNAME is the full path filename of the 
%   image file from which to read the header.  FILEINFO is a structure 
%   containing all the information contained in the header tags.
%
% ------------------------------------------------------------------------
%   Written by Donald M. Aubrecht
%   version 5
%   3 September 2014
%
%   Notes
%       v1 (30 April 2014)
%           - compatible with known FLIR tag locations in *.SEQ and
%           radiometric *.JPG files as of 30 April 2014.
%           - only tested on images from the following cameras: A655sc,
%           A325sc, SC325, and T450sc
%       v2 (8 July 2014)
%           - added capability to read *.FFF files
%       v3 (21 August 2014)
%           - updated compatibility with radiometric *.JPG that have not
%           been reopened in FLIR software
%       v4 (28 August 2014)
%           - updated compatibility with *.FFF files to deal with the extra
%           information appended in the first image in a recording sequence
%           - updated compatibility with *.JPG files to deal with thermal
%           sensor sizes stored at different indices in the header
%       v5 (3 September 2014)
%           - updated routine for finding header information in *.SEQ so 
%           that byte offsets are not hard-coded
% ------------------------------------------------------------------------


% Set file name
fileInfo.name = fname;

parts = regexp(fname,'\.','split');
fileType = parts{end};

if strcmp(fileType,'seq')
    
    % Determine if the header is saved before or after the image data
    fid = fopen(fname,'r');
    allData = fread(fid);
    fclose(fid);
    allChar = char(allData);
    folChar = ['F';'O';'L']; % use focal length tag to find header and then camera model
    folIdx = findstr(folChar.',allChar.');
    modelName = allData(folIdx-151:folIdx-151+15);
    mnEndIdx = find(modelName == 0,1);
    modelText = [char(modelName(1:mnEndIdx-1)).'];
    [headerStartIndicator,width,height] = cameraModel(modelText);
    headerStartIdx = findstr(allData.',headerStartIndicator.');
    
    % Set magic sequence for finding data and headers
    fileInfo.magicSeq = headerStartIndicator;
    
    % Determine which index is for the header
    if (headerStartIdx(2)-headerStartIdx(1)) > width*height*2
        skipToByte = headerStartIdx(2)-1;
    else
        skipToByte = headerStartIdx(1)-1;
    end
    clear allData allChar folChar folIdx modelName mnEndIdx modelText...
        headerStartIndicator headerStartIdx width height
    
    % Read in camera and file parameters
    fileInfo.emiss = readIRheaderblock(fname,skipToByte,32,'d','f','l');
    fileInfo.objDist = readIRheaderblock(fname,skipToByte,36,'d','f','l');
    fileInfo.reflectAppTemp = readIRheaderblock(fname,skipToByte,40,'d','f','l');
    fileInfo.atmTemp = readIRheaderblock(fname,skipToByte,44,'d','f','l');
    fileInfo.windowTemp = readIRheaderblock(fname,skipToByte,48,'d','f','l');
    fileInfo.windowTrans = readIRheaderblock(fname,skipToByte,52,'d','f','l');
    fileInfo.RH = readIRheaderblock(fname,skipToByte,60,'d','f','l');
    fileInfo.R1 = readIRheaderblock(fname,skipToByte,88,'d','f','l');
    fileInfo.B = readIRheaderblock(fname,skipToByte,92,'d','f','l');
    fileInfo.F = readIRheaderblock(fname,skipToByte,96,'d','f','l');
    fileInfo.alpha1 = readIRheaderblock(fname,skipToByte,112,'d','f','l');
    fileInfo.alpha2 = readIRheaderblock(fname,skipToByte,116,'d','f','l');
    fileInfo.beta1 = readIRheaderblock(fname,skipToByte,120,'d','f','l');
    fileInfo.beta2 = readIRheaderblock(fname,skipToByte,124,'d','f','l');
    fileInfo.X = readIRheaderblock(fname,skipToByte,128,'d','f','l');
    fileInfo.camRangeMax = readIRheaderblock(fname,skipToByte,144,'d','f','l');
    fileInfo.camRangeMin = readIRheaderblock(fname,skipToByte,148,'d','f','l');
    fileInfo.camModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,212,'d','s32','l')).'));
    fileInfo.camPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,244,'d','s32','l')).'));
    fileInfo.camSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,260,'d','s16','l')).'));
    fileInfo.camSoftwareVer = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,276,'d','s16','l')).'));
    fileInfo.lensModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,368,'d','s32','l')).'));
    fileInfo.lensPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,400,'d','s16','l')).'));
    fileInfo.lensSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,416,'d','s16','l')).'));
    fileInfo.lensHorzFOV = readIRheaderblock(fname,skipToByte,436,'d','f','l');
    fileInfo.filterModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,492,'d','s16','l')).'));
    fileInfo.filterPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,508,'d','s32','l')).'));
    fileInfo.filterSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,540,'d','s32','l')).'));
    fileInfo.O = readIRheaderblock(fname,skipToByte,776,'d','i32','l');
    fileInfo.R2 = readIRheaderblock(fname,skipToByte,780,'d','f','l');
    fileInfo.rawMedian = readIRheaderblock(fname,skipToByte,824,'d','u16','l');
    fileInfo.rawRange = readIRheaderblock(fname,skipToByte,828,'d','u16','l');
    unixDTOrig = readIRheaderblock(fname,skipToByte,900,'d','u32','l');
    millisOrig = readIRheaderblock(fname,skipToByte,904,'d','u32','l');
    timezoneOrig = readIRheaderblock(fname,skipToByte,908,'d','i16','l');
    fileInfo.dateTimeOrig = datestr(datenum([1970 1 1 0 0 unixDTOrig-timezoneOrig*60]),'yyyy:mm:dd HH:MM:SS');
    fileInfo.dateTimeOrig = strcat(fileInfo.dateTimeOrig,'.',num2str(millisOrig),sprintf('%+03i',-timezoneOrig/60),':00');
    fileInfo.focus = readIRheaderblock(fname,skipToByte,912,'d','u16','l');
    fileInfo.focusDist = readIRheaderblock(fname,skipToByte,1116,'d','f','l');
    
    % Read in camera sensor parameters
    skipToByte = 322;
    fileInfo.width = readIRheaderblock(fname,skipToByte,0,'d','u16','l'); %image width in pixels
    fileInfo.height = readIRheaderblock(fname,skipToByte,2,'d','u16','l'); %image height in pixels
    
    % Set thermal data storage format
    fileInfo.thermalFormat = 'RAW';
    
elseif strcmp(fileType,'fff')
    
    % Determine if the header is saved before or after the image data
    fid = fopen(fname,'r');
    allData = fread(fid);
    fclose(fid);
    allChar = char(allData);
    folChar = ['F';'O';'L']; % use focal length tag to find header and then camera model
    folIdx = findstr(folChar.',allChar.');
    modelName = allData(folIdx-151:folIdx-151+15);
    mnEndIdx = find(modelName == 0,1);
    modelText = [char(modelName(1:mnEndIdx-1)).'];
    [headerStartIndicator,width,height] = cameraModel(modelText);
    headerStartIdx = findstr(allData.',headerStartIndicator.');
    
    % Set magic sequence for finding data and headers
    fileInfo.magicSeq = headerStartIndicator;
    
    % Determine which index is for the header
    if (headerStartIdx(2)-headerStartIdx(1)) > width*height*2
        skipToByte = headerStartIdx(2)-1;
    else
        skipToByte = headerStartIdx(1)-1;
    end
    clear allData allChar folChar folIdx modelName mnEndIdx modelText...
        headerStartIndicator headerStartIdx width height
    
    % Read in camera and file parameters
    fileInfo.emiss = readIRheaderblock(fname,skipToByte,32,'d','f','l');
    fileInfo.objDist = readIRheaderblock(fname,skipToByte,36,'d','f','l');
    fileInfo.reflectAppTemp = readIRheaderblock(fname,skipToByte,40,'d','f','l');
    fileInfo.atmTemp = readIRheaderblock(fname,skipToByte,44,'d','f','l');
    fileInfo.windowTemp = readIRheaderblock(fname,skipToByte,48,'d','f','l');
    fileInfo.windowTrans = readIRheaderblock(fname,skipToByte,52,'d','f','l');
    fileInfo.RH = readIRheaderblock(fname,skipToByte,60,'d','f','l');
    fileInfo.R1 = readIRheaderblock(fname,skipToByte,88,'d','f','l');
    fileInfo.B = readIRheaderblock(fname,skipToByte,92,'d','f','l');
    fileInfo.F = readIRheaderblock(fname,skipToByte,96,'d','f','l');
    fileInfo.alpha1 = readIRheaderblock(fname,skipToByte,112,'d','f','l');
    fileInfo.alpha2 = readIRheaderblock(fname,skipToByte,116,'d','f','l');
    fileInfo.beta1 = readIRheaderblock(fname,skipToByte,120,'d','f','l');
    fileInfo.beta2 = readIRheaderblock(fname,skipToByte,124,'d','f','l');
    fileInfo.X = readIRheaderblock(fname,skipToByte,128,'d','f','l');
    fileInfo.camRangeMax = readIRheaderblock(fname,skipToByte,144,'d','f','l');
    fileInfo.camRangeMin = readIRheaderblock(fname,skipToByte,148,'d','f','l');
    fileInfo.camModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,212,'d','s32','l')).'));
    fileInfo.camPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,244,'d','s32','l')).'));
    fileInfo.camSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,260,'d','s16','l')).'));
    fileInfo.camSoftwareVer = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,276,'d','s16','l')).'));
    fileInfo.lensModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,368,'d','s32','l')).'));
    fileInfo.lensPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,400,'d','s16','l')).'));
    fileInfo.lensSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,416,'d','s16','l')).'));
    fileInfo.lensHorzFOV = readIRheaderblock(fname,skipToByte,436,'d','f','l');
    fileInfo.filterModel = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,492,'d','s16','l')).'));
    fileInfo.filterPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,508,'d','s32','l')).'));
    fileInfo.filterSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,skipToByte,540,'d','s32','l')).'));
    fileInfo.O = readIRheaderblock(fname,skipToByte,776,'d','i32','l');
    fileInfo.R2 = readIRheaderblock(fname,skipToByte,780,'d','f','l');
    fileInfo.rawMedian = readIRheaderblock(fname,skipToByte,824,'d','u16','l');
    fileInfo.rawRange = readIRheaderblock(fname,skipToByte,828,'d','u16','l');
    unixDTOrig = readIRheaderblock(fname,skipToByte,900,'d','u32','l');
    millisOrig = readIRheaderblock(fname,skipToByte,904,'d','u32','l');
    timezoneOrig = readIRheaderblock(fname,skipToByte,908,'d','i16','l');
    fileInfo.dateTimeOrig = datestr(datenum([1970 1 1 0 0 unixDTOrig-timezoneOrig*60]),'yyyy:mm:dd HH:MM:SS');
    fileInfo.dateTimeOrig = strcat(fileInfo.dateTimeOrig,'.',num2str(millisOrig),sprintf('%+03i',-timezoneOrig/60),':00');
    fileInfo.focus = readIRheaderblock(fname,skipToByte,912,'d','u16','l');
    fileInfo.focusDist = readIRheaderblock(fname,skipToByte,1116,'d','f','l');
    
    % Read in camera sensor parameters
    skipToByte = skipToByte+2;
    fileInfo.width = readIRheaderblock(fname,skipToByte,0,'d','u16','l'); %image width in pixels
    fileInfo.height = readIRheaderblock(fname,skipToByte,2,'d','u16','l'); %image height in pixels
    
    % Set thermal data storage format
    fileInfo.thermalFormat = 'RAW';
    
elseif strcmp(fileType,'jpg')
    
    % Determine how data is stored in image file (native off the camera is
    % PNG, after opening in FLIR software format changes to TIFF and
    % offsets change)
    fid = fopen(fname,'r');
    allData = fread(fid);
    fclose(fid);
    allChar = char(allData);
    dataIndicator = ['F';'F';'F'];
    jpgIndicator = ['J';'F';'I';'F'];
    pngChar = ['P';'N';'G'];
    hdrChar = ['I';'H';'D';'R'];
    endChar = ['I';'E';'N';'D'];
    dataStart = findstr(dataIndicator.',allChar.');
    jpgStart = findstr(jpgIndicator.',allChar.');
    pngStart = findstr(pngChar.',allChar.')-1;
    pngHdr = findstr(hdrChar.',allChar.');
    pngEnd = findstr(endChar.',allChar.')+7;
    
    if ~isempty(dataStart)
        
        if numel(jpgStart) < 2 % Deal with radiometric JPG
            
            % Byte offset for JPG header
            jpgOffset = dataStart(1);
            
            % Read in camera and file parameters
            skipToByte = 511;
            fileInfo.emiss = readIRheaderblock(fname,jpgOffset+skipToByte,32,'d','f','l');
            fileInfo.objDist = readIRheaderblock(fname,jpgOffset+skipToByte,36,'d','f','l');
            fileInfo.reflectAppTemp = readIRheaderblock(fname,jpgOffset+skipToByte,40,'d','f','l');
            fileInfo.atmTemp = readIRheaderblock(fname,jpgOffset+skipToByte,44,'d','f','l');
            fileInfo.windowTemp = readIRheaderblock(fname,jpgOffset+skipToByte,48,'d','f','l');
            fileInfo.windowTrans = readIRheaderblock(fname,jpgOffset+skipToByte,52,'d','f','l');
            fileInfo.RH = readIRheaderblock(fname,jpgOffset+skipToByte,60,'d','f','l');
            fileInfo.R1 = readIRheaderblock(fname,jpgOffset+skipToByte,88,'d','f','l');
            fileInfo.B = readIRheaderblock(fname,jpgOffset+skipToByte,92,'d','f','l');
            fileInfo.F = readIRheaderblock(fname,jpgOffset+skipToByte,96,'d','f','l');
            fileInfo.alpha1 = readIRheaderblock(fname,jpgOffset+skipToByte,112,'d','f','l');
            fileInfo.alpha2 = readIRheaderblock(fname,jpgOffset+skipToByte,116,'d','f','l');
            fileInfo.beta1 = readIRheaderblock(fname,jpgOffset+skipToByte,120,'d','f','l');
            fileInfo.beta2 = readIRheaderblock(fname,jpgOffset+skipToByte,124,'d','f','l');
            fileInfo.X = readIRheaderblock(fname,jpgOffset+skipToByte,128,'d','f','l');
            fileInfo.camRangeMax = readIRheaderblock(fname,jpgOffset+skipToByte,144,'d','f','l');
            fileInfo.camRangeMin = readIRheaderblock(fname,jpgOffset+skipToByte,148,'d','f','l');
            fileInfo.camModel = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,212,'d','s64','l')).'));
            fileInfo.camPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,244,'d','s32','l')).'));
            fileInfo.camSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,260,'d','s16','l')).'));
            fileInfo.camSoftwareVer = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,276,'d','s16','l')).'));
            fileInfo.lensModel = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,368,'d','s32','l')).'));
            fileInfo.lensPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,400,'d','s16','l')).'));
            fileInfo.lensSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,416,'d','s16','l')).'));
            fileInfo.lensHorzFOV = readIRheaderblock(fname,jpgOffset+skipToByte,436,'d','f','l');
            fileInfo.filterModel = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,492,'d','s16','l')).'));
            fileInfo.filterPartNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,508,'d','s32','l')).'));
            fileInfo.filterSerialNum = cell2mat(cellstr(char(readIRheaderblock(fname,jpgOffset+skipToByte,540,'d','s32','l')).'));
            fileInfo.O = readIRheaderblock(fname,jpgOffset+skipToByte,776,'d','i32','l');
            fileInfo.R2 = readIRheaderblock(fname,jpgOffset+skipToByte,780,'d','f','l');
            fileInfo.rawMedian = readIRheaderblock(fname,jpgOffset+skipToByte,824,'d','u16','l');
            fileInfo.rawRange = readIRheaderblock(fname,jpgOffset+skipToByte,828,'d','u16','l');
            unixDTOrig = readIRheaderblock(fname,jpgOffset+skipToByte,900,'d','u32','l');
            millisOrig = readIRheaderblock(fname,jpgOffset+skipToByte,904,'d','u32','l');
            timezoneOrig = readIRheaderblock(fname,jpgOffset+skipToByte,908,'d','i16','l');
            fileInfo.dateTimeOrig = datestr(datenum([1970 1 1 0 0 unixDTOrig-timezoneOrig*60]),'yyyy:mm:dd HH:MM:SS');
            fileInfo.dateTimeOrig = strcat(fileInfo.dateTimeOrig,'.',num2str(millisOrig),sprintf('%+03i',-timezoneOrig/60),':00');
            fileInfo.focus = readIRheaderblock(fname,jpgOffset+skipToByte,912,'d','u16','l');
            fileInfo.focusDist = readIRheaderblock(fname,jpgOffset+skipToByte,1116,'d','f','l');
            
            % Read in extra info for registering visible and thermal images
            if ~isempty(pngStart)
                
                % Read in camera IR sensor parameters
                skipToByte = pngHdr(1) + 5;
                fileInfo.width = readIRheaderblock(fname,skipToByte,0,'d','u16','b'); %image width in pixels
                fileInfo.height = readIRheaderblock(fname,skipToByte,4,'d','u16','b'); %image height in pixels
                
                fileInfo.thermalFormat = 'PNG';
                
                % Read image registration parameters
                subsetData = allData(pngEnd(1)+1:pngEnd(1)+20);
                skipIdx = find(subsetData > 0,1);
                skipToByte = pngEnd(1) + skipIdx - 1;
                fileInfo.real2ir = readIRheaderblock(fname,skipToByte,0,'d','f','l');
                fileInfo.offsetX = readIRheaderblock(fname,skipToByte,4,'d','i16','l');
                fileInfo.offsetY = readIRheaderblock(fname,skipToByte,6,'d','i16','l');
                fileInfo.pipX1 = readIRheaderblock(fname,skipToByte,8,'d','i16','l');
                fileInfo.pipX2 = readIRheaderblock(fname,skipToByte,10,'d','i16','l');
                fileInfo.pipY1 = readIRheaderblock(fname,skipToByte,12,'d','i16','l');
                fileInfo.pipY2 = readIRheaderblock(fname,skipToByte,14,'d','i16','l');
                % Read visible image dimensions
                skipToByte = pngHdr(2) + 5;
                fileInfo.visImageWidth = readIRheaderblock(fname,skipToByte,0,'d','u16','b');
                fileInfo.visImageHeight = readIRheaderblock(fname,skipToByte,4,'d','u16','b');
                
            else
                
                % Read in camera IR sensor parameters
                imgIndicator = [51;147;146;67;49;0;0;0;2;0]; % indicator just before beginning of thermal data
                dataBeginIdx = findstr(allData.',imgIndicator.');
                skipToByte = dataBeginIdx + 9;
                fileInfo.width = readIRheaderblock(fname,skipToByte,0,'d','u16','l'); %image width in pixels
                fileInfo.height = readIRheaderblock(fname,skipToByte,2,'d','u16','l'); %image height in pixels
                
                fileInfo.thermalFormat = 'RAW';
                
            end
            
        else % Deal with visible JPG image taken by FLIR camera
            
            fileInfo.thermalFormat = 'JPG';
            
        end
        
    end
    
end


% Determine and assign temperature unit
if isfield(fileInfo,'atmTemp')
    if fileInfo.atmTemp > 100
        fileInfo.tempUnits = 'K';
    elseif fileInfo.atmTemp > 20
        fileInfo.tempUnits = 'C';
    else
        fileInfo.tempUnits = 'F';
    end
end