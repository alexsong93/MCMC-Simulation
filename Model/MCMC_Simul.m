function [BIC,dividedData,simDataArray,stateRangeArray,cap_factors] = ...
    MCMC_Simul(data,order,numStates,intv,unit,simulationLength,originalLength,...
    isLeap,yesSample)

originalData = csvread(data);

maxData = max(originalData);
stateWidth = maxData/numStates;
stateRangeArray = 0:stateWidth:maxData;

numPeriods = 0;
if(strcmp(unit,'minute(s)')==1), numPeriods = 60/intv;
elseif(strcmp(unit,'hour(s)')==1), numPeriods = 1/intv;
end

%remove feb 29th if leap year
if(isLeap==1)
     originalData(numPeriods*24*(31+28):(numPeriods*24*(31+29)-1)) = [];
end


progressbar('Simulating...');
step = 0;


%multiple original year..
%for hours, not just minutes
Seasons = cellstr(['Summer     ';'Spring/Fall';'Winter     ']);
TimeOfDays = cellstr(['Morning  ';'Afternoon';'Evening  ';'Night    ']);

dividedData = cell(1,13);
simDataArray = cell(1,13);

%divide the data into 12
numHoursArray = zeros(1,12);
index = 1;
for i = 1:3
    for j = 1:4
        [dividedData{index}, numHours]  = divideData(Seasons(i),TimeOfDays(j),...
            numPeriods,originalData,originalLength);
        numHoursArray(index) = numHours;
        index = index + 1;
    end
end
dividedData{13} = originalData;
dataForCapFactors = dividedData;

limit = 0;
if(yesSample ~= 1)
    dividedData = cell(1,1);
    dividedData{1} = originalData;
    simDataArray = cell(1,1);
    limit = 1;
else
    limit = numel(dividedData)-1;
end

maxState = max(ceil(originalData/stateWidth));
for k = 1:limit
    if(max(dividedData{k} < stateWidth*(maxState-1)))
         difference = (maxState-1)*stateWidth - max(dividedData{k}) + 1;
         index = find(dividedData{k}==max(dividedData{k}));
         dividedData{k}(index) = dividedData{k}(index) + difference;
    end
    %convert data into states
    stateArray = ceil(dividedData{k}/stateWidth);
    %if converted value is 0, change to 1;
    stateArray(stateArray==0) = 1;

    % extract contiguous sequences of n items from the above
    matrix = zeros(order,numel(stateArray(1:end-order)));
    for i=1:order
        matrix(i,1:end) = stateArray(i:end-(order-i+1));
    end
    ngrams = cellstr(num2str(matrix'));

    % create all possible combinations of the n items
    str1 = 'ndgrid(1:maxState';
    str2 = 'cellstr(num2str([out{1}(:)';
    for i = 1:order-1
        str1 = strcat(str1, ',1:maxState');
        str2 = strcat(str2, ',out{', num2str(i+1), '}(:)');
    end
    str1 = strcat(str1,')');
    str2 = strcat(str2,']))');
    out = {};
    for i = 1:order
        [out{1:order}] = eval(str1);
    end
    possibleCombinations = eval(str2);

    str = 'textscan(sprintf(''%s\n'',possibleCombinations{:}),''';
    for i = 1:order
        str = strcat(str,'%s');
    end
    str = strcat(str,''')');
    q = eval(str);
    mat = str2double([q{:}]);

    [g,~] = grp2idx([possibleCombinations;ngrams]);  % map ngrams to numbers starting from 1
    s1 = g(((maxState^order)+1):end);
    s2 = stateArray((order+1):end);          % items following the ngrams

    P = full(sparse(s1,s2,1,maxState^order,maxState));    
    temp = P;                       % trans matrix of frequencies (before dividing)

    dim = size(P);
    columnLength = dim(1);
    rowLength = dim(2);

    s = zeros(1,columnLength);
    for iter = 1:columnLength
        s(iter) = sum(P(iter,:));
    end

    for i = 1:columnLength
        for j = 1:rowLength
            if(s(i) == 0)
                break;
            end
            P(i,j) = P(i,j)./s(i);    %trans matrix of probabilities
        end
    end
    %   figure(2)
    %   spy(P,5)                        % uncomment to see sparsity of transition matrix

    % cumulative transition matrix
    C = zeros(size(P));
    for i = 1:columnLength
        for j = 1:rowLength
            C(i,j) = sum(P(i,1:j));
        end
    end

    %% Simulating Wind Data (Monte Carlo)
    simulatedDataLength = simulationLength*numel(dividedData{k});
    simulatedData = zeros(simulatedDataLength,1);
    startRow = randi([1,columnLength-1],1);
    %check if startRow is not all zeros
    while(isValid(startRow,C) == 0)
        startRow=randi([1,columnLength-1],1);
    end

    for i = 1:simulatedDataLength
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
        
        %progress bar
        step = step + 1;
        frac2 = step / simulationLength;
        frac1 = ((k-1) + frac2) / numel(originalData);
        if(mod(step,100)==0)
            progressbar(frac1);
        end
    end
    
    simDataArray{k} = simulatedData;
    
end   

%Combine data if sample selection is selected
if(yesSample==1)
    combinedSimData = combineSimData(simDataArray, simulationLength, numPeriods);
    simDataArray{end} = combinedSimData;
else
    dividedData = cell(1,13);
    dividedData{13} = originalData;
    simulatedData = simDataArray{1};
    simDataArray = cell(1,13);
    simDataArray{13} = simulatedData;
end




%% Calculating the Bayesian information criterion (BIC)
num_row = numel(P(1:end,1));
num_col = numel(P(1,1:end));

LL = 0;
for i = 1:num_row
    for j = 1:num_col
        if(P(i,j) == 0 || isnan(P(i,j)))
            continue;
        else
            LL = LL + temp(i,j).*log(P(i,j));       % log likelihood
        end
    end
end
phi = (numStates.^order).*(numStates-1);           % no. of independent parameters 
BIC = -2.*LL + phi.*log(numel(originalData));

% subtract back for negative numbers
%if(min_data < 0)
%    originalData = originalData - -1.*min_data;
%    simulatedData = simulatedData - -1.*min_data;
%    states = states - -1.*min_data;
%end

%% Calculate average annual capacity factor
cap_factors = zeros(6,12);

if(yesSample ~= 1)
    numHoursArray = zeros(1,12);
    index = 1;
    for i = 1:3
        for j = 1:4
            [simDataArray{index}, numHours]  = divideData(Seasons(i),TimeOfDays(j),...
                numPeriods,simulatedData,simulationLength);
            numHoursArray(index) = numHours;
            index = index + 1;
        end
    end
    simDataArray{13} = simulatedData;
end
index = 1;
for i = 1:2:5
    for j = 1:3:10
        orig_max = max(dataForCapFactors{index}/maxData);
        sim_max  = max(simDataArray{index}/maxData);
        orig_min = min(dataForCapFactors{index}/maxData);
        sim_min  = min(simDataArray{index}/maxData);
        orig_sum = sum(dataForCapFactors{index});
        sim_sum  = sum(simDataArray{index});
        orig_capfactor = orig_sum/(maxData*numHoursArray(index)*numPeriods*originalLength);
        sim_capfactor  = sim_sum/(maxData*numHoursArray(index)*numPeriods*simulationLength);
        
        cap_factors(i,j) = orig_capfactor;
        cap_factors(i,j+1) = orig_min;
        cap_factors(i,j+2) = orig_max;
        cap_factors(i+1,j) = sim_capfactor;
        cap_factors(i+1,j+1) = sim_min;
        cap_factors(i+1,j+2) = sim_max;
        
        index = index + 1;
    end
end

progressbar(1);
end
