function [ output_args ] = debugmode( varargin )
%debugmode toggles the debugOutput environment variable for debugout
%
%   debugmode
%   debugmode(true)
%   debugmode(1)
%
%   Calling debugmode with no argument prints the current debugging mode to
%   the Command Window.
%
%   Calling debugmode with a boolean (or 1 or 0) argument sets the debug
%   mode by setting the environment variable.
%
%   Accepts:
%
%   Boolean (logicals) true, false, 1, 0
%
%   Strings 'on', 'off', 'true', 'false', 'yes', 'no'
%
%   Counts, VCSFA 2016

setting = 'false';

if nargin == 0
    % no argument displays the current setting
    
    if isempty( getenv('debugOutput') )
        setenv('debugOutput', 'false');
    end
    
    fprintf( '<strong>debugmode:</strong> %s\n', getenv('debugOutput') );
    
    return
    
elseif nargin == 1
    
    trueFalse = varargin{1};
    
    switch class(varargin{1})
        
        case {'logical' 'double'}
            
            if trueFalse(1)
                setting = 'true';
                
            else
                % defaults to turn off
            end
            
        case {'char'}
            
            if isequal(varargin{1}, 'on')
                setting = 'true';
            elseif isequal(varargin{1}, 'yes')
                setting = 'true';
            elseif isequal(varargin{1}, 'true')
                setting = 'true';
            elseif isequal(varargin{1}, 'off')
                setting = 'false';
            elseif isequal(varargin{1}, 'no')
                setting = 'false';
            elseif isequal(varargin{1}, 'false')
                setting = 'false';
            else
                warning( ['debugmode() does not support the argument ' varargin{1}]);
                return
            end
                
                
        otherwise
            
            % A case we don't support!
            warning( ['debugmode() does not support arguments of type: ' class(trueFalse)]);
            return
    end
            


end

setenv('debugOutput', setting);
debugout('Debugging output is active');
end

