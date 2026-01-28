function filterCell = UIGetSystemFilters()

hfig = [];
hcb = [];


    function makeUI()
        hfig = figure;
            hfig.Position(3:4) = [271, 271];
            hfig.Name = 'Valve Command Selection Filter';
            hfig.NumberTitle = 'off';
            hfig.MenuBar = 'none';
            hfig.ToolBar = 'none';

        checkboxes = {
            [ 30,  211,  201,   23], 'All valves'  ,'ALL', true;
            [ 30,  186,  201,   23], 'RP-1 Valves' ,'RP1', false;
            [ 30,  161,  201,   23], 'LO2 Valves'  ,'LO2', false;
            [ 30,  136,  201,   23], 'LN2 Valves'  ,'LN2', false;
            [ 30,  111,  201,   23], 'GHe Valves'  ,'GHE', false;
            [ 30,   86,  201,   23], 'GN2 Valves'  ,'GN2', false;
            [ 30,   61,  201,   23], 'ECS Valves'  ,'ECS', false;
            [ 30,   36,  201,   23], 'WDS Valves'  ,'WDS', false;
        };

        hcb = [];

        for i = 1:length(checkboxes)

            pos = checkboxes{i,1} + 15;
            label = checkboxes{i,2};
            tag = checkboxes{i,3};
            startValue = checkboxes{i,4};

            thisBox = uicontrol('Style', 'checkbox', ...
                                     'Position', pos, ...
                                     'String', label, ...
                                     'Value', startValue, ... 
                                     'Tag', tag );

            hcb = vertcat(hcb, thisBox);

        end

        hButton = uicontrol('style','pushbutton','units','pixels',...
                    'position',[40,10,100,30],'string','START',...
                    'callback',@go_button);

    end

    function go_button(~, ~) 

        if hcb(1).Value
            % No removal
            filters = {};
        else
            values = [hcb(:).Value];
            tags = {hcb(:).Tag};

            values(1) = [];
            tags(1) = [];

            filters = tags(logical(values));
        end

        filterCell = filters;
        hfig.delete

    end

makeUI()
uiwait(hfig)

end