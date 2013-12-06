function [simDataArray,P,temp] = performMCMCSimulation(origData,origLength,limit,dividedData,...
    order,simLength,numStates,sampleSelected,onePeriodRangeArray,stateRangeArray,...
    stateWidth,oneYearRangeArray)
    
    simDataArray = cell(1,13);
    if(sampleSelected ~= 1)
        simDataArray = cell(1,1);
    end

    %create progress bar
    progressbar('Simulating...');
    step = 0;
    
    maxState = max(ceil(origData/stateWidth));
    for k = 1:limit
        %create cumulative transition matrix
        [P,C,temp,mat,columnLength] = createTransitionMatrices(stateWidth,...
            dividedData,order,maxState,k,onePeriodRangeArray, sampleSelected);
        %simulate the data
        [simulatedData, step] = simulateData(simLength,stateRangeArray,numStates,C,mat,...
            columnLength,dividedData,step,k,order,origData,origLength,oneYearRangeArray,sampleSelected);
        simDataArray{k} = simulatedData; %#ok<AGROW>
        
    end
    simDataArray{limit+1} = [];
    
    % close progressbar
    progressbar(1);

end