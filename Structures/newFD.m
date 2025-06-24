function [ fd ] = newFD( varargin )
%newFD returns an fd structure populated with blanks.
%
% newFD('version', 'v1')
% newFD('FullString', 'My FD String')
%
% if no version argument is passed, newFD() defaults to the latest version.
% version arguments:
%     "v1" : original version. MDRT treats FD structs without the version field
%            as version 1.
%     "v2":  version 2, stores Time and Data vector in the main struct for
%            compatability with python/scipy for importing. Also allows
%            better importing efficiency for large files.

SUPPORTED_VERSIONS = {'v1', 'v2'};
LATEST_VERSION = 'v2';

version = LATEST_VERSION;
FullString = '';

for i = 1:2:nargin
    key = lower(varargin{i});
    value = varargin{i + 1};
    switch key
        case 'fullstring'
            mustBeTextScalar(key);
            FullString = value;
        case 'version'
            assert(ismember(value, SUPPORTED_VERSIONS))
            version = value;     
    end
end


%% Generate v1 FD Struct

fd = struct('ID',           '',...
    'Type',         '', ...
    'System',       '', ...
    'FullString',   FullString,...
    'ts',           [],...
    'isValve',      false, ...
    'version',      version);

%% Generate v2 Struct

fd.Data = [];
fd.Time = [];
fd.Units = '';


end
  
