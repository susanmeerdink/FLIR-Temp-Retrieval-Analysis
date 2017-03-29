% run this script after 'irFileOpen' function.
% This script is to specify some variable that are used in function "integer2temp".

global fileInfo
fileInfo.data=fileInfo.overlayDefaultThermal; % TIR data is replace with the overlaping portion of TIR data.
fileInfo.width=160;
fileInfo.height=120;
