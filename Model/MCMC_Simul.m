function [BIC,dividedData,simDataArray,stateRangeArray,cap_factors] = ...
    MCMC_Simul(data,order,numStates,intv,unit,simLength,origLength,...
    isLeap,leapValue,sampleSelected)

    %initialize variables
    [origData,numPeriods,Seasons,TimeOfDays,stateRangeArray,stateWidth,maxData] = ...
        initialize(data,intv,unit,numStates,sampleSelected,isLeap,leapValue);

    %divide the data into 12 if sample selection is specified (also used later for cap factors)
    [numHoursArray,dividedData,dataForCapFactors,limit,onePeriodRangeArray,oneYearRangeArray] = ...
        divideData(Seasons,TimeOfDays,numPeriods,origData,origLength,sampleSelected,order);

    %perform MCMC simulation
    [simDataArray,P,temp] = ...
        performMCMCSimulation(origData,origLength,limit,dividedData,order,simLength,numStates,...
                              sampleSelected,onePeriodRangeArray,stateRangeArray,...
                                  stateWidth,oneYearRangeArray);
        
    %combine simulated data if sample selection was called    
    [simDataArray,dividedData] = ...
        combineData(simDataArray,simLength,numPeriods,...
                    origData,dividedData,sampleSelected);

    %calculate BIC (not fully implemented yet)
    BIC = calculateBIC(P,temp,numStates,order,origData);

    %calculate average annual capacity factors
    [cap_factors, simDataArray] = calculateCapFactors(dataForCapFactors,simDataArray,maxData,...
        numHoursArray,numPeriods,origLength,simLength,Seasons,TimeOfDays,sampleSelected,order);

end
