function ValveTimingProcessFunc(MasterStructure)

% This function comprises the computational processes involved in valve
% timing calculations on Pad 0C.
%
% Input...
%   -> MasterStructure
%       -> structure containing I/O Code Numbers and their associated time 
%          series data sets
%       -> formatting is significant...
%           -> 1st Column: titled 'Code', contains I/O Code numbers
%           -> 2nd Column: titled 'TimeSeries', contains time series data 
%                          sets associated with each I/O Code
%       -> attained as output of ValveTimingInputFunc.m
%
% Output...
%   -> writes valve timing results and any discovered errors to a
%      pre-formatted Excel worksheet; this worksheet is then saved to the
%      folder
% -------------------------------------------------------------------------




% -------------------------------------------------------------------------
% We close the function.
% -------------------------------------------------------------------------
end
% -------------------------------------------------------------------------