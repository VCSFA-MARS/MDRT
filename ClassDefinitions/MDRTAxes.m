classdef MDRTAxes < handle
    %MDRTAxes is the MDRT controlling object for MDRT Figure Axes
    %   MDRTAxes has methods to add, remove, and modify data plots
    

    properties
        hAx
        streams = {};
        yrange
    end
    
    properties (SetAccess = private)
        hLines = [];
    end
    
    properties (Hidden = true)
        colorInd = 1
        styleInd = 1
    end
    
    properties (Dependent)
        hLegend
        lineColorStyle
    end
        
    
    methods
        
        function self = MDRTAxes()
            % MDRTAxes() constructor. With no arguments, creates a single
            % MDRTAxes object (and stores the handle to the MATLAB axes
            % object)
            
            self.hAx = axes('Units','normalized', ...
                ... 'Position',[xPos yPos axwidth axheight], ...
                'XTickLabel','', ...
                'YTickLabel','', ...
                ... 'HitTest', 'off', ...
                'NextPlot', 'add', ...
                'XGrid','on', ...
                'XMinorGrid','on', ...
                'XMinorTick','on', ...
                'YGrid','on', ...
                'YMinorGrid','on', ...
                'YMinorTick','on', ...
                'YTickLabelMode', 'auto', ...
                'Box', 'on', ...
                'Tag', 'MDRTAxes');
            
        end
        
        %% Class Methods
        function addFD(self, fd)
            % addFD(fd) accepts an fd structure as an argument and plots
            % the FD.ts timeseries data to the axis, automatically
            % selecting the line style and retaining handles and data
            % stream "fullstrings"
            
            self.streams = vertcat(self.streams, fd.FullString);
            
            self.hLines = vertcat(self.hLines, ...
                stairs(self.hAx, fd.ts.Time, fd.ts.Data, ...
                        'displayname',  [fd.Type '-' fd.ID], ...
                        self.lineColorStyle{:} ) ...
                    );
        end
        
        function addFDfromFile(self, fileName)
            % addFD(fd) accepts an filename an argument, opens the file, 
            % loads the fd variable and plots the FD.ts timeseries data 
            % using addFD(fd) 

            if exist(fileName, 'file')
                variableInfo = who('-file', fileName);
                if ismember('fd', variableInfo)
                    s = load(fileName, '-mat');
                    self.addFD(s.fd);
                end
            end
        end
        
        %% Get Methods for Dependent Properties
        function lineColorStyle = get.lineColorStyle(self)
            % returns a cell array of name, value pairs for color and
            % linestyle. Automatically increments through all valid
            % combinations.
            %
            % Usage: plot(x, y, lineColorStyle{:})
            
            lineColors = {  [0 0 1],        [0 .5 0],       [.75 0 .75],...
                            [0 .75 .75],    [.68 .46 0]     };
            lineStyles = {'-','--',':'};
            
            lineColorStyle = { 'color',     lineColors{self.colorInd}, ...
                               'linestyle', lineStyles{self.styleInd} };
            
            % Increment Styles as needed
            self.colorInd = self.colorInd + 1;
            if (self.colorInd > length(lineColors))
                self.styleInd = self.styleInd + 1;
                self.colorInd = 1;
                if (self.styleInd > length(lineStyles))
                    self.styleInd = 1;
                    self.colorInd = 1;
                end
            end
        end
        
        function hLegend = get.hLegend(self)
            hLegend = legend(self.hAx, 'show');
        end
        
    end
    
end

