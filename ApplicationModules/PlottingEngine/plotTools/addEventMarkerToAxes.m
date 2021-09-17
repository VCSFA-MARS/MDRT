function addEventMarkerToAxes

hf = gcf;
hax = gca;

%% Make Time Marker

lx = mean(hax.XLim);

hMark = line(   [lx lx],                hax.YLim, ...
                'Color',                'red', ...
                'LineWidth',            3, ...
                'ButtonDownFcn',        @startDragFcn);
            
hf.WindowButtonUpFcn = @stopDragFcn;




    function startDragFcn(varargin)
        hf.WindowButtonMotionFcn = @draggingFcn;
        hf.WindowButtonUpFcn = @stopDragFcn;
    end

    function stopDragFcn(varargin)
        hf.WindowButtonMotionFcn = '';
    end

    function draggingFcn(varargin)
        pt = get(hax, 'CurrentPoint');
        set(hMark, 'XData', pt(1)*[1 1]);
%         updateGUIfromTime(pt(1));
        
        
    end






end