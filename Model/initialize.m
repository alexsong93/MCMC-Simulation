function [originalData,maxData,stateWidth,stateRangeArray,...
    numPeriods,Seasons,TimeOfDays,dividedData,simDataArray] = ...
    initialize(data,numStates,intv,unit,sampleSelected,isLeap,leapValue)

    originalData = csvread(data);
    maxData = max(originalData);
    stateWidth = maxData/numStates;
    stateRangeArray = 0:stateWidth:maxData;

    numPeriods = 0;
    if(strcmp(unit,'minute(s)')==1), numPeriods = 60/intv;
    elseif(strcmp(unit,'hour(s)')==1), numPeriods = 1/intv;
    end
    
    Seasons = cellstr(['Summer     ';'Spring/Fall';'Winter     ']);
    TimeOfDays = cellstr(['Morning  ';'Afternoon';'Evening  ';'Night    ']);
    dividedData = cell(1,13);
    simDataArray = cell(1,13);
    
    if(sampleSelected ~= 1)
        simDataArray = cell(1,1);
    end
    
    %convert leap years if a leap year exists
    originalData = convertLeapYear(isLeap,leapValue,originalData,numPeriods);
    
end