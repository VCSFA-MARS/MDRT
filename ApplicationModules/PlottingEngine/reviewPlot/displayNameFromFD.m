function [ legendString ] = displayNameFromFD( FDstruct )
%displayNameFromFD generates a legend label string for a given FD Struct



% isValve = false;
% isSensor = false;
% isCommand = false;
% isMon = false;
% isState = false;

suffix='';

% switch FDstruct.Type
%     case {'PCVNO' 'PCVNC' 'DCVNC' 'DCVNO' 'RV'}
%         isValve = true;
%     case {'PT' 'TC' 'FM'}
%         isSensor = true;
%     otherwise
% end


if strfind(FDstruct.FullString, 'Param') suffix=' Cmd'    ; end
if strfind(FDstruct.FullString, 'State') suffix=' State'  ; end
if strfind(FDstruct.FullString, 'Mon')   suffix=''        ; end

legendString = strcat(FDstruct.Type, '-', FDstruct.ID, suffix);

if strcmp(legendString, '-')
    legendString = FDstruct.FullString;
end