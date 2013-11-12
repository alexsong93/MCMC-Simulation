function [simDataArray,dividedData] = combineData(simDataArray,simLength,...
    numPeriods,origData,dividedData,sampleSelected)

    %Combine data if sample selection is selected
    if(sampleSelected==1)
        combinedSimData = combineSimData(simDataArray, simLength, numPeriods);
        simDataArray{end} = combinedSimData;
    else
        dividedData = cell(1,13);
        dividedData{13} = origData;
        simulatedData = simDataArray{1};
        simDataArray = cell(1,13);
        simDataArray{13} = simulatedData;
    end
    
end