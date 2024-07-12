function [ lineCount ] = getFileLineCount( fileNameAndPath )
%getFileLineCount returns the number of lines in a file
%   Returns the number of lines in a data file.
%   Is now platform independant with two methods for windows machines. If
%   the command line option fails, uses a perl script as a fallback.
%
%   fileNameAndPath can be a str or the fid of an open file
%
% Counts, Spaceport Support Services, 2014, 2023


% -------------------------------------------------------------------------

if isnumeric(fileNameAndPath)
    % convert fid to path
    fileNameAndPath = fopen(fileNameAndPath);
end


if (isunix) %# Linux, mac

    unixFileNameAndPath = fileNameAndPath;
    unixFileNameAndPath = regexprep(unixFileNameAndPath, '\s','\\ ');

    [~, result] = system( ['wc -l ', unixFileNameAndPath] );
    numlines = textscan(result, '%s %*s');
    lineCount = str2num(numlines{1}{1});
    
elseif (ispc) %# Windows
    try
        [status, cmdout] = system(['find /c /v "" ', fileNameAndPath]);
        if(status~=1)
            scanCell = textscan(cmdout,'%s %s %u');
            lineCount = scanCell{3};
            disp(['Found ', num2str(lineCount), ' lines in the file']);
        else
            disp('Unable to determine number of lines in the file');
        end
        
    catch
        lineCount = str2num( perl('countlines.pl', fileNameAndPath) );
        debugout("try/catch failed - falling back to perl script")
    end

else
    error('...');

end



end

