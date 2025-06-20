function [ structureTypeString ] = checkStructureType( testVariable )
%CHECKSTRUCTURETYPE returns a string with the name of the structure tested
%
%   Valid structure return strings
%
%   fd
%   graph
%   timeline
%   metadata
%   config
%   searchResult
%   masterFDList
%
%   Will return an empty string if no match. Extra fields will not falsify
%   the check. The prototype (makeStructure) fields must ALL be present.
%
%       EXAMPLE: 
% 
%       checkStructureType( newGraphStructure )
% 
%       returns:
% 
%       ans =
% 
%       graph
% 
%
%   This function uses the prototype definition functions to generate the
%   test conditions. It does not require updating unless a new structure
%   prototype is added. Existing prototype functions can be modified and
%   this test will continue to work.
%
%   Counts - 2016, VCSFA
%   Pruce  - 7-14-16, VCFSA


%% Instantiate variables for use in the function

structureTypeString = [];



fdPrototype             = newFD;
fd1Prototype            = newFD('version', 'v1'); % Legacy FD Support
fd2Prototype            = newFD('version', 'v2'); % Legacy FD Support
graphPrototype          = newGraphStructure;
timelinePrototype       = newTimelineStructure;
metadataPrototype       = newMetaDataStructure;
configPrototype         = newConfig;
searchResultPrototype   = newSearchResult;
masterFDListPrototype   = newMasterFDListStruct;

% Legacy FD support - remove optional 'version' field from v1
fd1Prototype = rmfield(fd1Prototype, 'version');

% Create a cell array where each row is {'structure name', {'field list'}}

prototypes = {  'fd',           fieldnames(fdPrototype)';
                'fd1',          fieldnames(fd1Prototype)';
                'fd2',          fieldnames(fd2Prototype)';
                'graph',        fieldnames(graphPrototype)';
                'timeline',     fieldnames(timelinePrototype)';
                'metadata',     fieldnames(metadataPrototype)';
                'config',       fieldnames(configPrototype)';
                'searchResult', fieldnames(searchResultPrototype)';
                'masterFDList', fieldnames(masterFDListPrototype)'};
            
            
%% Check each structure type
%
% This test requires that all prototype structure fields are present to
% validate a structure. Additional fields may be present and are not
% checked

    
    % Only test if testVariable is a structure (this method is actually
    % robust to non-structure variables being passed. This is not required)
%     
%     switch nargin
%         case 0 
%             return
%             
    
    if nargin == 0
        return
    end

    if ~isstruct(testVariable)
        return
    end
        
            
    for n = 1:length(prototypes)
        proto_str = prototypes{n,1};
        this_proto = prototypes{n,2};
    
    
    % Using switch statement for readability - lots of duplicated code
    % here.
    
    % TODO: change this to automatically return the structure type using
    % the prototypes cell array?
        
        switch proto_str
            case {'fd', 'fd1', 'fd2'}
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'fd';
                    break 
                end

            case 'graph'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'graph';
                    break
                end

            case 'timeline'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'timeline';
                    break
                end

            case 'metadata'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'metadata';
                    break
                end
                
            case 'config'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'config';
                    break
                end
                
            case 'searchResult'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'searchResult';
                    break
                end
            case 'masterFDList'
                if doesVariableHaveAllFields(testVariable, this_proto)
                    structureTypeString = 'masterFDList';
                    break
                end

            otherwise
                % Why did I include this case? Probably nothing to do here
        end


    end


end



            

function allFieldsMatch = doesVariableHaveAllFields(testVar, fieldList)

    allFieldsMatch = true;
    
    for i = 1:numel(fieldList)
        
        % Use multiply to falsify the allFieldsMatch flag if any field is
        % missing

        allFieldsMatch = allFieldsMatch * isfield(testVar, fieldList{i});
        
    end

end


