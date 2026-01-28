classdef ProcessProgress < handle
    %ProcessProgress manages progress updates for complex, multi-step
    %processes.
    
    properties
        mBars = [];
        mTitles = {};
        master_id = 0;
        prog_bar = false;
    end

    properties (Dependent)
        dBarPercent;
        dTotalPercent;
    end

    methods
        function obj = ProcessProgress(overallTitle)
            %ProcessProgress constructor. Give all the progress bar names
            %and their max values. 
            obj.mTitles = {overallTitle};
            obj.master_id = obj.add_child_bar(overallTitle, 1);
        end

        function show_bar(self)
            progressbar(self.mTitles{:})
            self.prog_bar = true;
            self.update_percentages()
        end

        function bar_id = add_child_bar(obj, progress_title, total_work)
            this_bar = obj.new_config(progress_title, total_work);
            obj.mBars = vertcat(obj.mBars, this_bar);
            obj.mTitles = {obj.mBars.Title};
            bar_id = numel(obj.mTitles);
        end

        function set_completed(obj, progress_id, total_completed)
            obj.mBars(progress_id).CurrentValue = total_completed;
            obj.update_percentages();
        end

        function add_to_completed(obj, progress_id, new_progress)
            current = obj.mBars(progress_id).CurrentValue;
            obj.mBars(progress_id).CurrentValue = current + new_progress;
            obj.update_percentages();
        end

        function new_max_for_bar(self, progress_id, new_max)
            self.mBars(progress_id).MaxValue = new_max;
            self.mBars(progress_id).CurrentValue = 0;
        end

        function update_percentages(self)
            num_bars = numel(self.mBars);
            pcts = repmat({0},1, num_bars);
            last_pct = 0;
            for n = num_bars:-1:1
                child_contribution = (1/self.mBars(n).MaxValue) * last_pct;
                this_pct = (self.mBars(n).CurrentValue ) ...
                    / self.mBars(n).MaxValue + child_contribution;
                pcts{n} = this_pct;
                last_pct = this_pct;
            end
            debugout(pcts)
            if self.prog_bar & any(cell2mat(pcts))
                progressbar(pcts{:})
            end
        end

    end

    methods (Static)
        function progress_struct = new_config(progress_title, total_work)
            progress_struct = struct;
            progress_struct.Title = progress_title;
            progress_struct.MaxValue = total_work;
            progress_struct.CurrentValue = 0;
            progress_struct.Child = [];
        end

    end
end