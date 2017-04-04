function [fnameUnix] = unixFN(filename)


fnameUnix = filename;
% Convert to ASCII code, then eliminate spaced
fnameCode = double(fnameUnix);
spaceLoc = find(fnameCode == 32); % find spaces in the directory name
if ~isempty(spaceLoc)
    for ii = length(spaceLoc):-1:1
        fnameUnix = strcat(fnameUnix(1:spaceLoc(ii)-1),'[[:space:]]',fnameUnix(spaceLoc(ii)+1:end));
    end
end
% Convert to ASCII code, then eliminate left parentheses
fnameCode = double(fnameUnix);
lparenLoc = find(fnameCode == 40); % find left parentheses in the directory name
if ~isempty(lparenLoc)
    for ii = length(lparenLoc):-1:1
        fnameUnix = strcat(fnameUnix(1:lparenLoc(ii)-1),'\',fnameUnix(lparenLoc(ii):end));
    end
end
% Convert to ASCII code, then eliminate right parentheses
fnameCode = double(fnameUnix);
rparenLoc = find(fnameCode == 41); % find right parentheses in the directory name
if ~isempty(rparenLoc)
    for ii = length(rparenLoc):-1:1
        fnameUnix = strcat(fnameUnix(1:rparenLoc(ii)-1),'\',fnameUnix(rparenLoc(ii):end));
    end
end