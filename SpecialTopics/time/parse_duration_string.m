function duration = parse_duration_string(str)
%parse_duration_string returns a datetime value corresponding to the time
% interval in the string
%   Supports the following formats:
%       '1:12:15'   - 1 hour, 12 minutes, 15 seconds
%       '1d 3hr'    - 1 day, 3 hours
%  
%   Duration markers
%       Y / yr(s)       - year
%       M / month(s)    - months
%       d / day(s)      - day
%       h / hr(s)       - hour
%       m / min(s)      - minute
%       s / sec(s)      - second
%
%   Returns 0 if unparsable

duration = 0;
str = lower(str);

% Check for colon-separation:
if contains(str, ':')
    toks = split(str, ':');
    time_nums = flip(cellfun(@str2num, toks)');
    if numel(time_nums) < 6
        time_nums(1,6) = 0;
        % seconds ... years
    end

    time_nums = flip(time_nums);
    % time_nums = [ y m H M S ]
    time_nums = num2cell(time_nums);
    
    try
        duration = datenum( time_nums{1,:});
    catch
        fprintf('Unsupported duration string: %s\n', str)
    end
    return
else
    % Assume using d/h/m/s style strings
    abbrevs = {
        'Y', {'y', 'yr', 'yrs', 'year', 'YEAR', 'years', 'YEARS', 'Years', 'Year'};
        'M', {'Month', 'MONTH', 'months', 'month', 'Months', 'MONTHS'};
        'D', {'d', 'day', 'DAY', 'Day', 'days', 'Days', 'DAYS'};
        'h', {'H', 'hr', 'hrs', 'hour', 'hours'};
        'm', {'min', 'mins', 'minute', 'minutes'};
        's', {'S', 'sec', 'SEC', 'second', 'seconds'};
     };

    date_args = struct;

    for n = 1:size(abbrevs,1)
        key_str = abbrevs{n,1};
        valid_strs = strjoin(horzcat(abbrevs{n,:}), '|');
        pat = strcat('([\d\.]*)\s?(?=', valid_strs, ')');

        match_str = regexp(str, pat, 'match');
        if isempty(match_str)
            match_str = '0';
        else
            match_str = match_str{1};
        end

        try
            match_val = str2num(match_str);
        catch
            match_val = 0;
            fprintf('Unable to convert matched string %s for %s', ... 
                match_str, key_str);
        end
        
        date_args.(key_str) = match_val;
     
    end
    
    duration = datenum( date_args.Y, date_args.M, date_args.D, ...
                        date_args.h, date_args.m, date_args.s);
end


end
