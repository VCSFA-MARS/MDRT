function [ is_folder ] = isfolder( folder )
%% Introduced in 2017b - used in recent MDRT Development
% This is added with a startup.m check to ensure backwards compatability
is_folder = exist(folder, 'dir') == 7;
end
