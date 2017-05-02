function val = readIRheaderblock(fname,start,address,addressType,dataType,endian)
%READIRHEADERBLOCK Reads single typed value from a FLIR camera image file
% (*.seq or *.jpg)
%
% VAL = READIRHEADERBLOCK(FNAME,START,ADDRESS,TYPEOFADDRESS,DATATYPE)
%
% FNAME - file name to read from
% START - starting block address
% ADDRESS - data address relative to starting block address
% TYPEOFADRESS - data address type:
%   'h' - hexadecimal,
%   'd' - decimal
% DATATYPE - data type: 'f' = 32-bit float, 'u8' = 8-bit unsigned integer,
%   'u16' = 16-bit unsigned integer, 'u32' = 32-bit unsigned integer,
%   'i8' = 8-bit signed integer, 'i16' = 16-bit signed integer,
%   'i32' = 32-bit signed integer, 's16' = 8 character string,
%   's32' = 16 character string, 's64' = 32 character string
% VAL - converted value read from data file (integer, float, string, etc.)
%
% ------------------------------------------------------------------------
% Adapted from code copyrighted in 2008 by Sebastian Dudzik 
% (sebdud@el.pcz.czest.pl).  Code provided in Infrared Thermography: Errors
% and Uncertainties, by Waldemar Minkina and Sebastian Dudzik.
% ------------------------------------------------------------------------
%   Written by Donald M. Aubrecht
%   version 2
%   19 August 2014
%
%   Notes
%       v1 (30 April 2014)
%       v2 (19 August 2014)
%           - endian-ness can be specified in function call
% ------------------------------------------------------------------------

% Open file, read only
fid = fopen(fname,'r','l');

% Convert data address to decimal increments
if strcmp(addressType,'h')
    blockAddress = start+hex2dec(address);
elseif strcmp(addressType,'d')
    blockAddress = start+address;
end

% Determine type and size of date block to read, then read data
if strcmp(dataType,'f')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'float32',0,endian);
elseif strcmp(dataType,'u8')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'uint8',0,endian);
elseif strcmp(dataType,'u16')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'uint16',0,endian);
elseif strcmp(dataType,'u32')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'uint32',0,endian);
elseif strcmp(dataType,'i8')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'int8',0,endian);
elseif strcmp(dataType,'i16')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'int16',0,endian);
elseif strcmp(dataType,'i32')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,1,'int32',0,endian);
elseif strcmp(dataType,'s16')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,8,'char',0,endian);
elseif strcmp(dataType,'s32')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,16,'char',0,endian);
elseif strcmp(dataType,'s64')
    status = fseek(fid,blockAddress,'bof');
    [val,count] = fread(fid,32,'char',0,endian);
end

% Close file
status = fclose(fid);