function filteredList = AnyRowContaining(masterList, filterTokens)
% AnyRowContaining expects two cell arrays. 
%  masterList is a column array
%  filterTokens is a row array
%  returns masterList unfiltered if filterTokens is empty


if isempty(filterTokens)
    filteredList = masterList;
    return
end

SystemFilterMap = struct( ...
    'RP1', {{'RP1', 'FLS'}}, ...
    'LO2', {{'LO2', 'LOLS'}}, ...
    'LN2', {{'LN2', 'LNSS'}}, ...
    'GHE', {{'GHE', 'HLS'}}, ...
    'GN2', {{'GN2', 'NLS'}}, ...
    'ECS', {{'ECS', 'AIR'}}, ...
    'WDS', {{'WDS'}}, ...
    'HSS', {{'HSS'}} ...
);

searchToks = {};

for n = 1:numel(filterTokens)
    searchToks = horzcat(searchToks, SystemFilterMap.(filterTokens{n}));
end


% start with empty match index variable
ind = true(size(masterList, 1), length(searchToks));

% create an index of matches for each token
% -------------------------------------------------------------

for i = 1:numel(searchToks)
    ind(:,i) = cellfun(@(x)( ~isempty(x) ), ...
           regexpi(masterList, searchToks{i}));
end

% combine matches (and searching, not or)
ind = any(ind,2);

filteredList = masterList(ind);