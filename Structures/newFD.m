function [ fd ] = newFD( varargin )
%newFD returns an fd structure populated with blanks.
%
% newFD('FullString', 'My FD String')
%


FullString = '';

for i = 1:2:nargin
    key = lower(varargin{i});
    value = varargin{i + 1};
    switch key
        case {'fullstring', 'name'}
            mustBeTextScalar(key);
            FullString = value;
    end
end


%% Generate v1 FD Struct

fd = struct('ID',   '', ...
    'Type',         '', ...
    'System',       '', ...
    'FullString',   FullString, ...
    'ts',           [], ...
    'isValve',      false ...
    );


end
  
