function [simulatedData,step] = simulateData(simLength,stateRangeArray,numStates,C,...
    mat,columnLength,dividedData,step,k,order,origData,oneYearRangeArray)
    
    simulatedDataLength = simLength*oneYearRangeArray(k);
    simulatedData = zeros(simulatedDataLength,1);
    startRow = randi([1,columnLength-1],1);
    
    %check if startRow is not all zeros
%     while(isValid(startRow,C) == 0)
%         startRow=randi([1,columnLength-1],1);
%     end
    
    %startRow = 1;

    for i = 1:simulatedDataLength
        if(isValid(startRow,C) == 0)
%             disp(k + ': all zeros...');
%             while(isValid(startRow,C) == 0)
%                 startRow=randi([1,columnLength-1],1);
%             end
        end
        nextState = sum(C(startRow,:) < rand(1,1)) + 1;
        simulatedData(i) = stateRangeArray(nextState) + ...
            (stateRangeArray(nextState+1) - stateRangeArray(nextState)).*rand(1,1);

        toAdd = 0;
        for j = order-1:-1:1
            toAdd = toAdd + (numStates.^j).*(nextState-1);
            nextState = mat(startRow,j+1);
        end

        if(order ~= 1), startRow = toAdd + mat(startRow,2);
        else startRow = nextState;
        end
        
                
        % update progress bar
        step = step + 1;
        frac2 = step / simLength;
        frac1 = ((k-1) + frac2) / numel(origData);
        if(mod(step,100)==0)
            progressbar(frac1);
        end
        
    end

end