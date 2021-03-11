
function tsArray = getDataInTimeInterval(varargin)

    if nargin == 0
        start = datenum('04-17-2019 20:44:25');
        stop = datenum('04-17-2019 20:46:07');        
    elseif nargin == 2
        start = varargin{1};
        stop  = varargin{2};
    else
        warning('Expects arguments (start, stop)');
        return
    end

    
    

    config = getConfig;

    filesInFolder = dir(fullfile(config.dataFolderPath, '*.mat'));

    tsArray = [];

    N = numel(filesInFolder);

    if N % Files are found!

        progressbar('Retrieving Available FDs');

        valveFDs {N,2} = '';

        for i = 1:N
            if ~ strcmpi(filesInFolder(i).name(1:2), '._') % Ignore weird system files hopefully

                F = load(fullfile(config.dataFolderPath, filesInFolder(i).name),'-mat');
                % disp(sprintf('%s',[fd.Type '-' fd.ID]))

                debugout(filesInFolder(i).name)

                if isfield(F, 'fd') % Make sure it's an FD
                    %if ~isempty(strfind(F.fd.FullString, 'Valve')) % Does name include valve?
                        
                        debugout(F.fd.FullString);
                        
                        ts = findDataInTimespan(F.fd.ts, [start stop]);
                        
                        if ~isempty(ts)
                            valveFDs{i,1} = sprintf('%s     %s',F.fd.ID, F.fd.FullString);
                            valveFDs{i,2} = filesInFolder(i).name;
                            tsArray = vertcat(tsArray, ts);
                        end
                    %end
                end
            end
            
            progressbar(i/N);
            
        end

        valveFDs = valveFDs(~cellfun('isempty',valveFDs));
        valveFDs = reshape(valveFDs,length(valveFDs)/2,2);

        % updateMetaDataFile(path, valveFDs);

    else % no files are found
        % return an empty cell

    end

end

%% Loop through valveFDs

function nts = findDataInTimespan(ts, timespan)

    ind = not(abs(sign(sign(timespan(1) - ts.Time) + sign(timespan(2) - ts.Time))));
    
    try
        % nts = ts.getsampleusingtime(timespan(1), timespan(2));
        ind = not(abs(sign(sign(timespan(1) - ts.Time) + sign(timespan(2) - ts.Time))));
    catch
        disp(sprintf('Skipping %s for non-unique data points', ts.Name))
        return
    end

    if max(ind)
        % found data in the time range
        % nts = ts.getsamples(ind);
        % nts.Name = ts.Name;
        
        i = find(ind, 1, 'first');
        j = find(ind, 1, 'last');
        
        if i ~= 1
            i = i - 1;
        end
        
        if j ~= numel(ind)
            j = j + 1;
        end
        
        
        try % this check fails on NaN values. Let's soft-fail and continue
            if ~(max( abs( diff( ts.Data(i:j)))) )
                nts = [];
                return;
            else
                nts = ts;
                return;
            end
        catch % Return empty set if unable to parse the ts.Data
            nts = [];
            return;
        end
        
    else
        nts = [];
    end
    
end

    function changed = didValueChange(ts)
        changed = false;
        keyboard
    end
















