locs = regexpi(contents, "temperatureDewPoint");

for n = 1:length(locs)
    strt = locs(n);
    stp  = locs(n) + 100;
    disp(contents(1,strt:stp))
end

%%

url = "https://www.wunderground.com/history/daily/us/va/wallops-island/KWAL/date/2024-3-24";

max_iterations = 20;

page = [];

progressbar('Loading Wunderground Historical Data')

for n = 1:max_iterations
    progressbar(n/max_iterations)
    page = webread(url);
    if ~ contains(page, "No Data Recorded")
        progressbar(1);
        break;
    end
    pause(1)
end




locs = regexpi(page, "Daily Observations");

for n = 1:length(locs)
    strt = locs(n);
    stp  = locs(n) + 100;
    disp(page(1,strt:stp))
end