function [ runTime ] = integrateRunTime( databrush, unit )
%integrateRunTime ( data, 'unit' )
%   integrates the output of data brush variables for a total run time.
%   Assumes values of 1 = on and 0 = off.
%
%   Note: this is equivalent to square wave integration (by rectangle)
%
%   Intended as helper function when looking at plotted data. 
%       1) Select data with data brush and export as a variable 
%          (i.e. databrush). 
%       
%       2) call integrateRunTime(databrush, 'hour') to calculate the run
%          time in hours
%
%   Standard abbreviations for day, minute, hour and second are
%   implemented.
%
%   unit    corresponds to the unit of time in the data. Unrecognized unit
%           strings default to 'days'
%
%   Counts, 04-06-22 - Virginia Commercial Spaceflight Authority

if numel(databrush) < 3
    runTime = 0;
    return
end

unit = lower(unit);
switch unit
    case {'gpm' 'm' 'min' 'minute' 'gal/m' 'gal/min' 'gallons per minute' 'cfm' 'scfm'}
        % set timestep as one minute.
        deltat = 0.000694444;
    case {'gph' 'hr' 'hour' 'gal/h' 'gal/hr' 'gallons per hour'}
        % set timestep as one hour.
        deltat = 0.041666667;
    case {'gps' 's' 'sec' 'second' 'gal/s' 'gal/sec' 'gal/second' 'gallons per second'}
        deltat = 0.000011574;
    case {'day', '1/day', 'd'}
        deltat = 1;
    otherwise
        % assume time step is one day
        disp(sprintf('Unsupported unit ''%s''. Defaulting to 1/day', unit));
        deltat = 1;
end


tdiff = diff(databrush(:,1));
data  = [tdiff, databrush(1:end-1, 2)];

runTime = sum(prod(data, 2)) / deltat;
