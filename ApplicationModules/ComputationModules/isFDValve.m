function isValve = isFDValve(fd)
% isFDValve takes an FD structure or a filename and returns true if the fd
% is valve data. 

isValve = [];

switch class(fd)
    case 'struct'
        if strcmpi(checkStructureType(fd), 'fd')
            testStr = fd.ts.Name;
        else
            isValve = false
            return
        end
        
    case 'char'
        % filename passed as char array
        testStr = fd;
        
    case 'cell'
        % passed as cell array?
        testStr = fd{1};
        
    otherwise
        return
end
        
mustHave = {'Damper|Positioner|Valve|[D|P]CVN[OC]|RV'};
mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
excludeValves = { 'WDS PCR|Shut-Out'} ;

l_allValves = ~cellfun('isempty',regexp(testStr, mustHave));
l_toExclude = ~cellfun('isempty',regexp(testStr, mustNotHave));
l_notValves = ~cellfun('isempty',regexp(testStr, excludeValves));

isValve = l_allValves & ~l_toExclude & ~l_notValves;