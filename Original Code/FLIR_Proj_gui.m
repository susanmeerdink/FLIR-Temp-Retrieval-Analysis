function varargout = FLIR_Proj_gui(varargin)
% FLIR_PROJ_GUI MATLAB code for FLIR_Proj_gui.fig
%      FLIR_PROJ_GUI, by itself, creates a new FLIR_PROJ_GUI or raises the existing
%      singleton*.
%
%      H = FLIR_PROJ_GUI returns the handle to a new FLIR_PROJ_GUI or the handle to
%      the existing singleton*.
%
%      FLIR_PROJ_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIR_PROJ_GUI.M with the given input arguments.
%
%      FLIR_PROJ_GUI('Property','Value',...) creates a new FLIR_PROJ_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIR_Proj_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIR_Proj_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIR_Proj_gui

% ***Original FLIR Project GUI v1.0 Created by Samuel W. Fall, 10-11-2016***

% Last Modified by GUIDE v2.5 05-Oct-2016 22:42:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FLIR_Proj_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @FLIR_Proj_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FLIR_Proj_gui is made visible.
function FLIR_Proj_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIR_Proj_gui (see VARARGIN)

% Choose default command line output for FLIR_Proj_gui
handles.output = hObject;
handles.imageLoadedFlag = 0; % this initializes the flag for checking if a images has been loaded before running batch process
handles.treeLoadedFlag = 0; % this initializes the flag for checking if a tree has been loaded before running batch process
handles.outputFolderFlag = 0; % this initializes the flag for checking if an output folder has been loaded before running batch process

% Update handles structure
guidata(hObject, handles);

% Initialize NPV, GV, Shade Values to default
handles.NPV.String = '0.94';  % Assigning default emissivity value to 'NPV'
handles.GV.String = '0.98';    % Assigning default emissivity value to 'GV'
handles.Shade.String = '1.00';   % Assigning default emissivity value to 'Shade'
handles.DWR.String = '379.8';      % Down welling radiance defaut. It should be change according to the Radiometer reading at time of Image acquisition
set(handles.openFigWindow,'Value', 0);

% UIWAIT makes FLIR_Proj_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FLIR_Proj_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ImportImages.
function ImportImages_Callback(hObject, eventdata, handles)
% hObject    handle to ImportImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%This is the code for importing images

%this allows for selecting/importing multiple files


global filename
global pathname
global filterIndex

[filename, pathname, filterIndex] = uigetfile('*.jpg','MultiSelect','on');
if ~isa(filename, 'double') % If filename is a double of value "0" then the user canceled out of the dialog 
    pathname = pathname(1:numel(pathname)-1); % removes '/' from the end of pathname; required by irFileOpen
    set(handles.ImageListBox,'String',filename);

    global imageBatchQueue
    imageBatchQueue = imageData([]);  %Initializes the image storage object
    handles.imageLoadedFlag = 1; %set the flag that images have been loaded
    guidata(hObject,handles) %updates the handles

    global fileInfo
    %Step 1
    if isa(filename,'cell')
        for i = 1:numel(filename) % loops over each file name, opens it, and stores it in the imageBatchQueue object
             [fileInfo]=irFileOpen(pathname,filename{i},'jpg','false'); %Opens each image
             [~,tempFilename,~] = fileparts(filename{i});
             fileInfo.filename = tempFilename;
             imageBatchQueue.storeImage;  %use for example 'imageBatchQueue.queue{1}.thermalFormat' to access image data 
        end
    else
        [fileInfo]=irFileOpen(pathname,filename,'jpg','false'); %Opens one image
        [~,tempFilename,~] = fileparts(filename);
        fileInfo.filename = tempFilename;
        imageBatchQueue.storeImage;  %use for example 'imageBatchQueue.queue{1}.thermalFormat' to access image data
    end
end


% --- Executes on button press in LoadTree.
function LoadTree_Callback(hObject, eventdata, handles)
% hObject    handle to LoadTree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This code is part of Step 5. It asks the user to select the tree and then loads it.
global treeFileName
global treepathname
global filterIndex
[treeFileName, treepathname, filterIndex] = uigetfile('*.mat');
if ~isa(treeFileName, 'double') % If filename is a double of value "0" then the user canceled out of the dialog 
    global t0
    load (treeFileName)  %Loads the decision tree
    set(handles.treeName,'String',treeFileName);
    handles.treeLoadedFlag = 1; %flags that a tree has been loaded
    guidata(hObject, handles)
end


% --- Executes on button press in chooseSaveFolder.
function chooseSaveFolder_Callback(hObject, eventdata, handles)
% hObject    handle to chooseSaveFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global origPathname
global newPathname
origPathname = cd;
newPathname = uigetdir; % Gets folder pathname from the user to save data into 
if ~isa(newPathname, 'double') % If filename is a double of value "0" then the user canceled out of the dialog
    handles.chooseSaveFolderDisp.String = newPathname;
    handles.outputFolderFlag = 1; %flags that a tree has been loaded
    guidata(hObject, handles)
end


% --- Executes on button press in RunBatch.
function RunBatch_Callback(hObject, eventdata, handles)
% hObject    handle to RunBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imageBatchQueue
global origPathname
global newPathname

if handles.imageLoadedFlag == 0 % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please load one or more images.','Missing Images')
   return 
end
if handles.treeLoadedFlag == 0 % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please load a clasification tree.','Missing Clasification Tree')
   return 
end
if handles.outputFolderFlag == 0 % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please choose a folder to save data files into.','Missing Output Folder Path')
   return 
end
if isempty(handles.NPV.String) % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please enter a NPV value.','Missing Emissivity Value')
   return 
end
if isempty(handles.GV.String) % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please enter a GV value.','Missing Emissivity Value')
   return 
end
if isempty(handles.Shade.String) % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please enter a Shade value.','Missing Emissivity Value')
   return 
end
if isempty(handles.DWR.String) % this checks for images and displays an error dialog if there are none
   errordlg('Error: Please enter a DWR value.','Missing Emissivity Value')
   return 
end

imageBatchQueue.queueReset; % go to first image

for  j = 1:imageBatchQueue.queueImageCount % Main loop that processes each image
    set(handles.ImageListBox,'Value',j) % sets the selection of the item in the listbox (just for the visual effect in the GUI)
    change_output       %Step 2: run the chang_output script
    global temp_sub
    temp_sub = integer2temp(fileInfo,'false');  %Step 3 
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    imwrite(fileInfo.overlayDefaultVisible,cat(2,imageBatchQueue.queue{imageBatchQueue.queueIndex}.filename,'.jpg')); %Step 4
    csvwrite(cat(2,imageBatchQueue.queue{imageBatchQueue.queueIndex}.filename,'_Uncor','.dat'),temp_sub);
    cd(origPathname)
    versionTest = version('-release');
    
    % Step 5 need to pick out just the code that is needed from the gui
    q = 2;  
    I = fileInfo.overlayDefaultVisible;  %This is were the images data is stored into I
    %Apply Tree
    for g = 1:3
        RowS=I(:,:,g);
        all_rgb(:,g)=double(RowS(:));
    end
    ratioGR = all_rgb(:,2)./all_rgb(:,1);
    sumRGB = sum(all_rgb,2);
    %Troubleshooting
    %     assignin('base','all_rgb',all_rgb)
    %     assignin('base','ratioGR',ratioGR)
    %     assignin('base','sumRGB',sumRGB)
    global x
    global t0
    x = [all_rgb,ratioGR,sumRGB];
    if str2num(versionTest(1:4)) < 2016
        treeOut_x_0 = treeval(t0,x);
        %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead. 
    else
        treeOut_x_0 = predict(tree,x);
    end
%     R=all_rgb(:,1);
%     G=all_rgb(:,2);
%     B=all_rgb(:,3);
    %treeOut_x_0(B>G+40 & R>160)=4; %Blue Flowers
    %treeOut_x_0(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS
    hx(1,:) = hist(treeOut_x_0,1:3)/length(sumRGB); 
    
    %Create Figure    
    szImg=size(RowS);
    m=szImg(1);
    n=szImg(2);
    yout=reshape(treeOut_x_0,m,n);
    assignin('base','yout',yout)
    figure
    assignin('base','cfig',gcf)
    subplot(1,2,1)
    imagesc(yout)
    axis image
    cmap=[1 1 1; 0 0 0; 0 1 0]; %colormap: white, black, green, [Blue, Yellow]
    set(gca,'CLim',[1 3])
    colormap(cmap)
    %     ytlabel={['NPV ',num2str(100*hx(1,1),2),'%'],...
    %     ['Shade ',num2str(100*hx(1,2),2),'%'],...
    %     ['GV ',num2str(100*hx(1,3),2),'%']};
    f=1;
    ytlabel = {['NPV ',num2str(100*hx(f,1),2),'%'],...
        ['Shade ',num2str(100*hx(f,2),2),'%'],...
        ['GV ',num2str(100*hx(f,3),2),'%']};
    colorbar('Ticks',[1.5 2.25 3],...
    'TickLabels',ytlabel);
    name = imageBatchQueue.queue{imageBatchQueue.queueIndex}.filename;
    title([name,' Classification (Tree1)'],'Interpreter','none')
    subplot(1,2,2)
    imagesc(I)
    axis image
    title([name,' Original'],'Interpreter','none')
    set(gcf,'Position',[1 1 810 500])
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
        savefig(gcf,imageBatchQueue.queue{j}.filename)   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    % Step6: Assigning emissivity values to classified image
    % This script read the output of "gui_image_intro_batch_flir" and 
    % assign emissivities to each pixel of different classes
    % date April 01, 2015; Written by Saleem Ullah; Version 01****
    em=yout;
    em(em==1)= str2num(handles.NPV.String); % Assigning emissivity values to class 'NPV'
    em(em==2)= str2num(handles.Shade.String); % Assigning emissivity values to class 'Shade'
    em(em==3)= str2num(handles.GV.String); % Assigning emissivity values to class 'GV'
    emiss=em;

    %Step7 (this should be a numeric field in the gui)
  
    dwr= str2num(handles.DWR.String); % Down welling radiance. It should be change according to the Radiometer reading at time of Image acquisition
    
    %******Calculating Accurate temp and Exitance******
    % Written by Saleem Ullah, Date April 02, 2015
    unCorTem = temp_sub;% Raw temperature image.
    emiss = emiss; % emissivity image

    sig = (5.670373*1e-08); % Stefen boltzmen constant

    %dwr=292.52; % Down welling radiance. It should be change according to the Radiometer reading at time of Image aquizition

    %% Uncorrected temperature and calculate the Scene average
    f1 = figure (1)
    subplot(1,2,1)
    imshow(temp_sub,[]);
    colormap 'hot'
    h=colorbar;
    title('Thermal Image without any correction (E=1)','fontsize',14);
    subplot(1,2,2)
    imshow(fileInfo.overlayDefaultVisible,[]);
    title(strcat('Visible Image_',name))
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
        savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Visible Image_'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    format shortg
    Avg_unCorTem=mean(mean(unCorTem)); %Scene average temperature assuming BB !!Output!!
    imageBatchQueue.Avg_unCorTem_queue{j} = round(Avg_unCorTem,2); % stores for inclusion into data table output

    %% Exitance calculated from Temperature at BlactBody
    Exit_at_BB = (sig*((unCorTem).^4)); % Calculating Exitance at Balack Body(BB)

    %writing Exitance Images
    f2=figure(2)
    imshow(Exit_at_BB,[]);
    title('Exitance Image without any correction(Assuming BB)', 'fontsize',12')
    colormap 'hot'
    h=colorbar;
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Exitance_Image_No_Correction'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    % Scene Temperature calculated from average Exitance at BB
    Avg_Exit_at_BB =mean(mean(Exit_at_BB)); %Scene average Exitance at BB !!Output!!
    imageBatchQueue.Avg_Exit_at_BB_queue{j} = round(Avg_Exit_at_BB,2); % stores for inclusion into data table output
    Scene_temp_calcul_from_Avg_exit_at_BB=((Avg_Exit_at_BB)/sig)^0.25; % calculate scene temperature from Avg_exitance !!Output!!
    imageBatchQueue.Scene_temp_calcul_from_Avg_exit_at_BB_queue{j,1} = round(Scene_temp_calcul_from_Avg_exit_at_BB,2); % stores for inclusion into data table output

    %% Exitance after correcting down welling Radiance and assuming emissivity of 0.95.

    Surf_exit=Exit_at_BB-((1-0.95)*dwr); % the 'DWR' may be varing with time of day and with atmospheric condition.  
    Avg_Surf_exit=mean(mean(Surf_exit)); %!!Output!!
    imageBatchQueue.Avg_Surf_exit_queue{j} = round(Avg_Surf_exit,2); % stores for inclusion into data table output
    Scene_temp_calcul_from_Avg_Surf_exit=(Avg_Surf_exit/(sig*0.95))^0.25; % !!Output!!
    imageBatchQueue.Scene_temp_calcul_from_Avg_Surf_exit_queue{j} = round(Scene_temp_calcul_from_Avg_Surf_exit,2); % stores for inclusion into data table output
    f3=figure(3)
    subplot(1,2,1)
    imshow(Surf_exit,[])
    colormap 'hot'
    h=colorbar;
    title('Exitance at Surface, corrected for L_D_W_R(emissivity=0.95)', 'fontsize',12)
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Exitance_at_Surface_Corrected95'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    %% Temperature after corecting for DWR and assuming emissivity 0.95
    Temp_calcul_from_Surf_exit=(Surf_exit/(sig*0.95)).^0.25;    
    Scene_temp_at_Emiss_95=mean(mean(Temp_calcul_from_Surf_exit));%!!Output!!
    imageBatchQueue.Scene_temp_at_Emiss_95_queue{j} = round(Scene_temp_at_Emiss_95,2); % stores for inclusion into data table output
    f3=figure(3)
    subplot(1,2,2)
    imshow(Temp_calcul_from_Surf_exit,[])
    colormap 'hot'
    h=colorbar;
    title('Surface Temperature , corrected for L_D_W_R(emissivity=0.95)', 'fontsize',12)
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Surface_Temperature_Corrected'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    %% Retriving surface Exitance using pixel based emissivity and correcting for DWR 
    Scene_emiss=mean(mean(emiss)); % average (scene) emissivity (use same below for output)
    Surf_exit_using_class_emiss=(Exit_at_BB -((1-emiss).*dwr)); 
    f4=figure(4)
    imshow(Surf_exit_using_class_emiss,[])
    title('Exitance at Surface corrected for L_D_W_R(emissivity=NPV,GV,SOIL)', 'fontsize',12)
    colormap 'hot'
    h=colorbar;
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Exitance_at_Surface_Corrected_NPV_GV_SOIL'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    Avg_Surf_exit_using_class_emiss=mean(mean(Surf_exit_using_class_emiss));       %!!Output!!
    imageBatchQueue.Avg_Surf_exit_using_class_emiss_queue{j} = round(Avg_Surf_exit_using_class_emiss,2); % stores for inclusion into data table output
    Scene_emiss=mean(mean(emiss));                                                 %!!Output!!
    imageBatchQueue.Scene_emiss_queue{j} = round(Scene_emiss,2); % stores for inclusion into data table output
    Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss=(Avg_Surf_exit_using_class_emiss/(Scene_emiss*sig))^0.25; %!!Output!!
    imageBatchQueue.Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss_queue{j} = round(Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss,2); % stores for inclusion into data table output


    %% Surface Temperature using pixel based emissivity and  applying DWR corrections
    Surf_temp_using_class_emiss_DWR=(Surf_exit_using_class_emiss./(emiss.*sig)).^0.25;  
    Avg_Surf_temp_using_class_emiss=mean(mean(Surf_temp_using_class_emiss_DWR));        %!!Output!!
    imageBatchQueue.Avg_Surf_temp_using_class_emiss_queue{j} = round(Avg_Surf_temp_using_class_emiss,2); % stores for inclusion into data table output
    f5=figure(5);
    imshow(Surf_temp_using_class_emiss_DWR,[])
    title('Temperature at Surface corrected for L_D_W_R(emissivity=NPV,GV,SOIL)', 'fontsize',12)
    colormap 'hot'
    h=colorbar;
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
    savefig(gcf,strcat(imageBatchQueue.queue{j}.filename,'Temperature_at_Surface_Corrected_NPV_GV_SOIL'))   %Saves the figure out
    cd(origPathname)
    if handles.openFigWindow.Value == 0 % if the user turned off auto open then the figures are closed after saving out.
        close(gcf)
    end
    %End Step7
    
    
    fileName{j} = imageBatchQueue.queue{j}.filename; % This is where the filename used in the output table is set.
    imageBatchQueue.tableFileName_queue{j} = fileName{j};
    dateOrig = strsplit(imageBatchQueue.queue{j}.dateTimeOrig);    % stores date when the image was captured. year:month:day Example: 2015:02:20
    timeOrig24_hour_min_sec = cellstr(dateOrig{2});    % slpits the date and time parts up into individual variables
    dateOrig = cellstr(dateOrig{1});    % slpits the date and time parts up into individual variables
    imageBatchQueue.dateOrig_queue{j} = dateOrig{1};
    imageBatchQueue.timeOrig24_hour_min_sec_queue{j} = timeOrig24_hour_min_sec{1};
    
    
    % Assigning emissivity values to named variables for output to table:
    NPV_Value = str2num(handles.NPV.String);
    imageBatchQueue.NPV_Value{j} = NPV_Value; % stores for inclusion into data table output
    GV_Value = str2num(handles.GV.String);
    imageBatchQueue.GV_Value{j} = GV_Value; % stores for inclusion into data table output
    Shade_Value = str2num(handles.Shade.String);
    imageBatchQueue.Shade_Value{j} = Shade_Value; % stores for inclusion into data table output
    DWR_Value = str2num(handles.DWR.String);     
    imageBatchQueue.DWR_Value{j} = DWR_Value; % stores for inclusion into data table output
    
    % Generate data output table. 
    %Values Not Used: Surf_exit,
    %Temp_calcul_from_Surf_exit, Surf_temp_using_class_emiss_DWR, Surf_exit_using_class_emiss
    Data_Output_Table = table(fileName(1),dateOrig,timeOrig24_hour_min_sec,Avg_unCorTem,Avg_Exit_at_BB,Scene_temp_calcul_from_Avg_exit_at_BB',...
        Avg_Surf_exit,Scene_temp_calcul_from_Avg_Surf_exit,...
        Scene_temp_at_Emiss_95,Scene_emiss,Avg_Surf_exit_using_class_emiss,...
        Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss,Avg_Surf_temp_using_class_emiss,NPV_Value,GV_Value,Shade_Value,DWR_Value)

    ImageSpreadSheetName = strcat(fileName{j},'_Data');
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
        writetable(Data_Output_Table,ImageSpreadSheetName)   %Saves the table out as csv file
    cd(origPathname)

    %combinedFileName{j} = imageBatchQueue.tableFileName_queue{j};

    imageBatchQueue.queueNext; % Load next image from queue
end

  % Generate combined data output table for all processed images. 
    %Values Not Used: Surf_exit,
    %Temp_calcul_from_Surf_exit, Surf_temp_using_class_emiss_DWR, Surf_exit_using_class_emiss
    fileName = imageBatchQueue.tableFileName_queue';          %stores the name column for output
    dateOrig = imageBatchQueue.dateOrig_queue';               %stores the date column for output
    timeOrig24_hour_min_sec = imageBatchQueue.timeOrig24_hour_min_sec_queue';  %stores the time column for output
    Avg_unCorTem = imageBatchQueue.Avg_unCorTem_queue';                          %Scene average temperature assuming BB 
        % Exitance calculated from Temperature at BlactBody
    Avg_Exit_at_BB = imageBatchQueue.Avg_Exit_at_BB_queue';     %Scene average Exitance at BB
    Scene_temp_calcul_from_Avg_exit_at_BB = imageBatchQueue.Scene_temp_calcul_from_Avg_exit_at_BB_queue; %calculate scene temperature from Avg_exitance
        % Exitance after correcting down welling Radiance and assuming emissivity of 0.95
    Avg_Surf_exit = imageBatchQueue.Avg_Surf_exit_queue';    %the 'DWR' may be varing with time of day and with atmospheric condition.  
    Scene_temp_calcul_from_Avg_Surf_exit = imageBatchQueue.Scene_temp_calcul_from_Avg_Surf_exit_queue';
        % Temperature after corecting for DWR and assuming emissivity 0.95
    Scene_temp_at_Emiss_95 = imageBatchQueue.Scene_temp_at_Emiss_95_queue';
        % Retriving surface Exitance using pixel based emissivity and correcting for DWR
    Scene_emiss = imageBatchQueue.Scene_emiss_queue'; % average (scene) emissivity
    Avg_Surf_exit_using_class_emiss = imageBatchQueue.Avg_Surf_exit_using_class_emiss_queue';
    Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss = imageBatchQueue.Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss_queue';
        % Surface Temperature using pixel based emissivity and  applying DWR corrections
    Avg_Surf_temp_using_class_emiss = imageBatchQueue.Avg_Surf_temp_using_class_emiss_queue';
    NPV_Value = imageBatchQueue.NPV_Value'; 
    GV_Value = imageBatchQueue.GV_Value'; 
    Shade_Value = imageBatchQueue.Shade_Value'; 
    DWR_Value = imageBatchQueue.DWR_Value'; 

    % forms the combined output table
    imageBatchQueue.Data_Output_Table_queue = table(fileName,dateOrig,timeOrig24_hour_min_sec,Avg_unCorTem,Avg_Exit_at_BB,Scene_temp_calcul_from_Avg_exit_at_BB,...
    Avg_Surf_exit,Scene_temp_calcul_from_Avg_Surf_exit,...
    Scene_temp_at_Emiss_95,Scene_emiss,Avg_Surf_exit_using_class_emiss,...
    Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss,Avg_Surf_temp_using_class_emiss,NPV_Value,GV_Value,Shade_Value,DWR_Value)
   
    % saves the combined output table to cv file
    cd(newPathname); % changes the working folder to the users selection, so files can be saved
        writetable(imageBatchQueue.Data_Output_Table_queue,strcat('Combined_Output_Series_',imageBatchQueue.tableFileName_queue{1}))   %Saves the table out as csv file
    cd(origPathname)

% --- Executes on selection change in ImageListBox.
function ImageListBox_Callback(hObject, eventdata, handles)
% hObject    handle to ImageListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageListBox


% --- Executes during object creation, after setting all properties.
function ImageListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NPV_Callback(hObject, eventdata, handles)
% hObject    handle to NPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NPV as text
%        str2double(get(hObject,'String')) returns contents of NPV as a double


% --- Executes during object creation, after setting all properties.
function NPV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GV_Callback(hObject, eventdata, handles)
% hObject    handle to GV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GV as text
%        str2double(get(hObject,'String')) returns contents of GV as a double


% --- Executes during object creation, after setting all properties.
function GV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Shade_Callback(hObject, eventdata, handles)
% hObject    handle to Shade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Shade as text
%        str2double(get(hObject,'String')) returns contents of Shade as a double


% --- Executes during object creation, after setting all properties.
function Shade_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Shade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearImages.
function clearImages_Callback(hObject, eventdata, handles)
% hObject    handle to clearImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear imageBatchQueue')
set(handles.ImageListBox,'String', ' ')
global imageBatchQueue
imageBatchQueue = imageData([]); %Initializes new image storage object
handles.imageLoadedFlag = 0; %clear the flag to show that images have not been loaded
guidata(hObject,handles) %updates the handles
set(handles.ImageListBox,'Value',1); % resets the batchqueue selestion to the first item


% --- Executes during object creation, after setting all properties.
function clearImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clearImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in closeAllFigures.
function closeAllFigures_Callback(hObject, eventdata, handles)
% hObject    handle to closeAllFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handleMainGUI = gcf;
set(handleMainGUI, 'HandleVisibility', 'off');
close all;
set(handleMainGUI, 'HandleVisibility', 'on');


% --- Executes on button press in openFigWindow.
function openFigWindow_Callback(hObject, eventdata, handles)
% hObject    handle to openFigWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of openFigWindow


% --- Executes on button press in openSelectedImages.
function openSelectedImages_Callback(hObject, eventdata, handles)
% hObject    handle to openSelectedImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global newPathname
global origPathname
cd(newPathname); % changes the working folder
if isa(handles.ImageListBox.String,'cell')
    [~, figureName, ~] = fileparts(handles.ImageListBox.String{handles.ImageListBox.Value}); %If two or more images were load
else
    [~, figureName, ~] = fileparts(handles.ImageListBox.String); %If only one image was loaded
end
names = dir(strcat(figureName,'*.fig'));
names = {names.name};
for i = 1:length(names)
    open(names{i})
end
cd(origPathname)
    

function DWR_Callback(hObject, eventdata, handles)
% hObject    handle to DWR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DWR as text
%        str2double(get(hObject,'String')) returns contents of DWR as a double


% --- Executes during object creation, after setting all properties.
function DWR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DWR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when uipanel5 is resized.
function uipanel5_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Quit.
function Quit_Callback(hObject, eventdata, handles)
% hObject    handle to Quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear all')
evalin('base','clc')
close all
