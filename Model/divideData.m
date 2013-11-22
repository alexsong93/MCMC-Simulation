function [numHoursArray,dividedData,dataForCapFactors,limit,onePeriodRangeArray,oneYearRangeArray] = ...
    divideData(Seasons,TimeOfDays,numPeriods,data,dataLength,sampleSelected,order)

    dividedData = cell(1,13);
    numHoursArray = zeros(1,12); %used for cap factors
    onePeriodRangeArray = zeros(1,12);
    oneYearRangeArray = zeros(1,12);
    index = 1;
    for i = 1:3
        for j = 1:4
            [dividedData{index}, numHours, onePeriodRange, oneYearRange]  = ... 
                divideDataByPeriod(Seasons(i),TimeOfDays(j),numPeriods,data,dataLength,order);
            numHoursArray(index) = numHours;
            onePeriodRangeArray(index) = onePeriodRange;
            oneYearRangeArray(index) = oneYearRange;
            index = index + 1;
        end
    end
    dividedData{13} = data;
    dataForCapFactors = dividedData;
    limit = numel(dividedData)-1;
        
    if(sampleSelected ~= 1)
        dividedData = cell(1,1);
        dividedData{1} = data;
        limit = 1;    
    end

end