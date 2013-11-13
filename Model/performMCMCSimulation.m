function [simDataArray,P,temp] = performMCMCSimulation(origData,stateWidth,limit,dividedData,...
    order,simLength,stateRangeArray,numStates,sampleSelected)
    
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
            dividedData,order,maxState,k);
        %simulate the data
        [simulatedData, step] = simulateData(simLength,stateRangeArray,numStates,C,mat,...
            columnLength,dividedData,step,k,order,origData);
        simDataArray{k} = simulatedData; %#ok<AGROW>
        
        % subtract back for negative numbers
        %if(min_data < 0)
        %    originalData = originalData - -1.*min_data;
        %    simulatedData = simulatedData - -1.*min_data;
        %    states = states - -1.*min_data;
        %end
        
    end
    simDataArray{limit+1} = [];
    
    % close progressbar
    progressbar(1);

end