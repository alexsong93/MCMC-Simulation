function [BIC,dividedData,simDataArray,stateRangeArray,cap_factors] = ...
    MCMC_Simul(data,order,numStates,intv,unit,simLength,origLength,...
    isLeap,leapValue,sampleSelected)

    %initialize variables
    [origData,maxData,stateWidth,stateRangeArray,numPeriods,Seasons,TimeOfDays] = ...
        initialize(data,numStates,intv,unit,sampleSelected,isLeap,leapValue);

    %divide the data into 12 if sample selection is specified (also used later for cap factors)
    [numHoursArray,dividedData,dataForCapFactors,limit] = ...
        divideData(Seasons,TimeOfDays,numPeriods,origData,origLength,sampleSelected);

    %perform MCMC simulation
    [simDataArray,P,temp] = ...
        performMCMCSimulation(origData,stateWidth,limit,dividedData,...
                              order,simLength,stateRangeArray,numStates,sampleSelected);
        
    %combine simulated data if sample selection was called    
    [simDataArray,dividedData] = ...
        combineData(simDataArray,simLength,numPeriods,...
                    origData,dividedData,sampleSelected);

    %calculate BIC (not fully implemented yet)
    BIC = calculateBIC(P,temp,numStates,order,origData);

    %calculate average annual capacity factors
    [cap_factors, simDataArray] = calculateCapFactors(dataForCapFactors,simDataArray,maxData,...
        numHoursArray,numPeriods,origLength,simLength,Seasons,TimeOfDays,sampleSelected);

end
