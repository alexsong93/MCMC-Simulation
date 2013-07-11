function [BIC,data_orig,data_simul,states,cap_factors] = MCMC_Simul(data,order,num,intv,unit,len)

%[BIC,data_orig,data_simul,states] = MCMC_Simul(data,order,num,len)     
%   This function takes in some time-series data and generates a simulation
%   of that data using the Markov Chain Monte Carlo (MCMC) technique. This
%   function should be used with the MCMC_pre and the GUI gui to see the
%   simulation visually using a simple UI.
%
%Inputs:
%   data  - original data (wind speeds, wind power, electricity prices, etc.)
%   order - order of the markov chain used to generate simulation
%   num   - number of states desired in the markov chain
%   intv  - time interval between each data point (eg. 1,10,etc.)
%   unit  - unit of each time interval (eg. min, hours, days)
%   len   - desired length of simulation
%
%Outputs:
%   BIC         - Bayesian information criterion
%   needed for GUI:
%   data_orig   - original data in csv form
%   data_simul  - simulated data
%   states      - the range of values for each state
%   cap_factors - average annual capacity factors for mornings, Afternoons,
%                 evenings, and Nights                  

% if(nargin~=6)                       % no/incorrect number of arguments
%     errordlg('Please input 6 arguments.');
% end

data_orig = csvread(data);         % original data in csv form
% calculate length of simulated data based on time interval and unit
% if(strcmp(unit,'minute(s)')==1)
%     %len = floor((525949*len)/intv);
% elseif(strcmp(unit,'hour(s)')==1)
%     %len = floor((8766*len)/intv);
% else
%     %len = floor((365*len)/intv);
% end
len = len*numel(data_orig);
simul_len = len;
data_simul=zeros(simul_len,1);

% account for negative values
min_data = min(data_orig);
if(min_data < 0)
    data_orig = data_orig + -1.*min_data;
end

max_data=max(data_orig);
numstates = num;
width_state = max_data/numstates;   % shows the range of values that make up one state
lim = width_state*numstates;
states = 0:width_state:lim;

%% transition matrix for first order markov chain
if(order == 1) 
    N = histc(data_orig,states);   
    P=zeros(numel(N));
    for iter=1:numel(data_orig)-1
        transit=data_orig(iter:iter+1);
        state1=floor(transit(1)/width_state);
        state2=floor(transit(2)/width_state);
        P(state1+1,state2+1)=P(state1+1,state2+1)+1;
    end
    temp = P;                       % trans matrix of frequencies (before dividing)
    last=data_orig(end);
    state_last=floor(last/width_state);
    N(state_last+1)=N(state_last+1)-1;

    for iter=1:numel(N)-1
        P(iter,1:end)=P(iter,1:end)./N(iter);    
    end
    P=P(1:end-1,1:end-1);
%   figure 
%   spy(P)                          % uncomment to see sparsity of transition matrix
    
% Cumulative transition matrix
    n=numel(P(1,1:end));
    C=zeros(size(P));
    for iter=1:n
        for iter1=1:n
            C(iter,iter1)=sum(P(iter,1:iter1));
        end
    end

%% transition matrix for higher order Markov chain    
else
    x=zeros(1,numel(data_orig));
    for iter1 = 1:numel(data_orig)     %make values into states
        if(data_orig(iter1)==0)
            state = 1;
        elseif(data_orig(iter1)==max_data)
            state = numstates;
        else
            state = ceil(data_orig(iter1)/width_state);
        end
        x(iter1) = state;
    end

    M = max(x);

    % extract contiguous sequences of n items from the above
    matrix = zeros(order,numel(x(1:end-order)));
    for i=1:order
        matrix(i,1:end) = x(i:end-(order-i+1));
    end
    ngrams = cellstr(num2str( matrix' ));
    
    % create all possible combinations of the n items
    str1 = 'ndgrid(1:M,1:M';
    str2 = 'cellstr(num2str([out{1}(:),out{2}(:)';
    for i = 2:order-1
        str1 = strcat(str1, ',1:M');
        str2 = strcat(str2, ',out{', num2str(i+1), '}(:)');
    end
    str1 = strcat(str1,')');
    str2 = strcat(str2,']))');
    out = {};
    for i = 1:order
        [out{1:order}] = eval(str1);
    end
    xy = eval(str2);
    
    str = 'textscan(sprintf(''%s\n'',xy{:}),''';
    for i=1:order
        str = strcat(str,'%s');
    end
    str = strcat(str,''')');
    q = eval(str);
    mat = [q{:}];
    
    [g,~] = grp2idx([xy;ngrams]);  % map ngrams to numbers starting from 1
    s1 = g(((M^order)+1):end);
    s2 = x((order+1):end);          % items following the ngrams
    
    P = full(sparse(s1,s2,1,M^order,M));    
    temp = P;                       % trans matrix of frequencies (before dividing)

    dim=size(P);
    col_len=dim(1);
    row_len=dim(2);

    s = zeros(1,col_len);
    for iter=1:col_len
        s(iter)=sum(P(iter,:));
    end

    for iter1=1:col_len
        for iter2=1:row_len
            if(s(iter1)==0)
                break;
            end
            P(iter1,iter2)=P(iter1,iter2)./s(iter1);    %trans matrix of probabilities
        end
    end
%   figure(2)
%   spy(P,5)                        % uncomment to see sparsity of transition matrix

%   cumulative transition matrix
    C=zeros(size(P));
    for iter1=1:col_len
        for iter2=1:row_len
            C(iter1,iter2)=sum(P(iter1,1:iter2));
        end
    end
end

%% Simulating Wind Data (Monte Carlo)
% for first order
if(order == 1) 
    start=randi([1,n-1],1);         % randomly choose wind state at hr 0
    chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
    data_simul(1)=chosen_value;

    % Simulation simul_len times
    for iter=2:simul_len
        u_rand = rand(1,1);
        next_state = 1;
        for j=1:n-1
            if(C(start,j) < u_rand && u_rand <= C(start,j+1))
                next_state = j+1;
            end
        end
        chosen_value=states(next_state) + (states(next_state+1)-...
                     states(next_state)).*rand(1,1);
        data_simul(iter)=chosen_value;
        start=next_state;
    end
    
% for higher order
else                                    
    start=randi([1,row_len-1],1);       % randomly choose wind state at hr 0
    chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
    data_simul(1)=chosen_value;

    start_row=randi([1,col_len-1],1);

    out = isValid(start_row,C); %check if start_row is not all zeros
    while(out==0)
        start_row=randi([1,col_len-1],1);
        out = isValid(start_row,C);
    end
    
    % Simulation simul_len times
    for iter=2:simul_len
        u_rand = rand(1,1);
        next_state = sum(C(start_row,:)<u_rand)+1;
        chosen_value=states(next_state) + (states(next_state+1)-...
                     states(next_state)).*rand(1,1);
        data_simul(iter)=chosen_value;
        toAdd = 0;
        for i = order-1:-1:1
            toAdd = toAdd + (numstates.^i).*(next_state-1);
            next_state = sscanf(mat{start_row,i+1},'%f');
        end
        toAdd = toAdd + sscanf(mat{start_row,2},'%f');
        start_row = toAdd;
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
phi = (numstates.^order).*(numstates-1);           % no. of independent parameters 
BIC = -2.*LL + phi.*log(numel(data_orig));

% subtract back for negative numbers
if(min_data < 0)
    data_orig = data_orig - -1.*min_data;
    data_simul = data_simul - -1.*min_data;
    states = states - -1.*min_data;
end

%% Calculate average annual capacity factor
cap_factors = [6,12];
Seasons = cellstr(['Summer     ';'Spring/Fall';'Winter     ']);
TimeOfDays = cellstr(['Morning  ';'Afternoon';'Evening  ';'Night    ']);

numPeriods = 0;
if(strcmp(unit,'minute(s)')==1)
    numPeriods = 60/intv;
elseif(strcmp(unit,'hour(s)')==1)
    numPeriods = 1/intv;
end

index = 1;
for i = 1:2:6
    count = 1;
    for j = 1:3:10
        [orig_capfactor,sim_capfactor,orig_max,sim_max,orig_min,sim_min] = ...
        calcCapFactors(Seasons(index),TimeOfDays(count),false,numPeriods,...
                        max_data,data_orig,data_simul);
        cap_factors(i,j) = orig_capfactor;
        cap_factors(i,j+1) = orig_min;
        cap_factors(i,j+2) = orig_max;
        cap_factors(i+1,j) = sim_capfactor;
        cap_factors(i+1,j+1) = sim_min;
        cap_factors(i+1,j+2) = sim_max;
        count = count + 1;
    end
    index = index + 1;
end


end

function out = isValid(start_row,C)
% check to see if all elements of start_row are zero - means the state
% transition never happened so choose a different start_row
    if(C(start_row,:)==0)
        out = 0;
    else
        out = 1;
    end
end

function [orig_capfactor,sim_capfactor,orig_max,sim_max,orig_min,sim_min] = ...
    calcCapFactors(season,timeOfDay,isLeap,numPeriods,max_data,data_orig,data_simul)
% calculate the annual average capacity factors for different time of the
% day for different seasons

    orig = data_orig';
    sim = data_simul';
    numerator_orig = [];
    numerator_sim = [];
    
    % check season
    begin = 0; numDays = 0;  numHours = 0;
    if(strcmp(season,'Summer') == 1)
        if(isLeap == true)
            begin = 121;
        else
            begin = 120;
        end
        numDays = 153;
        if(strcmp(timeOfDay,'Morning'))
            numHours = 1071;
        elseif(strcmp(timeOfDay,'Afternoon'))
            numHours = 765;
        elseif(strcmp(timeOfDay,'Evening'))
            numHours = 612;
        elseif(strcmp(timeOfDay,'Night'))
            numHours = 1224;
        end
    elseif(strcmp(season,'Spring/Fall') == 1)
        if(isLeap == true)
            begin = 91;
        else
            begin = 90;
        end
        numDays = 61;
        if(strcmp(timeOfDay,'Morning'))
            numHours = 427;
        elseif(strcmp(timeOfDay,'Afternoon'))
            numHours = 305;
        elseif(strcmp(timeOfDay,'Evening'))
            numHours = 244;
        elseif(strcmp(timeOfDay,'Night'))
            numHours = 488;
        end
    elseif(strcmp(season,'Winter') == 1)
        if(isLeap == true)
            begin = 305;
        else
            begin = 304;
        end
        numDays = 151;
        if(strcmp(timeOfDay,'Morning'))
            numHours = 1057;
        elseif(strcmp(timeOfDay,'Afternoon'))
            numHours = 755;
        elseif(strcmp(timeOfDay,'Evening'))
            numHours = 604;
        elseif(strcmp(timeOfDay,'Night'))
            numHours = 1208;
        end
    end
    
    % check time of day
    timeBegin = 0; timeEnd = 0; timeToNext = 0;
    if(strcmp(timeOfDay,'Morning'))
        timeBegin = 6;
        timeEnd = 7;
        timeToNext = 17*numPeriods + 1;
    elseif(strcmp(timeOfDay,'Afternoon'))
        timeBegin = 13;
        timeEnd = 5;
        timeToNext = 19*numPeriods + 1;
    elseif(strcmp(timeOfDay,'Evening'))
        timeBegin = 18;
        timeEnd = 4;
        timeToNext = 20*numPeriods + 1;
    elseif(strcmp(timeOfDay,'Night'))
        timeBegin = 22;
        timeEnd = 8;
        timeToNext = 16*numPeriods + 1;
    end
    
    % perform calculations
    start_index = (begin*24*numPeriods)+(numPeriods*timeBegin);
    end_index = start_index + numPeriods*timeEnd - 1;
    numerator_orig(1,1:numPeriods*timeEnd) = orig(1,start_index:end_index);
    numerator_sim(1,1:numPeriods*timeEnd) = sim(1,start_index:end_index);
    
    if(strcmp(season,'Summer'))
        for i = 2:numDays
            start_index = end_index + timeToNext;      
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
            numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        end
        
    elseif(strcmp(season,'Spring/Fall'))
        for i = 2:30
            start_index = end_index + timeToNext;      
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
            numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        end
        start_index = (212*24*numPeriods) + numPeriods*timeBegin;
        end_index = start_index + numPeriods*timeEnd - 1;
        numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
        numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        for i = 2:31
            start_index = end_index + timeToNext;      
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
            numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        end
        
    elseif(strcmp(season,'Winter'))
        for i = 2:60
            start_index = end_index + timeToNext;      
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
            numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        end
        start_index = numPeriods*timeBegin;
        end_index = start_index + numPeriods*timeEnd - 1;
        numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
        numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        for i = 2:90
            start_index = end_index + timeToNext;      
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(1,start_index:end_index);
            numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
        end
    end
    orig_max = max(numerator_orig/max_data);
    sim_max = max(numerator_sim/max_data);
    orig_min = min(numerator_orig/max_data);
    sim_min = min(numerator_sim/max_data);
    orig_sum = sum(numerator_orig);
    sim_sum = sum(numerator_sim);
    orig_capfactor = orig_sum/(max_data*numHours*numPeriods);
    sim_capfactor = sim_sum/(max_data*numHours*numPeriods);
end
