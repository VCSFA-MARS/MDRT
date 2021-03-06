function [ data ] = MDReadJSON( filename, varargin )
%MDReadJSON reads a JSON text file and returns a MATLAB object or variable

    data = loadjson( filename );

end