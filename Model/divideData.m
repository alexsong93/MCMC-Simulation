function [numHoursArray,dividedData,dataForCapFactors,limit] = ...
    divideData(dividedData,Seasons,TimeOfDays,numPeriods,originalData,originalLength,sampleSelected)

    numHoursArray = zeros(1,12); %used for cap factors
    onePeriodRangeArray = zeros(1,12);
    index = 1;
    for i = 1:3
        for j = 1:4
            [dividedData{index}, numHours, onePeriodRange]  = ... 
                divideDataByPeriod(Seasons(i),TimeOfDays(j),numPeriods,originalData,originalLength);
            numHoursArray(index) = numHours;
            onePeriodRangeArray(index) = onePeriodRange;
            index = index + 1;
        end
    end
    dividedData{13} = originalData;
    dataForCapFactors = dividedData;

    if(sampleSelected ~= 1)
        dividedData = cell(1,1);
        dividedData{1} = originalData;
        limit = 1;
    else
        limit = numel(dividedData)-1;
    end


end