function useSelectedEvent( hobj, event )

hs = getappdata(gcf, 'hs');

newMilestones = [];

for val = hs.events.Value
    
    timeString = hs.events.String{val};
    cctDateStamp = timeString(1:24);
    eventTime = makeMatlabTimeVector({cctDateStamp}, false, false);
    
    fdString = hs.master.String{hs.master.Value};
    fdHumanReadable = hs.infoString.String;
    
    if isempty(fdHumanReadable)
        fdHumanReadable = fdString;
    end
    
    newMilestone  = struct(     'String',       fdHumanReadable, ...
                                'FD',           fdString, ...
                                'Time',         eventTime);
    
	if numel(newMilestones)                        
        newMilestones = vertcat(newMilestones, newMilestone);
    else
        newMilestones = newMilestone; 
    end
	
	
end

% Instantiate a default milestone struct
% -------------------------------------------------------------------------


                        
milestones = getappdata(gcf, 'milestones');

if numel(milestones)                        
    milestones = vertcat(milestones, newMilestones);
    
else
    milestones = newMilestones; 
end

                       

setappdata(gcf, 'milestones', milestones);

hs.milestones.String = {milestones.String}';

end

