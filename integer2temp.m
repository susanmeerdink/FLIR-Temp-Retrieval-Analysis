function finalImage = integer2temp(fileInfo,varargin)
%INTEGER2TEMP converts infrared image pixels from raw integer format to a
%   temperature.  The temperature can be either uncorrected or corrected
%   for object and atmosphere properties. FILEINFO is a structure
%   conforming to the output of the function IRFILEOPEN. This structure
%   contains the 16-bit interger data for each pixel, along with properties
%   and constants for the imaging sensor and atmospheric corrections. The
%   other inputs to the function indicate whether or not the output
%   temperature is corrected for object and atmospheric properties.  If
%   uncorrected temperature is desired, only a logical false must be
%   supplied after the FILEINFO structure.  If corrected temperature is
%   desired, a logical true must be supplied, followed by data inputs for
%   the correction factors. The default value for all correction factors is
%   the information stored in the header of each thermal IR file. In all
%   cases, FINALIMAGE is an array the same size as the imaging sensor, 
%   containing a temperature value in Kelvin for each pixel.
%
%   Potential Correction Factors:
%       'correction temp units' - units for air temperature and reflected
%       object corrections. Both of these temperature must be in the same
%       units.  If no correction temperature units are supplied, it is
%       assumed that the supplied corrections are in the same units as the
%       original TIR image file header values
%       'distance map' - distance between camera and object at each pixel
%           (in meters)
%       'emissivity map' - emissivity of object at each pixel
%       'reflect emissivity map' - emissivity of reflected objects at each
%       pixel in FOV
%       'object distance' - single distance applied to all pixels (in
%           meters)
%       'object emissivity' - single emissivity applied to all pixels
%       'reflect emissivity' - single emissivity of reflected objects
%       applied to all pixels
%       'air temperature' - measured air temperature (in Centigrade)
%       'RH' - measured relative humidity in integer percent (ex: 45% = 45)
%       'longwave' - net radiometer measurement of upwelling longwave
%           radiation
%       'reflected temperature' - measured temperature of background
%           objects that will be reflected off objects being imaged (in
%           Centigrade)
%
%   Example (uncorrected temperature):
%       aDir = '/Users/usr1/Documents';
%       fn = 'Rec-test-000001-103_12_15_02_153.seq';
%       ft = 'seq';
%       sDAT = false;
%       imgInfo = irFileOpen(aDir,fn,ft,sDAT);
%       img = integer2temp(imgInfo,false);
%
%   Example (corrected temperature):
%       aDir = '/Users/usr1/Documents';
%       fn = 'Rec-test-000001-103_12_15_02_153.seq';
%       ft = 'seq';
%       sDAT = false;
%       objDist = 50;
%       objEmiss = 0.94;
%       airT = 17;
%       RH = 63;
%       corrFactors = {'object distance',objDist,'object emissivity',...
%           objEmiss,'air temperature',airT,'RH',RH}
%       imgInfo = irFileOpen(aDir,fn,ft,sDAT);
%       img = integer2temp(imgInfo,true,corrFactors);
%
% ------------------------------------------------------------------------
%   Written by Donald M. Aubrecht
%   version 4
%   2 May 2014
%
%   Notes
%       v1 (13 March 2014)
%           - compatible with ExifTool v9.45
%       v2 (13 March 2014)
%           - compatible with ExifTool v9.54
%           - added capability to read atmospheric correction constants
%       v3 (30 April 2014)
%           - updated to be compatible with IRFILEOPEN v3 (removed call to
%           ExifTool)
%       v4 (2 May 2014)
%           - updated to enable user to specifiy emissivity of reflected
%           objects
% ------------------------------------------------------------------------

% Set min and max input arguments
minargs = 2; maxargs = 3;
    
% Number of inputs must be >=minargs and <=maxargs.
narginchk(minargs, maxargs);

% Distribute input arguments into working variables
if numel(varargin) == 1
    correction = varargin{1};
elseif numel(varargin) == 2
    [correction,corrFactors] = deal(varargin{:});
else
    fprintf('Incorrect number of input arguments.');
end

% Distribute file info structure elements into appropriate variables
%integerImg = fileInfo.data; % This was the original code, but we are interested in only the overlapped area of the image
integerImg = fileInfo.overlayDefaultThermal;
R1 = fileInfo.R1;
R2 = fileInfo.R2;
B = fileInfo.B;
F = fileInfo.F;
O = fileInfo.O;
alpha1 = fileInfo.alpha1;
alpha2 = fileInfo.alpha2;
beta1 = fileInfo.beta1;
beta2 = fileInfo.beta2;
X = fileInfo.X;
tempUnits = fileInfo.tempUnits;
reflectTemp = fileInfo.reflectAppTemp;
airTemp = fileInfo.atmTemp;
RH = fileInfo.RH;
objDist = fileInfo.objDist;
objEmiss = fileInfo.emiss;
focusInteger = fileInfo.focus;
focusDist = fileInfo.focusDist;
reflectObjEmiss = 1;
longwaveSensor = false;

% Distribute correction factors into working variables
if exist('corrFactors')
    index = strcmp('correction temp units',corrFactors);
    if sum(index) == 1
        corrTempUnits = corrFactors{find(index)+1};
    end
    index = strcmp('distance map',corrFactors);
    if sum(index) == 1
        distMap = corrFactors{find(index)+1};
    end
    index = strcmp('emiss map',corrFactors);
    if sum(index) == 1
        emissMap = corrFactors{find(index)+1};
    end
    index = strcmp('reflect emissivity map',corrFactors);
    if sum(index) == 1
        reflectMap = corrFactors{find(index)+1};
    end
    index = strcmp('object distance',corrFactors);
    if sum(index) == 1
        objDist = corrFactors{find(index)+1};
    end
    index = strcmp('object emissivity',corrFactors);
    if sum(index) == 1
        objEmiss = corrFactors{find(index)+1};
    end
    index = strcmp('reflect emissivity',corrFactors);
    if sum(index) == 1
        reflectObjEmiss = corrFactors{find(index)+1};
    end
    index = strcmp('air temperature',corrFactors);
    if sum(index) == 1
        airTemp = corrFactors{find(index)+1};
        if exist('corrTempUnits')
            if strcmp(corrTempUnits,'K')
                airTemp = airTemp;
            elseif strcmp(corrTempUnits,'C')
                airTemp = airTemp + 273.15;
            elseif strcmp(corrTempUnits,'F')
                airTemp = (airTemp - 32)*(5/9) + 273.15;
                if airTemp < 0.1
                    airTemp = 0;
                end
            end
        end
    end
    index = strcmp('RH',corrFactors);
    if sum(index) == 1
        RH = corrFactors{find(index)+1};
    end
    index = strcmp('longwave',corrFactors);
    if sum(index) == 1
        longwaveSensor = true;
        lwIrrad = corrFactors{find(index)+1};
    end
    index = strcmp('reflected temperature',corrFactors);
    if sum(index) == 1
        reflectTemp = corrFactors{find(index)+1};
        if exist('corrTempUnits')
            if strcmp(corrTempUnits,'K')
                reflectTemp = reflectTemp;
            elseif strcmp(corrTempUnits,'C')
                reflectTemp = reflectTemp + 273.15;
            elseif strcmp(corrTempUnits,'F')
                reflectTemp = (reflectTemp - 32)*(5/9) + 273.15;
                if reflectTemp < 0.1
                    reflectTemp = 0;
                end
            end
        end
    end
    index = strcmp('tau',corrFactors);
    if sum(index) == 1
        tau = corrFactors{find(index)+1};
    end
end

% Make sure all temperatures are in Kelvin
if strcmp(tempUnits,'C')
    reflectTemp = reflectTemp + 273.15;
    airTemp = airTemp + 273.15;
elseif strcmp(tempUnits,'F')
    reflectTemp = (reflectTemp - 32)*(5/9) + 273.15;
    airTemp = (airTemp - 32)*(5/9) + 273.15;
end
tempUnits = 'K';

% Radiometric constants
h = 6.62606957e-34; % Planck's constant
kB = 1.3806488e-23; % Boltzman's constant
c = 299792458; % speed of light


%% PERFORM IMAGE CONVERSION TO TEMPERATURE

% Convert integer image to temperature image
if correction %generate corrected temperature (Kelvin) for each pixel
    
    % create distance and emissivity maps for image FOV
    if exist('distMap') && exist('emissMap') && exist('reflectMap')
        rEmiss = reflectMap;
        emiss = emissMap;
        dist = distMap;
    elseif exist('distMap') && exist('emissMap') && ~exist('reflectMap')
        %rEmiss = ones(fileInfo.height,fileInfo.width)*reflectObjEmiss; %Original code for full thermal image
        rEmiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*reflectObjEmiss; % Code for just overlaid area
        emiss = emissMap;
        dist = distMap;
    elseif exist('distMap') && ~exist('emissMap') && exist('reflectMap')
        rEmiss = reflectMap;
        %emiss = ones(fileInfo.height,fileInfo.width)*objEmiss; %Original code for full thermal image
        emiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objEmiss; % Code of just overlaid area
        dist = distMap;
    elseif exist('distMap') && ~exist('emissMap') && ~exist('reflectMap')
        %rEmiss = ones(fileInfo.height,fileInfo.width)*reflectObjEmiss; %Original code for full thermal image
        rEmiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*reflectObjEmiss; % Code of just overlaid area
        %emiss = ones(fileInfo.height,fileInfo.width)*objEmiss; %Original code for full thermal image
        emiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objEmiss; % Code of just overlaid area
        dist = distMap;
    elseif ~exist('distMap') && exist('emissMap') && exist('reflectMap')
        rEmiss = reflectMap;
        emiss = emissMap;
        %dist = ones(fileInfo.height,fileInfo.width)*objDist;
        dist = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objDist;
    elseif ~exist('distMap') && exist('emissMap') && ~exist('reflectMap')
        %rEmiss = ones(fileInfo.height,fileInfo.width)*reflectObjEmiss;
        rEmiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*reflectObjEmiss;
        emiss = emissMap;
        %dist = ones(fileInfo.height,fileInfo.width)*objDist;
        dist = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objDist;
    else
%         rEmiss = ones(fileInfo.height,fileInfo.width)*reflectObjEmiss;
%         emiss = ones(fileInfo.height,fileInfo.width)*objEmiss;
%         dist = ones(fileInfo.height,fileInfo.width)*objDist;
        rEmiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*reflectObjEmiss;
        emiss = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objEmiss;
        dist = ones(size(fileInfo.overlayDefaultThermal,1),size(fileInfo.overlayDefaultThermal,2))*objDist;
    end 
    
    % determine reflected temperature from downward-looking pyrgeometer (Kipp & Zonen CNR4 on barn tower)
    if longwaveSensor
        reflectTemp = ((lwIrrad)/(5.67e-8))^(1/4); %lwIrrad in W/m^2, reflectAppTemp in K
    end
    
    % calculate signals from reflected objects and the atmosphere
    integerReflect = ((R1/R2)*(1/(exp(B/reflectTemp)-F)))-O;
    integerAtm = ((R1/R2)*(1/(exp(B/airTemp)-F)))-O;
    
    % calculate atmosphere transmission if no override value given
    if ~exist('tau')
        airTempC = airTemp - 273.15;
        h2o = (RH/100) * exp(1.5587 + 6.939e-2*airTempC - 2.7816e-4*airTempC^2 + 6.8455e-7*airTempC^3);
        tau = X.*exp(-sqrt(dist).*(alpha1 + beta1 * sqrt(h2o))) + (1-X).*exp(-sqrt(dist).*(alpha2 + beta2 * sqrt(h2o)));
    end
    
    % apply corrections to 16-bit integer values
    integerObj = (1./(emiss.*tau)).*(integerImg-(1-emiss).*rEmiss.*tau.*integerReflect-(1-tau).*integerAtm);
    
    % generate temperature (Kelvin) for each corrected pixel
    finalImage = (B./log(R1./(R2.*(integerObj+O))+F));
    
    
elseif ~correction %generate uncorrected temperature (Kelvin) for each pixel
    
    finalImage = (B./log(R1./(R2.*(integerImg+O))+F));
      
end %end convert image conditionals



end %end INTEGER2TEMP function