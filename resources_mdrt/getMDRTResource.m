function [ fullFilePath ] = getMDRTResource( resourceName )
%getMDRTResource returns a full filename and path to an MDRT resource file
%   getMDRTResource is the deployment safe way to access application images and
%   other resource files



if isdeployed
    rootPath = fullfile(ctfroot, 'resources_mdrt');
else
    rootPath = fileparts(which('getMDRTResource.m'));
end

% TODO: Check for non-image resources and look in the appropriate location

if endsWith(resourceName, '.xlsx')
  fullFilePath = fullfile(rootPath, 'spreadsheets', resourceName);
  return;
end

fullFilePath = fullfile(rootPath, 'images', resourceName);

end

