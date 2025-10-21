function status = pad_c_gn2_stats(hObj, event)
%% pad_c_gn2_stats 
% prints statistics for use in our overview plots.
% use data brushing and save as the default name 'brushedData'
% then execute the appropriate code block and paste into a text box

hPlotFig = hObj.Parent.Parent;
status = 0;

% Add listnener for auto-close when parent closes
el = addlistener(hPlotFig, 'Close', @callerClosed);

%% Populate little UI popup

GUI_TITLE = 'Pad-C GN2 Annotation Tool';
GUI_SIZE = [250, 250];
PARENT_POS = hPlotFig.Position(1:2);
PARENT_SIZE = hPlotFig.Position(3:4);
PARENT_MID = PARENT_SIZE /2;
GUI_MID = GUI_SIZE / 2;
GUI_OFFSET = PARENT_MID - GUI_MID;

GUI_POSITION = [PARENT_POS + GUI_OFFSET, GUI_SIZE];

hfig = figure('Position', GUI_POSITION,  'Resize','off');
    hfig.Name = GUI_TITLE;
    hfig.NumberTitle = 'off';
    hfig.MenuBar = 'none';
    hfig.ToolBar = 'none';
    hfig.Tag = 'pad_c_annotation_gui';

%% UI Generation

btn_center = uicontrol(hfig, 'Style', 'pushbutton', 'String', 'Snap to day',     'Position', [20, 10, 100, 30]);
btn_trend  = uicontrol(hfig, 'Style', 'pushbutton', 'String', 'Calculate Trend', 'Position', [20, 50, 100, 30]);
btn_flow   = uicontrol(hfig, 'Style', 'pushbutton', 'String', 'Calculate Flow',  'Position', [20, 90, 100, 30]);


btn_center.Callback = @snapToCenter;
btn_trend.Callback = @annotatePressureTrend;
btn_flow.Callback = @annotateFlow;

return




%% Snap Time Axes to center on a single day with 1 hr margin
    function snapToCenter(hObj, event)
        hax = findall(hPlotFig, 'tag', 'MDRTAxes');
        if isempty(hax)
            return
        end

        middle_time = mean(hax(1).XLim);
        day_start = floor(middle_time);
        oneHr = 1/24;

        set(hax, 'XLim', [day_start - oneHr, day_start + 1 + oneHr]);

        dynamicDateTicks(hax, 'link');
    end

%% Average consumption rate in psig
% 1) save brushed data as 'brushedData'
% 2) place and select a textbox above the brushed data
% 3) run this section of code
    function annotatePressureTrend(hObj, event)

        hl = findall(hPlotFig, 'Type', 'Stair'); % get all lines in plot
        l_ind = strcmpi({hl.DisplayName}, 'PT-5902'); %find MGPN2
        hl = hl(l_ind);
        if isempty(hl) % No plots for mpgn2
            disp('You must have an axis with PT-5902')
            return
        end
        
        hax = hl.Parent;
        bh = hl.BrushHandles;
        
        brushedIdx = logical(hl.BrushData);

        if ~any(brushedIdx) % no data have been brushed on 5902
            disp('No data have been brushed. Please use the brushing tool on 5902')
            return
        end

        % Get time and data vectors for brushed data. Also xLim for brushed
        brushedTime = hl.XData(brushedIdx)';
        brushedData = hl.YData(brushedIdx)';
        bXLim = [brushedTime(1), brushedTime(end)];
        bYlim = [min(brushedData), max(brushedData)];

        % Do Calculations and build string
        tm = trendMath([brushedTime, brushedData]);
        min_rate = tm.rate;
        hr_rate = min_rate * 60;
        day_rate = hr_rate * 60;

        box_str = {
            sprintf('%.3f psig/min', min_rate);
            sprintf('%.1f psig/hr' , hr_rate);
            sprintf('%.0f psig/day', day_rate);
        };

        htb = get_textbox_handle(hax, bXLim, bYlim);

        htb.String = box_str;
        htb.FitBoxToText = 'on';

    end

    function htb = get_textbox_handle(hAx, brush_xlim, brush_ylim)
        
        % if no tb on this axis, make one and return
        htb = findall(hAx.Parent, 'Type', 'TextBox');
        
        if isempty(htb)
            htb = make_textbox_in_brush(hAx, brush_xlim, brush_ylim);
            return
        end

        % if tb inside brushed data, return it
        for i = 1:numel(htb)
            this_tb = htb(i);
            if is_inside_brushing(this_tb, hAx, brush_xlim)
                htb = this_tb;
                return
            end
        end
        
        htb = make_textbox_in_brush(hAx, brush_xlim, brush_ylim);
        
    end

    function is_inside = is_inside_brushing(htb, hAx, bxlim)
        is_inside = false;

        n_tbXlim = [htb.Position(1), htb.Position(3) + htb.Position(1)];
        n_tbYlim = [htb.Position(2), htb.Position(4) + htb.Position(2)];

        % make normalized coords for brushed data
        n_bXlim = make_fig_x_normalized(bxlim, hAx);
        n_bYlim = make_fig_y_normalized(bxlim, hAx);

        if all(n_tbXlim <= max(n_bXlim)) && all(n_tbXlim >= min(n_bXlim))
            if all(n_tbYlim <= max(n_bYlim)) && all(n_tbYlim >= min(n_bYlim))
                            is_inside = true;
            end
        end
    end

    function norm = make_fig_x_normalized(x, hAx)
        %x vals as percent of ax width
        perc_ax = (x - hAx.XLim(1)) ./ abs(diff(hAx.XLim));
        
        %x vals as percent of ax container
        perc_fig = perc_ax .* hAx.Position(3);

        %x values to fig norm: apply ax offset
        norm = perc_fig + hAx.Position(1);
    end

    function norm = make_fig_y_normalized(y, hAx)
        %x vals as percent of ax height
        perc_ax = (y - hAx.YLim(1)) ./ abs(diff(hAx.YLim));
        
        %x vals as percent of ax container
        perc_fig = perc_ax .* hAx.Position(4);

        %x values to fig norm: apply ax offset
        norm = perc_fig + hAx.Position(2);
    end

    function htb = make_textbox_in_brush(hAx, bxlim, bylim)
        % get normal bounds of brushed data
        nxlim = make_fig_x_normalized(bxlim, hAx);
        nx_width = abs(diff(nxlim));
        nx_offset = nx_width * 0.025;

        % get normal bounds of axes y-coords
        n_ylim = [hAx.Position(2), hAx.Position(4) + hAx.Position(2)];
        n_y_height = abs(diff(n_ylim));
        n_box_height = n_y_height * 0.2; % 20% of axes height

        

        n_box_pos = [
            nxlim(1) + nx_offset, ...
            make_fig_y_normalized(max(bylim), hAx), ...
            0.05, ...
            n_box_height];

        htb = annotation(hAx.Parent, 'textbox', n_box_pos, 'String', '');

    end


    function annotateFlow(hObj, event)

        hl = findall(hPlotFig, 'Type', 'Stair'); % get all lines in plot
        l_ind = strcmpi({hl.DisplayName}, 'FM-5700'); %find Pac-0C FM
    
        hl = hl(l_ind);
        if isempty(hl) % No plots for mpgn2
            disp('You must have an axis with FM-5700')
            return
        end
        
        hAx = hl.Parent;
        bh = hl.BrushHandles;
        
        brushedIdx = logical(hl.BrushData);

        if ~any(brushedIdx) % no data have been brushed on 5700
            disp('No data have been brushed. Please use the brushing tool on 5700')
            return
        end

        % Get time and data vectors for brushed data. Also xLim for brushed
        brushedTime = hl.XData(brushedIdx)';
        brushedData = hl.YData(brushedIdx)';
        bXLim = [brushedTime(1), brushedTime(end)];
        bYlim = [min(brushedData), max(brushedData)];

        avg_flow = mean(brushedData);

        lbm_flowed = integrateTotalFlow(horzcat(brushedTime, brushedData), 's');
        scf_flowed = lbm_flowed * 13.803
        scl_flowed = lbm_flowed * 390.8
        
        mpv = 1800*2
        mol = 775645
        m_gn2 = 28.02
        kg_storage = mol * m_gn2 / 1000
        sprintf('%f', kg_storage)
        kg2scf = 30.42
        % 21733.572900 * kg2scf
        
        one_storage_scf = 21733.572900 * kg2scf
        perc = scf_flowed/one_storage_scf

        box_str = {
            sprintf('%.3f lbm/s average flow',       avg_flow);
            sprintf('%.0f lbm total flow',           lbm_flowed);
            sprintf('%.1f%% of total MPGN2 Storage', perc*100);
        };


        htb = get_textbox_handle(hAx, bXLim, bYlim);

        htb.String = box_str;
        htb.FitBoxToText = 'on';

    end



%% Flow Meter Consumption Data
% avg = mean(brushedData(:,2));
% lbm = integrateTotalFlow(brushedData, 's');
% scf = lbm * 13.803
% scl = lbm * 390.8
% 
% mpv = 1800*2
% mol = 775645
% m_gn2 = 28.02
% kg_storage = mol * m_gn2 / 1000
% sprintf('%f', kg_storage)
% kg2scf = 30.42
% 21733.572900 * kg2scf
% 
% one_storage_scf = 21733.572900 * kg2scf
% perc = scf/one_storage_scf
% 
% sprintf('%.3f lbm/s average flow\n%.0f lbm total flow\n%.1f%% of total MPGN2 Storage', avg, lbm, perc*100)

%% Update selected textbox




    % Cleanup: close tool when "parent" figure closes
    function callerClosed(~, ~, varargin)
        if hfig.isvalid
            close(hfig);
        end
    end
end