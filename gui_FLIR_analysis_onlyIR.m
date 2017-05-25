function varargout = gui_FLIR_analysis_onlyIR(varargin)
% GUI_FLIR_ANALYSIS MATLAB code for gui_FLIR_analysis_onlyIR.fig
%      GUI_FLIR_ANALYSIS_onlyIR, by itself, creates a new GUI_FLIR_ANALYSIS_onlyIR or raises the existing
%      singleton*.
%
%      H = GUI_FLIR_ANALYSIS_onlyIR returns the handle to a new GUI_FLIR_ANALYSIS_onlyIR or the handle to
%      the existing singleton*.
%
%      GUI_FLIR_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLIR_ANALYSIS_onlyIR.M with the given input arguments.
%
%      GUI_FLIR_ANALYSIS_onlyIR('Property','Value',...) creates a new GUI_FLIR_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_FLIR_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_FLIR_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_FLIR_analysis

% Last Modified by GUIDE v2.5 25-May-2017 08:09:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_FLIR_analysis_onlyIR_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_FLIR_analysis_onlyIR_OutputFcn, ...
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


% --- Executes just before gui_FLIR_analysis is made visible.
function gui_FLIR_analysis_onlyIR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_FLIR_analysis (see VARARGIN)

% Choose default command line output for gui_FLIR_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_FLIR_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_FLIR_analysis_onlyIR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ImageList.
function ImageList_Callback(hObject, eventdata, handles)
% hObject    handle to ImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageList


% --- Executes during object creation, after setting all properties.
function ImageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Step1.
function Step1_Callback(hObject, eventdata, handles)
% hObject    handle to Step1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fnames,folder] = uigetfile('*.JPG','Select Files to Load','MultiSelect','on');
try %If fileInfo exists (only happens if you are loading in files a second time)
    fileInfo = evalin('base','fileInfo');
catch %If fileInfo doesn't exist
    fileInfo = [];
end 
fnamesList = {};
%Loop through and open files
if iscell(fnames) == 0  %If no or one file are selected, fnames is returned as a string NOT cell
    if fnames == 0 %If no files are selected
        errordlg('No Files Selected','Error');
    else %if one file is selected
        %Setting up variables for workspace and future analysis
        tempFile = irFileOpen_onlyIR(folder,fnames,'jpg','false'); %Opens each image
        fileInfo{size(fileInfo,1)+1} = tempFile;
        fnamesList{size(fnamesList,1)+1} = fnames;
    end   
else %if multiple files are selected
    for n = 1:size(fnames,2) %Loop through files   
        %Setting up variables for workspace and future analysis
        tempFile = irFileOpen_onlyIR(folder,fnames{n},'jpg','false'); %Opens each image
        fileInfo{size(fileInfo,2)+1} = tempFile;
        fnamesList{size(fnamesList,2)+1} = fnames{n};
    end
end
%Assign final variables to workspace & update GUI
new_table = cell(size(fnamesList,2),2);
new_table(:,1) = fnamesList;
new_table(:,2) = cell(size(fnamesList,1),1);
set(handles.ImageList,'Data',new_table)
assignin('base','table',new_table)
assignin('base','fileInfo',fileInfo)
assignin('base','folder',folder)

% --- Executes on button press in Step2.
function Step2_Callback(hObject, eventdata, handles)
% hObject    handle to Step2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = evalin('base','folder');
new_table = evalin('base','table');

[fnames,folder] = uigetfile(strcat(folder,'*.CSV'),'Select CSV Correction File','MultiSelect','off');
if isequal(fnames,0)
    errordlg('Input file is not selected!') 
else
    M = readtable(strcat(folder,fnames),'Delimiter',','); % Skip the first row
    for l = 1: size(new_table,1)
        for i = 1:size(M,1)
            if strcmp(new_table(l,1), table2cell(M(i,1))) == 1 || strcmp(new_table(l,1), strcat(table2cell(M(i,1)),'.jpg')) == 1
                new_table(l,2) = cellstr(sprintf('%0.2f',cell2mat(table2cell(M(i,2)))));
            else
                continue
            end
        end
    end
    
    %Assign final variables to workspace & update GUI
    set(handles.ImageList,'Data',new_table)
    assignin('base','table',new_table);
end

function EM_All_Callback(hObject, eventdata, handles)
% hObject    handle to EM_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EM_All as text
%        str2double(get(hObject,'String')) returns contents of EM_All as a double


% --- Executes during object creation, after setting all properties.
function EM_All_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EM_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Step5.
function Step5_Callback(hObject, eventdata, handles)
% hObject    handle to Step5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileInfo = evalin('base','fileInfo');
folder = evalin('base','folder');
table = get(handles.ImageList,'Data'); 

for img = 1: size(fileInfo,2) %loop through images    
   
    % Step 2: Assigning emissivity values to classified image and Downwelling Radiance
    imgEmis = zeros(fileInfo{img}.height,fileInfo{img}.width);
    imgEmis(:,:) = str2num(get(handles.EM_All,'String')); % Assigning emissivity values to class 'NPV'
    sig = (5.670373*1e-08); % Stefen boltzmen constant
    
    % Step 2: Get correction factors from table
    ldw = str2num(cell2mat(table(img,2))); % Down welling radiance. It should be change according to the Radiometer reading at time of Image acquisition

    % Step 3: Calculate Exitance of image (assuming blackbody aka emissivity of 1)
    % Code for Dar's Exitance Images and Intermediate Temperature Products
    imgTempUnCor = (fileInfo{img}.B./log(fileInfo{img}.R1./(fileInfo{img}.R2.*(fileInfo{img}.data + fileInfo{img}.O))+fileInfo{img}.F));
    imgExitBB = (sig*((imgTempUnCor).^4)); % Exitance calculated from Temperature at BlackBody
    imgExit95Emiss = imgExitBB - ((1-0.95)*ldw); % Exitance calculated from Temperature at 0.95 Emissivity
    imgExitSurfEmiss = (imgExitBB -((1-imgEmis).*ldw)); % Retriving surface Exitance using pixel based emissivity and correcting for DWR 
    imgTemp95Emiss = (imgExitBB/(sig*0.95)).^0.25; % Retriving surface temperature using 0.95 Emissivity
    imgTempSurfEmiss = (imgExitSurfEmiss./(imgEmis.*sig)).^0.25; % Surface Temperature using pixel based emissivity and applying DWR corrections
    
    %Get Temperature Stats 
    tempStats(img,:) = [mean(mean(imgTempSurfEmiss)),min(min(imgTempSurfEmiss)),max(max(imgTempSurfEmiss)), ...
        mean(mean(imgExitBB)),min(min(imgExitBB)),max(max(imgExitBB)), ...
        mean(mean(imgExit95Emiss)),min(min(imgExit95Emiss)),max(max(imgExit95Emiss)), ...
        mean(mean(imgExitSurfEmiss)),min(min(imgExitSurfEmiss)),max(max(imgExitSurfEmiss)), ...
        mean(mean(imgTempUnCor)),min(min(imgTempUnCor)),max(max(imgTempUnCor)), ...
        mean(mean(imgTemp95Emiss)),min(min(imgTemp95Emiss)),max(max(imgTemp95Emiss))];
        
    %DISPLAY Temp Correction RESULTS
    %figuring out cmin and cmax for color bar
    if min(min(imgTempUnCor)) < min(min(imgTempSurfEmiss))
        cmin = min(min(imgTempUnCor));
    else
        cmin = min(min(imgTempSurfEmiss));
    end
    if max(max(imgTempUnCor)) > max(max(imgTempSurfEmiss))
        cmax = max(max(imgTempUnCor));
    else
        cmax = max(max(imgTempSurfEmiss));
    end
    
    %Plot original temperature image
    figure('units','normalized','outerposition',[0 0 1 0.75])
    subplot(1,2,1)%Original Image
    hold on
    ind = strfind(fileInfo{img}.name,'\\') + 2;
    titleName = fileInfo{img}.name(ind:end-4);
    title([titleName,' Original'],'Interpreter','none')
    imagesc(imgTempUnCor);
    colormap 'hot'
    cmap = colormap();
    caxis([cmin, cmax])
    h1 = colorbar;
    axis square; axis off
    hold off
    
    %Plot Temperature correction image
    subplot(1,2,2) %Temperature Correction
    hold on
    title([titleName, ' Temp Correction'],'Interpreter','none')
    imagesc(imgTempSurfEmiss); %Display image with scaled colors
    colormap 'hot'
    caxis([cmin, cmax])
    h2 = colorbar;
    axis square; axis off
    hold on
    
    %Save Temperature file TO Temp Folder
    cflder = strcat(fileInfo{img}.name(1:ind-2), '\Temp_Correction\');
    if isdir(cflder)== 0 %If the directory doesn't exist make it
        mkdir(cflder)
    end
    
    % Output Temperature results
    saveas(gca, strcat(cflder,titleName,'_Temp_Orig&Cor.jpg'))
    fname = strcat(cflder,titleName,'_Temp');
    csvwrite(strcat(fname,'.csv'),imgTempSurfEmiss)
    outImage = mat2gray(round(imgTempSurfEmiss),[min(min(imgTempSurfEmiss)) max(max(imgTempSurfEmiss))]);
    imwrite(outImage,strcat(fname,'.jpg'));
    
    %Output Exitance results
    fname = strcat(cflder,titleName,'_Exitance');
    csvwrite(strcat(fname,'.csv'),imgExitSurfEmiss)
    outImage = mat2gray(round(imgExitSurfEmiss),[min(min(imgExitSurfEmiss)) max(max(imgExitSurfEmiss))]);
    imwrite(outImage,strcat(fname,'.jpg'));
    
    if get(handles.check_BBExit,'value') == 1 %If the user designated they want the Blackbody exitance image, save it
        fname = strcat(cflder,titleName,'_BBExitance');
        csvwrite(strcat(fname,'.csv'),imgExitBB)
        outImage = mat2gray(round(imgExitBB),[min(min(imgExitBB)) max(max(imgExitBB))]);
        imwrite(outImage,strcat(fname,'.jpg'));
    end
    if get(handles.check_95Exit,'value') == 1 %If the user designated they want the 0.95 emissivity exitance image, save it
        fname = strcat(cflder,titleName,'_95Exitance');
        csvwrite(strcat(fname,'.csv'),imgExit95Emiss)
        outImage = mat2gray(round(imgExit95Emiss),[min(min(imgExit95Emiss)) max(max(imgExit95Emiss))]);
        imwrite(outImage,strcat(fname,'.jpg'));    
    end
    if get(handles.check_BBTemp,'value') == 1 %If the user designated they want the Blackbody temp image, save it
        fname = strcat(cflder,titleName,'_BBTemp');
        csvwrite(strcat(fname,'.csv'),imgTempUnCor)
        outImage = mat2gray(round(imgTempUnCor),[min(min(imgTempUnCor)) max(max(imgTempUnCor))]);
        imwrite(outImage,strcat(fname,'.jpg'));    
    end
    if get(handles.check_95Temp,'value') == 1 %If the user designated they want the 0.95 emissivity temperature image, save it
        fname = strcat(cflder,titleName,'_95Temp');
        csvwrite(strcat(fname,'.csv'),imgTemp95Emiss)
        outImage = mat2gray(round(imgTemp95Emiss),[min(min(imgTemp95Emiss)) max(max(imgTemp95Emiss))]);
        imwrite(outImage,strcat(fname,'.jpg'));      
    end
    
    % Construct a questdlg with three options
    choice = questdlg('Correct next image?', 'Continue?', 'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            close Figure 1
            continue
        case 'No'
            close Figure 1
            break
    end
end

%Output Temperature Results
outputFile = strcat(folder,'temperature_correction_stats_',datestr(now,'ddmmmyy'),'.csv');
[fileout,path] = uiputfile(outputFile,'Save temperature correction results');
fid = fopen([path,char(fileout)],'w');
fprintf(fid,['Filename, Avg Temperature for Corrected Image, Min Temperature for Corrected Image, Max Temperature for Corrected Image,' ...
    'Avg Exitance for BB, Min Exitance for BB, Max Exitance for BB,' ...
    'Avg Exitance for 0.95 Emissivity, Min Exitance for 0.95 Emissivity, Max Exitance for 0.95 Emissivity,' ...
    'Avg Exitance for Class Emissivity, Min Exitance for Class Emissivity, Max Exitance for Class Emissivity,' ...
    'Avg Temperature for BB, Min Temperature for BB, Max Temperature for BB,'...
    'Avg Temperature for 0.95 Emissivity, Min Temperature for 0.95 Emissivity, Max Temperature for 0.95 Emissivity \n']);
for i = 1:size(fileInfo,2)
    fprintf(fid,'%s%s',char(fileInfo{i}.name),',');
    fprintf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f',tempStats(i,:));
    fprintf(fid,'\n');
end
fclose(fid);
msgbox('Completed processing.','Done!')

% --- Executes on button press in check_BBExit.
function check_BBExit_Callback(hObject, eventdata, handles)
% hObject    handle to check_BBExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_BBExit

% --- Executes on button press in check_BBExit.
function check_BBTemp_Callback(hObject, eventdata, handles)
% hObject    handle to check_BBExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_BBExit


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImageList,'Data',cell(4,5))
evalin('base','clear fileInfo')
set(handles.check_BBExit,'value',0) 
set(handles.check_95Exit,'value',0)
set(handles.check_BBTemp,'value',0)
set(handles.check_95Temp,'value',0)



% --- Executes on button press in check_95Exit.
function check_95Exit_Callback(hObject, eventdata, handles)
% hObject    handle to check_95Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_95Exit


% --- Executes on button press in check_95Temp.
function check_95Temp_Callback(hObject, eventdata, handles)
% hObject    handle to check_95Temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_95Temp


% --- Executes during object deletion, before destroying properties.
function ImageList_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
