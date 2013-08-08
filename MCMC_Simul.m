function [cap_factors,data_orig,data_simul,states] = MCMC_Simul(data,order,...
    num,intv,unit,len,orig_length,leap_yes,leap_no,leap_value,no_sample,...
    seasons_check,morn_check,hourly_sample)

% function [BIC,data_orig,data_simul,states,cap_factors] = MCMC_Simul(data,order,...
%     num,intv,unit,len,orig_length,leap_yes,leap_no,leap_value,no_sample,...
%     seasons_check,morn_value,hourly_sample)

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


if(isempty(morn_check))
    morn_check = 0;
end
if(isempty(seasons_check))
    seasons_check = 0;
end

orig_data = csvread(data);              % total original data in csv form

yearly_orig_data = cell(1,orig_length); % original data divided into years

if(numel(leap_value) == 0)
    leap_value = 'none';
end

%% Divide the original data as described in Pre_MCMC %%

%\\\\\\\\\\\\\\\\\\\ Divide original data into years\\\\\\\\\\\\\\\\\\\\\%
start = 1;
last = 0;

for i=1:orig_length
    yearLength = 365;
    if(i == str2double(leap_value(1)))
        yearLength = 366;
    end
    yeardata = [];
    if(strcmp(unit,'minute(s)')==1)
        yeardata = zeros(yearLength*24*(60/intv), 1);
        last = last + yearLength*24*(60/intv);
        
    elseif(strcmp(unit,'hour(s)')==1)
        yeardata = zeros(1, yearLength*(24/intv));
        last = last + yearLength*(24/intv);
    else
        yeardata = zeros(1, yearLength/intv);
        last = last + yearLength/intv;
    end
%     yeardata(1 : numel(orig_data(start : last))) = orig_data(start : last);
    yeardata(1 : numel(orig_data(start : last-1))) = orig_data(start : last-orig_length);
    yearly_orig_data{1,i} = yeardata;
    start = last + 1;
end


%\\\\\\\\\\\ Divide into seasons (Summer, Spring/Fall, Winter)\\\\\\\\\\\%
if(seasons_check==1)
    summer = []; springfall = []; winter = [];
    start_summer = 1; start_spring = 1; start_winter = 1;
    
    first_year = true;
    start_year = 1; end_win = 1; start_win = 1;
    start_summ = 1; end_summ = 1;
    start_spr = 1; start_oct = 1; end_oct = 1;
    
    for i = 1:numel(yearly_orig_data)
        currentYear = yearly_orig_data{1,i}; 
        % Summer %
        numdays = 153;
        begin_summer = 120;
        if(i == str2double(leap_value(1)))
            begin_summer = 121;
        end
        % Spring/Fall %
        begin_spring = 90;
        if(i == str2double(leap_value(1)))
            begin_spring = 91;
        end
        % Winter %
        begin_winter = 304;
        if(i == str2double(leap_value(1)))
            begin_winter = 305;
        end
        
        last_summer = 0; last_spring = 0; last_winter = 0; %#ok<*NASGU>
        if(strcmp(unit,'minute(s)')==1)
            begin_summer = begin_summer*24*(60/intv) + 1; 
            begin_spring = begin_spring*24*(60/intv) + 1; 
            begin_winter = begin_winter*24*(60/intv) + 1;
            last_summer = begin_summer + numdays*24*(60/intv);
            last_spring = begin_spring + 30*24*(60/intv);
            last_winter = begin_winter + 61*24*(60/intv);
        elseif(strcmp(unit,'hour(s)')==1)
            begin_summer = begin_summer*(24/intv) + 1; 
            begin_spring = begin_spring*(24/intv) + 1;
            begin_winter = begin_winter*(24/intv) + 1;
            last_summer = begin_summer + numdays*(24/intv);
            last_spring = begin_spring + 30*(24/intv);
            last_winter = begin_winter + 61*(24/intv);
        else
            begin_summer = begin_summer/intv + 1;
            begin_spring = begin_spring/intv + 1;
            begin_winter = begin_spring/intv + 1;
            last_summer = begin_summer + numdays/intv;
            last_spring = begin_summer + 30/intv;
            last_winter = begin_winter + 61/intv;
        end
        
        summer(start_summer : start_summer + numel(currentYear(begin_summer:last_summer)) - 2) = ...
            currentYear(begin_summer : last_summer - 1);
        springfall(start_spring : start_spring + numel(currentYear(begin_spring:last_spring)) - 2) = ...
            currentYear(begin_spring : last_spring - 1);
        winter(start_winter : start_winter + numel(currentYear(begin_winter:last_winter - 1)) - 1) = ...
            currentYear(begin_winter : last_winter - 1);
        
        if(first_year == true)
            start_summ = start_summer;
            end_summ = start_summer + numel(currentYear(begin_summer:last_summer)) - 2;
        end
        
        start_summer = start_summer + numel(currentYear(begin_summer:last_summer))-1;
        start_spring = start_spring + numel(currentYear(begin_spring:last_spring))-1;
        start_winter = start_winter + numel(currentYear(begin_winter:last_winter - 1));
        %end of summer
        
%continued for spring/fall and winter.....................................
        begin_spring = 273;
        winter_add = 90;
        if(i == str2double(leap_value(1)))
            begin_spring = 274;
            winter_add = 91;
        end
        begin_winter = 1;
        
        if(strcmp(unit,'minute(s)')==1)
            begin_spring = begin_spring*24*(60/intv) + 1; 
            last_spring = begin_spring + 31*24*(60/intv);
            last_winter = begin_winter + winter_add*24*(60/intv);
        elseif(strcmp(unit,'hour(s)')==1)
            begin_spring = begin_spring*(24/intv) + 1;
            last_spring = begin_spring + 31*(24/intv);
            last_winter = begin_winter + winter_add*(24/intv);
        else
            begin_spring = begin_spring/intv + 1;
            last_spring = begin_summer + 31/intv;
            last_winter = begin_winter + winter_add/intv;
        end
        
        springfall(start_spring : start_spring + numel(currentYear(begin_spring:last_spring)) - 2) = ...
            currentYear(begin_spring : last_spring - 1);
        winter(start_winter : start_winter + numel(currentYear(begin_winter:last_winter)) - 2) = ...
            currentYear(begin_winter : last_winter - 1);
        
        if(first_year == true)
            start_year = start_winter;
            end_win = start_winter + numel(currentYear(begin_winter:last_winter)) - 2;
            start_oct = start_spring;
            end_oct = start_spring + numel(currentYear(begin_spring:last_spring)) - 2;
            first_year = false;
        end
        
        start_spring = start_spring + numel(currentYear(begin_spring:last_spring))-1;
        start_winter = start_winter + numel(currentYear(begin_winter:last_winter))-1;       
    end
    season_orig_data{1,1} = summer;
    season_orig_data{1,2} = springfall;
    season_orig_data{1,3} = winter;
    data_orig{1} = summer';
    data_orig{2} = springfall';
    data_orig{3} = winter';
end

%//////// Divide into time of day (morning,afternoon,evening,night)///////%
if(morn_check==1)
    numPeriods = 0;
    if(strcmp(unit,'minute(s)')==1)
        numPeriods = 60/intv;
    elseif(strcmp(unit,'hour(s)')==1)
        numPeriods = 1/intv;
    end

%if both seasons and time of day are checked...............................
    if(seasons_check==1)
        ind = 1;
        for i = 1:numel(season_orig_data)
            morn = []; after = []; even = []; night = [];
            mornInd = []; afterInd = []; evenInd = []; nightInd = [];
            mornTag = []; afterTag = []; evenTag = []; nightTag = [];
            numdays = 0;
            current_season = season_orig_data{i};
            if(i == 1)
                numdays = 153*orig_length;
            elseif(i == 2)
                numdays = 61*orig_length;
            else
                numdays = 151*orig_length;
                if(leap_yes == 1)
                    numdays = numdays + 1;
                end
            end
            %morn
            morn_timeBegin = 6; morn_timeEnd = 7;
            morn_timeToNext = 17*numPeriods + 1;
            %after
            after_timeBegin = 13; after_timeEnd = 5;
            after_timeToNext = 19*numPeriods + 1;
            %even
            even_timeBegin = 18; even_timeEnd = 4;
            even_timeToNext = 20*numPeriods + 1;
            %night
            night_timeBegin = 22; night_timeEnd = 8;
            night_timeToNext = 16*numPeriods + 1;

            morn_begin = morn_timeBegin*numPeriods + 1;
            after_begin = after_timeBegin*numPeriods + 1;
            even_begin = even_timeBegin*numPeriods + 1;
            night_begin = night_timeBegin*numPeriods + 1;
            for j = 1:numdays
                %morning%
                morn_end = morn_begin + morn_timeEnd*numPeriods - 1;
                morn = [morn,current_season(morn_begin : morn_end)];
                mornTag = vertcat(mornTag,current_season(morn_end+1:morn_end + order));
                mornInd = [mornInd zeros(1,numel(current_season(morn_begin : morn_end)))];
                mornInd(end) = 1;
                morn_begin = morn_end + morn_timeToNext;
                %afternoon%
                after_end = after_begin + after_timeEnd*numPeriods - 1;
                after = [after,current_season(after_begin : after_end)];
                afterTag = vertcat(afterTag,current_season(after_end+1:after_end + order));
                afterInd = [afterInd zeros(1,numel(current_season(after_begin : after_end)))];
                afterInd(end) = 1;
                after_begin = after_end + after_timeToNext;
                %evening%
                even_end = even_begin + even_timeEnd*numPeriods - 1;
                even = [even,current_season(even_begin : even_end)];
                evenTag = vertcat(evenTag,current_season(even_end+1:even_end + order));
                evenInd = [evenInd zeros(1,numel(current_season(even_begin : even_end)))];
                evenInd(end) = 1;
                even_begin = even_end + even_timeToNext;
                %night%
                night_end = night_begin + night_timeEnd*numPeriods - 1;
                if(night_end > numel(current_season))
                    night_end = numel(current_season);
                    night = [night,current_season(night_begin : night_end)];
                    nightInd = [nightInd zeros(1,numel(current_season(night_begin : night_end)))];
                    night_begin = 1;
                    night_end = night_begin + 6*numPeriods - 1;
                    night = [night,current_season(night_begin : night_end)];
                    nightTag = vertcat(nightTag,current_season(night_end+1:night_end + order));
                    nightInd = [nightInd zeros(1,numel(current_season(night_begin : night_end)))];
                    nightInd(end) = 1;
                else
                    night = [night,current_season(night_begin : night_end)];
                    nightTag = vertcat(nightTag,current_season(night_end+1:night_end + order));
                    nightInd = [nightInd zeros(1,numel(current_season(night_begin : night_end)))];
                    nightInd(end) = 1;
                    night_begin = night_end + night_timeToNext;
                end
            end
            data_orig{ind} = morn';
            data_orig{ind+1} = after';
            data_orig{ind+2} = even';
            data_orig{ind+3} = night';
            
            indicator{ind} = mornInd;
            indicator{ind+1} = afterInd;
            indicator{ind+2} = evenInd;
            indicator{ind+3} = nightInd;
            
            tag{ind} = mornTag;
            tag{ind+1} = afterTag;
            tag{ind+2} = evenTag;
            tag{ind+3} = nightTag;
            
            ind = ind + 4;
        end
        
%if only time of day is checked...........................................
    else
        morn = []; after = []; even = []; night = [];
        mornInd = []; afterInd = []; evenInd = []; nightInd = [];
        mornTag = []; afterTag = []; evenTag = []; nightTag = [];
        ind = 1;
        for i = 1:numel(yearly_orig_data)            
            current_year = yearly_orig_data{i}';
            numdays = 365;
            if(i == str2double(leap_value(1)))
                numdays = 366;
            end
            
            %morn
            morn_timeBegin = 6;
            morn_timeEnd = 7;
            morn_timeToNext = 17*numPeriods + 1;
            %after
            after_timeBegin = 13;
            after_timeEnd = 5;
            after_timeToNext = 19*numPeriods + 1;
            %even
            even_timeBegin = 18;
            even_timeEnd = 4;
            even_timeToNext = 20*numPeriods + 1;
            %night
            night_timeBegin = 22;
            night_timeEnd = 8;
            night_timeToNext = 16*numPeriods + 1;

            morn_begin = morn_timeBegin*numPeriods + 1;
            after_begin = after_timeBegin*numPeriods + 1;
            even_begin = even_timeBegin*numPeriods + 1;
            night_begin = night_timeBegin*numPeriods + 1;
            for j = 1:numdays
                %morning%
                morn_end = morn_begin + morn_timeEnd*numPeriods - 1;
                morn = [morn,current_year(morn_begin : morn_end)];
                mornTag = vertcat(mornTag,current_year(morn_end+1:morn_end + order));
                mornInd = [mornInd zeros(1,numel(current_year(morn_begin : morn_end)))];
                mornInd(end) = 1;
                morn_begin = morn_end + morn_timeToNext;
                %afternoon%
                after_end = after_begin + after_timeEnd*numPeriods - 1;
                after = [after,current_year(after_begin : after_end)];
                afterTag = vertcat(afterTag,current_year(after_end+1:after_end + order));
                afterInd = [afterInd zeros(1,numel(current_year(after_begin : after_end)))];
                afterInd(end) = 1;
                after_begin = after_end + after_timeToNext;
                %evening%
                even_end = even_begin + even_timeEnd*numPeriods - 1;
                even = [even,current_year(even_begin : even_end)];
                evenTag = vertcat(evenTag,current_year(even_end+1:even_end + order));
                evenInd = [evenInd zeros(1,numel(current_year(even_begin : even_end)))];
                evenInd(end) = 1;
                even_begin = even_end + even_timeToNext;
                %night%
                night_end = night_begin + night_timeEnd*numPeriods - 1;
                if(night_end > numel(current_year))
                    night_end = numel(current_year);
                    night = [night,current_year(night_begin : night_end)];
                    nightInd = [nightInd zeros(1,numel(current_year(night_begin : night_end)))];
                    night_begin = 1;
                    night_end = night_begin + 6*numPeriods - 1;
                    night = [night,current_year(night_begin : night_end)];
                    nightTag = vertcat(nightTag,current_year(night_end+1:night_end + order));
                    nightInd = [nightInd zeros(1,numel(current_year(night_begin : night_end)))];
                    nightInd(end) = 1;
                else
                    night = [night,current_year(night_begin : night_end)];
                    nightTag = vertcat(nightTag,current_year(night_end+1:night_end + order));
                    nightInd = [nightInd zeros(1,numel(current_year(night_begin : night_end)))];
                    nightInd(end) = 1;
                    night_begin = night_end + night_timeToNext;
                end
            end
        end
        data_orig{ind} = morn';
        data_orig{ind+1} = after';
        data_orig{ind+2} = even';
        data_orig{ind+3} = night';
        
        indicator{ind} = mornInd;
        indicator{ind+1} = afterInd;
        indicator{ind+2} = evenInd;
        indicator{ind+3} = nightInd;
        
        tag{ind} = mornTag;
        tag{ind+1} = afterTag;
        tag{ind+2} = evenTag;
        tag{ind+3} = nightTag;
    end
end

%if no sample selection...................................................
if(morn_check==0 && seasons_check==0)
    data_orig{1} = orig_data;
end


% for progress bar........................................................
steps = 0;
for i = 1:numel(data_orig)
    steps = steps + numel(data_orig{i})*len;
end
progressbar('Simulating...');


%% Discretization into markov chain states
maximum = 0;
for k = 1:numel(data_orig)
    if(max(data_orig{k}) > maximum)
        maximum = max(data_orig{k});
    end
end

for k = 1:numel(data_orig)
    
    % account for negative values
    min_data = min(data_orig{k});
    if(min_data < 0)
        data_orig{k} = data_orig{k} + -1.*min_data;
    end
    
    max_data=max(data_orig{k});
    numstates = num;
    width_state = max_data/numstates;   % shows the range of values that make up one state
    lim = width_state*numstates;
    states = 0:width_state:lim;
    

%%%%%%%%%%%%%% transition matrix for first order markov chain %%%%%%%%%%%%%
    if(order == 1) 
        N = histc(data_orig{k},states);   
        P=zeros(numel(N));
        for iter=1:numel(data_orig{k})-1
            transit=data_orig{k}(iter:iter+1);
            state1=floor(transit(1)/width_state);
            state2=floor(transit(2)/width_state);
            P(state1+1,state2+1)=P(state1+1,state2+1)+1;
        end
        temp = P;                       % trans matrix of frequencies (before dividing)
        last=data_orig{k}(end);
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
        
        
%%%%%%%%%%%%%%transition matrix for higher order Markov chain%%%%%%%%%%%%%%
    else
        x=zeros(1,numel(data_orig{k}));
        for iter1 = 1:numel(data_orig{k})     %make values into states
            if(data_orig{k}(iter1)==0)
                state = 1;
            elseif(data_orig{k}(iter1)==max_data)
                state = numstates;
            else
                state = ceil(data_orig{k}(iter1)/width_state);
            end
            x(iter1) = state;
        end
        
        % for the tag (ending) values
        if(morn_check==1)
            for i = 1:numel(tag)
                for j = 1:numel(tag{i}(:,1))
                    for jj = 1:numel(tag{i}(1,:))
                        if(tag{i}(j,jj)==0)
                            tag{i}(j,jj) = 1;
                        elseif(tag{i}(j,jj)==max_data)
                            tag{i}(j,jj) = numstates;
                        else
                            tag{i}(j,jj) = ceil(tag{i}(j,jj)/width_state);
                        end
                    end
                end
            end
        end
        
%different definition of state.............................................
%         x=zeros(1,numel(data_orig{k}));
%         sorted = sort(data_orig{k});
%         numElements = floor(numel(data_orig{k})/numstates);
%         states = 0;
%         
%         for i = 1:numstates
%             states = [states sorted(numElements*i)];
%         end
%         
%         for iter1 = 1:numel(data_orig{k})
%             ind = numElements;
%             if(data_orig{k}(iter1) == max(data_orig{k}))
%                 x(iter1) = numstates;
%                 continue;
%             end
%             for iter2 = 1:numstates
%                 if(data_orig{k}(iter1) < sorted(ind))
%                     x(iter1) = iter2;
%                     break;
%                 end
%                 ind = ind + numElements;
%             end
%         end
%         
%         while(~isempty(find(x==0,1)))
%             x(find(x==0,1)) = x(find(x==0,1) - 1);
%         end
%..........................................................................

        M = max(x);

        % extract contiguous sequences of n items from the above
        matrix = zeros(order,numel(x(1:end-order)));
        for i=1:order
            matrix(i,1:end) = x(i:end-(order-i+1));
        end
        
        count = 1;
        if(morn_check==1)
            for i=1:numel(indicator{k})-order
                minus = 1;
                if(indicator{k}(i) == 1)
                    %matrix(2:end,i) = matrix(1,i);
                    matrix(2:end,i) = tag{k}(count,1:end-minus);
                    minus = minus + 1;
                else
                    continue;
                end
                back = 1;
                j = 3;
                while(back < order-1)
                    %matrix(j:end,i-back) = matrix(1,i);
                    matrix(j:end,i-back) = tag{k}(count,1:end-minus);
                    back = back + 1;
                    j = j + 1;
                    minus = minus + 1;
                end
                count = count + 1;
            end
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
%-----------------------------------------------------
        str = 'textscan(sprintf(''%s\n'',xy{:}),''';
        for i=1:order
            str = strcat(str,'%s');
        end
        str = strcat(str,''')');
        q = eval(str);
        mat = [q{:}];
%-----------------------------------------------------
        
        [g,~] = grp2idx([xy;ngrams]);  % map ngrams to numbers starting from 1
        s1 = g(((M^order)+1):end);
        s2 = x((order+1):end);          % items following the ngrams
        if(morn_check==1)
            indCount = 1;
            for i=1:numel(indicator{k})-order
                count = 0;
                minus = 0;
                if(indicator{k}(i) == 1)
                    count = count + 1;
                    while(count <= order)
                        s2(i-count+1) = tag{k}(indCount,end-minus);
                        count = count + 1;
                        minus = minus + 1;
                    end
                    indCount = indCount + 1;
                end
            end
        end

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

%% Simulating Data (Monte Carlo)
    simul_len = numel(data_orig{k})*len;
    data_simul{k} = zeros(simul_len,1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% for first order %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(order == 1) 
        start=randi([1,n-1],1);         % randomly choose wind state at hr 0
        chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
        data_simul{k}(1)=chosen_value;
    
        step = 1;
        
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
            data_simul{k}(iter)=chosen_value;
            start=next_state;
            
            step = step + 1;
            frac2 = step / simul_len;
            frac1 = ((k-1) + frac2) / numel(data_orig);
            if(mod(step,1000)==0)
                progressbar(frac1);
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%% for higher order %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else        
        start=randi([1,row_len-1],1);       % randomly choose wind state at hr 0
        chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
        data_simul{k}(1)=chosen_value;

        
        start_row=randi([1,col_len-1],1);

        out = isValid(start_row,C); %check if start_row is not all zeros
        while(out==0)
            start_row=randi([1,col_len-1],1);
            out = isValid(start_row,C);
        end
        
        step = 1;
        % Simulation simul_len times     
        for iter=2:simul_len
            u_rand = rand(1,1);
            next_state = sum(C(start_row,:)<u_rand)+1;
            chosen_value=states(next_state) + (states(next_state+1)-...
                         states(next_state)).*rand(1,1);
            data_simul{k}(iter)=chosen_value;
            toAdd = 0;
            for i = order-1:-1:1
                toAdd = toAdd + (numstates.^i).*(next_state-1);
                next_state = sscanf(mat{start_row,i+1},'%f');
            end
            toAdd = toAdd + sscanf(mat{start_row,2},'%f');
            start_row = toAdd;
            
            step = step + 1;
            frac2 = step / simul_len;
            frac1 = ((k-1) + frac2) / numel(data_orig);
            if(mod(step,1000)==0)
                progressbar(frac1);
            end
        end
    end

%     %% Calculating the Bayesian information criterion (BIC)
%     num_row = numel(P(1:end,1));
%     num_col = numel(P(1,1:end));
% 
%     LL = 0;
%     for i = 1:num_row
%         for j = 1:num_col
%             if(P(i,j) == 0 || isnan(P(i,j)))
%                 continue;
%             else
%                 LL = LL + temp(i,j).*log(P(i,j));       % log likelihood
%             end
%         end
%     end
%     phi = (numstates.^order).*(numstates-1);           % no. of independent parameters 
%     BIC = -2.*LL + phi.*log(numel(data_orig{k}));

    % subtract back for negative numbers
    if(min_data < 0)
        data_orig{k} = data_orig{k} - -1.*min_data;
    %     min_summer = min_summer - -1.*min_summer;
    %     min_springfall = min_springfall + -1.*min_springfall;
    %     min_winter = min_winter + -1.*min_winter;
        data_simul{k} = data_simul{k} - -1.*min_data;
        states = states - -1.*min_data;
    end
    
end
delete(gcf);    %close progress bar

%% combine seasons/time of days to years

% both time of day and seasons selected.....................................
if(morn_check == 1 && seasons_check == 1)
    num_days = [153,61,151];
    index = 1;
    data_simul{13} = [];
    for i = 1:numel(num_days)
        season = [];
        start_morn = 1; start_after = 1; start_even = 1; start_night = 1;
        morn_range = 7*(60/intv); after_range = 5*(60/intv);
        even_range = 4*(60/intv); night_range = 8*(60/intv);
        end_morn = 7*(60/intv); end_after= 5*(60/intv);
        end_even = 4*(60/intv); end_night = 8*(60/intv);
        season = data_simul{index + 3}(start_night:6*(60/intv));
        
        if(i == str2double(leap_value(1)))
            num_days(3) = 152;
        end
        
        for j = 1:num_days(i)*len
            season = vertcat(season, data_simul{index}(start_morn:end_morn)); %#ok<*AGROW>
            start_morn = end_morn + 1;
            end_morn = start_morn + morn_range - 1;
            
            season = vertcat(season, data_simul{index + 1}(start_after:end_after));
            start_after = end_after + 1;
            end_after = start_after + after_range- 1;
            
            season = vertcat(season, data_simul{index + 2}(start_even:end_even));
            start_even = end_even + 1;
            end_even = start_even + even_range - 1;
            
            season = vertcat(season, data_simul{index + 3}(start_night:end_night));
            start_night = end_night + 1;
            end_night = start_night + night_range - 1;
        end

        seasons{i} = season;
        index = index + 4;
    end
end

% both selected continued, or only seasons selected........................
if((morn_check == 0 && seasons_check == 1) || (morn_check == 1 && seasons_check == 1))
    if(morn_check == 0 && seasons_check == 1)
        data_simul{4} = [];
        d_simulated = data_simul;
    elseif(morn_check == 1 && seasons_check == 1)
        data_simul{13} = [];
        d_simulated = seasons;
    end
    d_simulated{4} = [];
    year_diff = start_year;
    for i = 1:len
        yearly_sim_data{i} = d_simulated{3}(start_year:end_win);
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{2}(start_spr:start_oct-1));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{1}(start_summ:end_summ));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{2}(start_oct:end_oct));
        yearly_sim_data{i} = vertcat(yearly_sim_data{i}, d_simulated{3}(start_win:start_year-1));
        d_simulated{4} = vertcat(d_simulated{4},yearly_sim_data{i});
        if(i < len)
            windiff = end_win - start_year;
            start_win = end_win + 1;
            start_year = end_win + year_diff;
            end_win = start_year + windiff;
            
            diff = end_summ - start_summ;
            start_summ = end_summ + 1;
            end_summ = start_summ + diff;
            
            diff = start_oct-1 - start_spr;
            start_spr = end_oct + 1;
            octdiff = end_oct - start_oct;
            start_oct = start_spr + diff + 1;
            end_oct = start_oct + octdiff;
        end

    end
    if(morn_check == 0 && seasons_check == 1)
        data_simul{4} = d_simulated{4};
        data_orig{4} = orig_data;
    elseif(morn_check == 1 && seasons_check == 1)
        data_simul{13} = d_simulated{4};
        data_orig{13} = orig_data;
    end

% only time of day selected.................................................
elseif(morn_check == 1 && seasons_check == 0)
    data_simul{5} = [];
    index = 1;
    sim = [];
    start_morn = 1; start_after = 1; start_even = 1; start_night = 1;
    morn_range = 7*(60/intv); after_range = 5*(60/intv);
    even_range = 4*(60/intv); night_range = 8*(60/intv);
    end_morn = 7*(60/intv); end_after= 5*(60/intv);
    end_even = 4*(60/intv); end_night = 8*(60/intv);
    sim = data_simul{index + 3}(start_night:6*(60/intv));
    
    num_days = 0;
    for i = 1:len
        num_days = num_days + 365;
        if(i == str2double(leap_value(1)))
            num_days = num_days + 366;
        end
    end

    for j = 1:num_days
        sim = vertcat(sim, data_simul{index}(start_morn:end_morn)); %#ok<*AGROW>
        start_morn = end_morn + 1;
        end_morn = start_morn + morn_range - 1;

        sim = vertcat(sim, data_simul{index + 1}(start_after:end_after));
        start_after = end_after + 1;
        end_after = start_after + after_range- 1;

        sim = vertcat(sim, data_simul{index + 2}(start_even:end_even));
        start_even = end_even + 1;
        end_even = start_even + even_range - 1;

        sim = vertcat(sim, data_simul{index + 3}(start_night:end_night));
        start_night = end_night + 1;
        end_night = start_night + night_range - 1;
    end
        data_simul{5} = vertcat(data_simul{5},sim);
        data_orig{5} = orig_data;

end   
% only time of day selected contd, or no sample selection..................
if((morn_check == 0 && seasons_check == 0) || (morn_check == 1 && seasons_check == 0))
    % Divide simulated data into years
    start = 1;
    last = 0;

    for i=1:len
        yearLength = 365;
        if(i == str2double(leap_value(1)))
            yearLength = 366;
        end
        yeardata = []; %#ok<NASGU>
        if(strcmp(unit,'minute(s)')==1)
            yeardata = zeros(yearLength*24*(60/intv), 1);
            last = last + yearLength*24*(60/intv);

        elseif(strcmp(unit,'hour(s)')==1)
            yeardata = zeros(1, yearLength*(24/intv));
            last = last + yearLength*(24/intv);
        else
            yeardata = zeros(1, yearLength/intv);
            last = last + yearLength/intv;
        end
        if(morn_check == 0 && seasons_check == 0)
%             yeardata(1 : numel(data_simul{1}(start : last))) = data_simul{1}(start : last);
            yeardata(1 : numel(data_simul{1}(start : last-len))) = data_simul{1}(start : last-len);
        elseif(morn_check == 1 && seasons_check == 0)
%             yeardata(1 : numel(sim(start : last))) = sim(start : last);
            yeardata(1 : numel(sim(start : last-len))) = sim(start : last-len);
        end
        yearly_sim_data{1,i} = yeardata;
        start = last + 1;
    end
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
for i = 1:2:5
    count = 1;
    for j = 1:3:10
        isOrig = true;
        [orig_capfactor,orig_max,orig_min] = calcCapFactors(Seasons(index),...
            TimeOfDays(count),numPeriods,maximum,yearly_orig_data,isOrig,leap_value);
        isOrig = false;
        [sim_capfactor,sim_max,sim_min] = calcCapFactors(Seasons(index),...
            TimeOfDays(count),numPeriods,maximum,yearly_sim_data,isOrig,leap_value);
        
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
%%%%%%%%%%%%%%%%%%%%%% End of MCMC_Simul function %%%%%%%%%%%%%%%%%%%%%%%%%


%% helper functions

function out = isValid(start_row,C)
% check to see if all elements of start_row are zero - means the state
% transition never happened so choose a different start_row
    if(C(start_row,:)==0)
        out = 0;
    else
        out = 1;
    end
end

function [orig_capfactor,orig_max,orig_min] = calcCapFactors(season,...
    timeOfDay,numPeriods,max_data,yearly_data,isOrig,leap_value)
% calculate the annual average capacity factors for different time of the
% day for different seasons

    numerator_orig = [];
    %factors = [];
    for iter = 1:numel(yearly_data)
    % check season
        begin = 0; numDays = 0;  numHours = 0;
        if(strcmp(season,'Summer') == 1)
            begin = 120;
            if(isOrig == true)
                if(iter == str2double(leap_value(1)))
                    begin = 121;
                end
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
            begin = 90;
            if(isOrig == true)
                if(iter == str2double(leap_value(1)))
                    begin = 91;
                end
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
            begin = 304;
            if(isOrig == true)
                if(iter == str2double(leap_value(1)))
                    begin = 305;
                end
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
        orig = yearly_data{iter};
        %sim = data_simul';
        %numerator_sim = [];

        start_index = (begin*24*numPeriods)+(numPeriods*timeBegin);
        end_index = start_index + numPeriods*timeEnd - 1;
        numerator_orig(1,1:numPeriods*timeEnd) = orig(start_index:end_index);
        %numerator_sim(1,1:numPeriods*timeEnd) = sim(1,start_index:end_index);

        if(strcmp(season,'Summer'))

            for i = 2:numDays
                start_index = end_index + timeToNext;      
                end_index = start_index + numPeriods*timeEnd - 1;
                numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
                %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            end

        elseif(strcmp(season,'Spring/Fall'))
            for i = 2:30
                start_index = end_index + timeToNext;      
                end_index = start_index + numPeriods*timeEnd - 1;
                numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
                %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            end
            start_index = (212*24*numPeriods) + numPeriods*timeBegin;
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
            %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            for i = 2:31
                start_index = end_index + timeToNext;      
                end_index = start_index + numPeriods*timeEnd - 1;
                numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
                %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            end

        elseif(strcmp(season,'Winter'))
            for i = 2:60
                start_index = end_index + timeToNext;      
                end_index = start_index + numPeriods*timeEnd - 1;
                numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
                %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            end
            start_index = numPeriods*timeBegin;
            end_index = start_index + numPeriods*timeEnd - 1;
            numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
            %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            for i = 2:90
                start_index = end_index + timeToNext;      
                end_index = start_index + numPeriods*timeEnd - 1;
                numerator_orig(1,end+1:end+(numPeriods*timeEnd)) = orig(start_index:end_index);
                %numerator_sim(1,end+1:end+(numPeriods*timeEnd)) = sim(1,start_index:end_index);
            end
        end
        
%         factorsum = sum(numerator_orig(start:end));
%         factor = (factorsum/(max_data*numHours*numPeriods))/numel(yearly_data);
%         factors(iter) = factor;
%         start = numel(numerator_orig) + 1;
    end
    orig_max = max(numerator_orig/max_data);
    orig_min = min(numerator_orig/max_data);
    orig_sum = sum(numerator_orig);
    orig_capfactor = (orig_sum/(max_data*numHours*numPeriods))/numel(yearly_data);
    
%     begin_factor = factors(1);
%     end_factor = factors(end);
%     annual_trend = ((end_factor-begin_factor)/begin_factor)/numel(yearly_data);
end
