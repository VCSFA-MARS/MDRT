
function valveFDs = findValveChange
    hf = figure;
    
    start = datenum('11-02-2019 13:50:00')
    stop = datenum('11-02-2019 14:20:00')

    config = getConfig;

    filesInFolder = dir(fullfile(config.dataFolderPath, '*.mat'));

    valveFDs = {};

    N = numel(filesInFolder);

    if N % Files are found!

        progressbar('Retrieving Available FDs');

        valveFDs {N,2} = '';

        for i = 1:N
            if ~ strcmpi(filesInFolder(i).name(1:2), '._') % Ignore weird system files hopefully

                F = load(fullfile(config.dataFolderPath, filesInFolder(i).name),'-mat');
                % disp(sprintf('%s',[fd.Type '-' fd.ID]))

                debugout(filesInFolder(i).name)

                if ( isfield(F, 'fd') && isfield(F.fd, 'isValve') )
                    if ~isempty(strfind(F.fd.FullString, 'Valve'))
                        
                        debugout(F.fd.FullString);
                        
                        ts = findDataInTimespan(F.fd.ts, [start stop]);
                        
                        if ~isempty(ts)
                            valveFDs{i,1} = sprintf('%s     %s',F.fd.ID, F.fd.FullString);
                            valveFDs{i,2} = filesInFolder(i).name;
                        end
                    end
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
        nts = ts.getsamples(ind);
        nts.Name = ts.Name;
    else
        nts = [];
    end
end

function changed = didValueChange(ts)

changed = false;

keyboard


end
















