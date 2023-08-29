function [ lineCount ] = getFileLineCount( fileNameAndPath )
%getFileLineCount returns the number of lines in a file
%   Returns the number of lines in a data file.
%   Is now platform independant with two methods for windows machines. If
%   the command line option fails, uses a perl script as a fallback.
%
% Counts, Spaceport Support Services, 2014, 2023


% -------------------------------------------------------------------------
fid = fopen(fullfile(fileNameAndPath));


    unixFileNameAndPath = fileNameAndPath;
    unixFileNameAndPath = regexprep(unixFileNameAndPath, '\s','\\ ');


if (isunix) %# Linux, mac
    [~, result] = system( ['wc -l ', unixFileNameAndPath] );
    numlines = textscan(result, '%s %*s');
    lineCount = str2num(numlines{1}{1});
    
elseif (ispc) %# Windows
    try
        [status, cmdout] = system(['find /c /v "" ', filename]);
        if(status~=1)
            scanCell = textscan(cmdout,'%s %s %u');
            lineCount = scanCell{3};
            disp(['Found ', num2str(lineCount), ' lines in the file']);
        else
            disp('Unable to determine number of lines in the file');
        end
        
    catch
        lineCount = str2num( perl('countlines.pl', 'your_file') );
    end

else
    error('...');

end




% where 'countlines.pl' is a perl script, containing
% 
% while (<>) {};
% print $.,"\n";









% Close the file
    fclose(fid);


end

