function [ availFDs, timespan, varargout ] = indexTimeAndFDNames( path, prog_bar_parent )
%indexTimeAndFDNames 
%
%   [ availFDs, timespan ] =indexTimeAndFDNames( path )
%
%       path is a string and should be a well formed directory string.
%       now checks to be sure there is an fd structure in the variable
%       before populating the list. Also cleans any empty cells.
%
%   Returns an N x 2 cell array of strings:
%
%       'FD1 name' 'fdFileName1.mat'
%       'FD2 name' 'fdFileName2.mat'
%           ...         ...
%       'FDN name' 'fdFileNameN.mat'
%
%   Returns a 1 x 2 matrix of datenums
%
%       [firstDataPointTimestamp, lastDataPointTimestamp]
%
%   This function is now cross-platform compatible
%
%   N. Counts, Spaceport Support Services, 2017

% Default value for prog_bar_parent for back-compatability
if nargin == 1
  prog_bar_parent = [];
end

    filesOfType = dir( fullfile( path, '*.mat') );
    
    N = numel(filesOfType);
    
    availFDs = {};
    timespan = [];
    timeCell = zeros(N, 2);

    
    if N % Files are found!
    
        pb = make_progress_bar('Retrieving Available FDs', prog_bar_parent);

        availFDs {N,2} = '';

        for i = 1:N
            
            if ~ strcmpi(filesOfType(i).name(1:2), '._') % Ignore weird system files hopefully
                % disp(sprintf('%s ',filesOfType(i).name));

                % TODO: Fix error case where file is named *.mat but is NOT 
                % a -mat file. Loader quits with an error

                F = load( fullfile(path, filesOfType(i).name),'-mat');
                % disp(sprintf('%s',[fd.Type '-' fd.ID]))
                                
                debugout(filesOfType(i).name);

                if isfield(F, 'fd')
                    % we loaded a structure called fd

                    availFDs{i,1} = F.fd.FullString;
                    availFDs{i,2} = filesOfType(i).name;
                    
                    % Legacy support for combined valve data.
                    if isfield(F.fd, 'position') && ~isempty(F.fd.position.Time);
                        thisTimeSpan = [F.fd.position.Time(1), F.fd.position.Time(end)];
                        timeCell(i, :) = thisTimeSpan;
                        
                    elseif ~isempty(F.fd.ts.Time) > 0
                        thisTimeSpan = [F.fd.ts.Time(1), F.fd.ts.Time(end)];
                        timeCell(i, :) = thisTimeSpan;
                        
                    else % If we fell through here, then it's an empty ts
                        thisTimeSpan = [];
                    end
                    
                    if isempty(timespan)
                        timespan = thisTimeSpan;
                    end
                    
                    timespan(1) = min( min(timespan), min(thisTimeSpan) );
                    timespan(2) = max( max(timespan), max(thisTimeSpan) );

                end
                
            end

            update_progress(pb, i/N, filesOfType(i).name);

        end

        availFDs = availFDs(~cellfun('isempty',availFDs));

        availFDs = reshape(availFDs,length(availFDs)/2,2);
        
        if nargout == 3
            varargout(1) = {timeCell};
        end
    
    else % no files are found
        % return an empty cell
        
    end
        
  function pb = make_progress_bar(message, parent)
    pb = [];

    if isempty(parent)
      progressbar(message);
    else
      pb = uiprogressdlg(parent, 'Title', 'Indexing Selected Data Set');
    end
  end


  function update_progress(pb, percent, message)
    if nargin < 3
      message = '';
    end

    if isempty(pb)
      progressbar(percent);
      return
    end

    pb.Value = percent;
    
    if ~isempty(message)
      pb.Message = message;
    end

  end


end

