function is_newer = matlab_newer_than(ver)
%% matlab_newer_than returns a logical if the matlab runtime is newer than the version argument.
%
%   matlab_newer_than(2014)     % Check by year as a numeric
%   matlab_newer_than('r2017a') % Check by release name
%   matlab_newer_than('9.11')   % Check by version number
%
%   Current version will run back to 2006, but is only accurate back to
%   2008 (when the rXXXXa release scheme started).
%

% Counts, 2025


[v,d] = version();

this_year = str2double(d(end-3:end));
this_rel = v(end-6:end-1);

[~, ~, ~, vstr] = regexp(v, '^\d+.\d+');
this_ver = str2double(vstr);


% release = { ...
%     'r2008a', 'r2008b', 'r2009a', 'r2009b', 'r2010a', 'r2010b', ...
%     'r2011a', 'r2011b', 'r2012a', 'r2012b', 'r2013a', 'r2013b', ...
%     'r2014a', 'r2014b', 'r2015a', 'r2015b', 'r2016a', 'r2016b', ...
%     'r2017a', 'r2017b', 'r2018a', 'r2018b', 'r2019a', 'r2019b', ...
%     'r2020a', 'r2020b', 'r2021a', 'r2021b', 'r2022a', 'r2022b', ...
%     'r2023a', 'r2023b', 'r2024a', 'r2024b', 'r2025a'};
% 
% release = string(release);
% 
% version = {
%     7.6, 7.7, 7.8, 7.9, 7.1, 7.11, 7.12, 7.13, 7.14, 8, 8.1, 8.2, ...
%     8.3, 8.4, 8.5, 8.6, 9, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, ...
%     9.9, 9.1, 9.11, 9.12, 9.13, 9.14, 23.2, 24.1, 24.2, 25.1 };
% 
% year = {2008, 2008, 2009, 2009, 2010, 2010, 2011, 2011, 2012, 2012, ...
%     2013, 2013, 2014, 2014, 2015, 2015, 2016, 2016, 2017, 2017, 2018, ...
%     2018, 2019, 2019, 2020, 2020, 2021, 2021, 2022, 2022, 2023, 2023, ...
%     2024, 2024, 2025 };
% 
% ver_table = table(release, version, year);


switch class(ver)
    case 'double'
        if ver < 1000
            is_newer = check_by_version(ver);
        else
            is_newer = check_by_year(ver);
        end

    case 'char'
        is_newer = check_by_release(lower(ver));

    case 'string'
        is_newer = check_by_release(lower(ver));

    otherwise
        error('Expected version as char, string, or doulbe. Got %s', class(ver))
end

return 

    function is_newer = check_by_year(year)
        is_newer = this_year >= year;
    end

    function is_newer = check_by_version(ver)
        is_newer = this_ver >= ver;
    end

    function is_newer = check_by_release(rel)
        is_newer = string(lower(this_rel)) >= lower(rel);
    end

end