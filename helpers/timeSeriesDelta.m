function newTs = timeSeriesDelta(ts1, ts2)
% generates a timeseries that is the difference between the `Data` vector
% from both ts1 and ts2. The `Time` vector is the combination of each
% timeseries, and any missing points are interpolated.

newTs = addsample(ts1, 'Data', ts2.Data, 'Time', ts2.Time);
newTime = newTs.Time;

warning off
ts1 = ts1.resample(newTime);
ts2 = ts2.resample(newTime);
warning on

newTs = ts1 - ts2;