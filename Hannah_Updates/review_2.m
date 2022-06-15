%% REVIEW 2 ELECTRIC BOOGALOO
%   VCSFA 2022, Hannah Johnson - Intern based on code by Nick Counts
%   
%   ABANDON HOPE ALL YE WHO VENTURE HERE
%
%   //NOTES//
%       -This is the main function dealing with the GUI, it houses all the
%       other functions the GUI uses to do its magic



function varargout = review_2(varargin)
%% Knock, Knock, Housekeeping!
%general clean/organization stuff

clc %clears command window
clear %clears workspace

close all hidden %prevents tab clutter
    %closes any open figures (including hidden ones)
    % Usually I would use close all instead but that command doesn't close
    % hidden figures.
    % .mlapp figures are automatically set as hidden since their
    % HandleVisibility is set to "callback"

%% GUI CALLreview_2


run('updateGUI_v_2022.mlapp');

end