% function [BIC,originalData,simulatedData,stateRangeArray,cap_factors] = ...
%     MCMC_Simul(data,order,numStates,intv,unit,simulationLength)

simulationLength = 5;
numStates = 20;
order = 3;
originalData = csvread('WindPower2005.csv');
simulatedDataLength = simulationLength*numel(originalData);
simulatedData = zeros(simulatedDataLength,1);

maxData = max(originalData);
stateWidth = maxData/numStates;
stateRangeArray = 0:stateWidth:maxData;

%% transition matrix for higher order Markov chain    
%convert original data into states
stateArray = ceil(originalData/stateWidth);
%if converted value is 0, change to 1;
stateArray(stateArray==0) = 1;
maxState = max(stateArray);

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
startRow = randi([1,columnLength-1],1);
%check if startRow is not all zeros
if(C(startRow,:)==0)
    out = 0;
else
    out = 1;
end
while(out == 0)
    startRow=randi([1,columnLength-1],1);
    if(C(startRow,:)==0)
        out = 0;
    else
        out = 1;
    end
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

% % Calculate average annual capacity factor
% cap_factors = [6,12];
% Seasons = cellstr(['Summer     ';'Spring/Fall';'Winter     ']);
% TimeOfDays = cellstr(['Morning  ';'Afternoon';'Evening  ';'Night    ']);
% 
% numPeriods = 0;
% if(strcmp(unit,'minute(s)')==1)
%     numPeriods = 60/intv;
% elseif(strcmp(unit,'hour(s)')==1)
%     numPeriods = 1/intv;
% end
% 
% index = 1;
% for i = 1:2:6
%     count = 1;
%     for j = 1:3:10
%         [orig_capfactor,sim_capfactor,orig_max,sim_max,orig_min,sim_min] = ...
%         calcCapFactors(Seasons(index),TimeOfDays(count),false,numPeriods,...
%                         maxData,originalData,simulatedData);
%         cap_factors(i,j) = orig_capfactor;
%         cap_factors(i,j+1) = orig_min;
%         cap_factors(i,j+2) = orig_max;
%         cap_factors(i+1,j) = sim_capfactor;
%         cap_factors(i+1,j+1) = sim_min;
%         cap_factors(i+1,j+2) = sim_max;
%         count = count + 1;
%     end
%     index = index + 1;
% end
% 

%end





% function [orig_capfactor,sim_capfactor,orig_max,sim_max,orig_min,sim_min] = ...
%     calcCapFactors(season,timeOfDay,isLeap,numPeriods,max_data,data_orig,data_simul)
% % calculate the annual average capacity factors for different time of the
% % day for different seasons
% 
%     orig = data_orig';
%     sim = data_simul';
%     numerator_orig = [];
%     numerator_sim = [];
%     
%     % check season
%     begin = 0; numDays = 0;  numHours = 0;
%     if(strcmp(season,'Summer') == 1)
%         if(isLeap == true)
%             begin = 121;
%         else
%             begin = 120;
%         end
%         numDays = 153;
%         if(strcmp(timeOfDay,'Morning'))
%             numHours = 1071;
%         elseif(strcmp(timeOfDay,'Afternoon'))
%             numHours = 765;
%         elseif(strcmp(timeOfDay,'Evening'))
%             numHours = 612;
%         elseif(strcmp(timeOfDay,'Night'))
%             numHours = 1224;
%         end
%     elseif(strcmp(season,'Spring/Fall') == 1)
%         if(isLeap == true)
%             begin = 91;
%         else
%             begin = 90;
%         end
%         numDays = 61;
%         if(strcmp(timeOfDay,'Morning'))
%             numHours = 427;
%         elseif(strcmp(timeOfDay,'Afternoon'))
%             numHours = 305;
%         elseif(strcmp(timeOfDay,'Evening'))
%             numHours = 244;
%         elseif(strcmp(timeOfDay,'Night'))
%             numHours = 488;
%         end
%     elseif(strcmp(season,'Winter') == 1)
%         if(isLeap == true)
%             begin = 305;
%         else
%             begin = 304;
%         end
%         numDays = 151;
%         if(strcmp(timeOfDay,'Morning'))
%             numHours = 1057;
%         elseif(strcmp(timeOfDay,'Afternoon'))
%             numHours = 755;
%         elseif(strcmp(timeOfDay,'Evening'))
%             numHours = 604;
%         elseif(strcmp(timeOfDay,'Night'))
%             numHours = 1208;
%         end
%     end
%     
%     % check time of day
%     timeBegin = 0; timeEnd = 0; timeToNext = 0;
%     if(strcmp(timeOfDay,'Morning'))
%         timeBegin = 6;
%         timeEnd = 7;
%         timeToNext = 17*numPeriods + 1;
%     elseif(strcmp(timeOfDay,'Afternoon'))
%         timeBegin = 13;
%         timeEnd = 5;
%         timeToNext = 19*numPeriods + 1;
%     elseif(strcmp(timeOfDay,'Evening'))
%         timeBegin = 18;
%         timeEnd = 4;
%         timeToNext = 20*numPeriods + 1;
%     elseif(strcmp(timeOfDay,'Night'))
%         timeBegin = 22;
%         timeEnd = 8;
%         timeToNext = 16*numPeriods + 1;
%     end
%     
%     % perform calculations
%     start_index = (begin*24*numPeriods)+(numPeriods*timeBegin);
%     end_index = start_index + numPeriods*timeEnd - 1;
%     numerator_orig(1,1:numPeriods*timeEnd) = orig(1,start_index:end_index);
%     numerator_sim(1,1:numPeriods*timeEnd) = sim(1,start_index:end_index);
%     
%     if(strcmp(season,'Summer'))
%         for i = 2:numDays
%             start_index = end_index + timeToNext;      
%             end_index = start_index + numPeriods*timeEnd - 1;
%             numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%             numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         end
%         
%     elseif(strcmp(season,'Spring/Fall'))
%         for i = 2:30
%             start_index = end_index + timeToNext;      
%             end_index = start_index + numPeriods*timeEnd - 1;
%             numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%             numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         end
%         start_index = (212*24*numPeriods) + numPeriods*timeBegin;
%         end_index = start_index + numPeriods*timeEnd - 1;
%         numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%         numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         for i = 2:31
%             start_index = end_index + timeToNext;      
%             end_index = start_index + numPeriods*timeEnd - 1;
%             numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%             numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         end
%         
%     elseif(strcmp(season,'Winter'))
%         for i = 2:60
%             start_index = end_index + timeToNext;      
%             end_index = start_index + numPeriods*timeEnd - 1;
%             numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%             numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         end
%         start_index = numPeriods*timeBegin;
%         end_index = start_index + numPeriods*timeEnd - 1;
%         numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%         numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         for i = 2:90
%             start_index = end_index + timeToNext;      
%             end_index = start_index + numPeriods*timeEnd - 1;
%             numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
%             numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
%         end
%     end
%     orig_max = max(numerator_orig/max_data);
%     sim_max = max(numerator_sim/max_data);
%     orig_min = min(numerator_orig/max_data);
%     sim_min = min(numerator_sim/max_data);
%     orig_sum = sum(numerator_orig);
%     sim_sum = sum(numerator_sim);
%     orig_capfactor = orig_sum/(max_data*numHours*numPeriods);
%     sim_capfactor = sim_sum/(max_data*numHours*numPeriods);
% end
