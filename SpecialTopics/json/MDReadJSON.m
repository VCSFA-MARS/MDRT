function [ data ] = MDReadJSON( filename, varargin )
%MDReadJSON reads a JSON text file and returns a MATLAB object or variable

%     if verLessThan('matlab', '9.1')
%     else   
%         % MATLAB builtin ?
%     end    

data = loadjson( filename, 'SimplifyCell',1 );

end