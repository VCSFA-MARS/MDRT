function [ fullFilePath ] = getMDRTResource( resourceName, options )
%getMDRTResource returns a full filename and path to an MDRT resource file
%   getMDRTResource is the deployment safe way to access application images and
%   other resource files
%
%   The default 'ResourceType' is 'image', and returns a match if found in the 
%   '[resources_root]/images' folder
% 
%   'ResourceType'    = {'image', 'icon', 'excel'}

arguments
  resourceName (1,:) char
  options.ResourceType (1,:) char {mustBeMember(options.ResourceType, {'image', 'excel', 'icon'})} = 'image'
end


if isdeployed
    rootPath = fullfile(ctfroot, 'resources_mdrt');
else
    rootPath = fileparts(which('getMDRTResource.m'));
end

% TODO: Check for non-image resources and look in the appropriate location

switch options.ResourceType
  case 'image'
    fullFilePath = fullfile(rootPath, 'images', resourceName);

  case 'icon'
    fullFilePath = fullfile(rootPath, 'icons', resourceName);

  case 'badge'
    fullFilePath = fullfile(rootPath, 'icon', resourceName);

  case 'excel'
    fullFilePath = fullfile(rootPath, 'spreadsheets', resourceName);

end

% if endsWith(resourceName, '.xlsx')
%   fullFilePath = fullfile(rootPath, 'spreadsheets', resourceName);
%   return;
% end
%
% fullFilePath = fullfile(rootPath, 'images', resourceName);

end

