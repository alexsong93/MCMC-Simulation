function BIC = MCMC_Simul(data,order,width,len)
%MCMC_Simul Summary of this function goes here
%   Detailed explanation goes here


%% Generating wind power time series by MCMC method

% simulation details
width_state=width;  % this denotes the number of elements in each state of the Markov Chain
simul_len=len;      % this is the length of the simulated wind power data
wind_simul=zeros(simul_len,1);
Wind_10min = csvread(data);

%% creating state transition matrix
max_wind=max(Wind_10min);
% % changed if/else to ceil
numstates=ceil(max_wind/width_state);
% if (numstates~=round(numstates))
%     if(numstates<round(numstates))
%         numstates=round(numstates);
%     else
%         numstates=round(numstates)+1; 
%     end
% end

%% Order 1 Markov Chain
if(order == 1) 
    
    lim = 0+width_state*numstates;
    states = 0:width_state:lim;
    N = histc(Wind_10min,states);
   
    P=zeros(numel(N));
    for iter=1:numel(Wind_10min)-1
        transit=Wind_10min(iter:iter+1);
        state1=floor(transit(1)/width_state);
        state2=floor(transit(2)/width_state);
        P(state1+1,state2+1)=P(state1+1,state2+1)+1;
    end

    temp = P;      % trans matrix of frequencies (before dividing)

    last=Wind_10min(end);
    state_last=floor(last/width_state);
    N(state_last+1)=N(state_last+1)-1;

    for iter=1:numel(N)-1
        P(iter,1:end)=P(iter,1:end)./N(iter);    
    end
    P=P(1:end-1,1:end-1);
    
    %% Creating the cumulative transition matrix
    n=numel(P(1,1:end));
    C=zeros(size(P));
    for iter=1:n
        for iter1=1:n
            C(iter,iter1)=sum(P(iter,1:iter1));
        end
    end

    %% Simulating Wind Data

    % randomly choose wind state at hr 0
    start=randi([1,n-1],1);
    % The following lines of code are in case you want the starting point to be
    % the most frequent wind power value at 0 hrs, in the training data set

    %inter_var=find(states<=start_wind);
    %start=inter_var(end);
    %wind_values=linspace(states(start),states(start+1));

    chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
    %wind_values(randi([1,numel(wind_values)],1));
    wind_simul(1)=chosen_value;

    for iter=2:simul_len
        u_rand=rand(1);
        % finding next state as indicated by u_rand
        for iter1=2:n
            if(u_rand<=C(start,1))
                next_state=1;
            else
                if(C(start,iter1-1)<u_rand && C(start,iter1)>=u_rand)
                    next_state=iter1;
                end
            end
        end
        chosen_value=states(next_state) + (states(next_state+1)-states(next_state)).*rand(1,1);
        wind_simul(iter)=chosen_value;
        start=next_state;
    end
    
%% higher order Markov chain    
else
    
    lim = 0+width_state*numstates;
    states = 0:width_state:lim;
    % N = histc(Wind_10min,states);

    x=[];
    for iter1 = 1:numel(Wind_10min)
        state = floor(Wind_10min(iter1)/width_state);
        x(end+1) = state;
    end

    %  add one because index of matrix can't be zero
    x = x+1;
    M = max(x); %numstates

    % extract contiguous sequences of 2 items from the above
    matrix = zeros(order,numel(x(1:end-order)));
    for i=1:order
        matrix(i,1:end) = x(i:end-(order-i+1));
    end
    ngrams = cellstr(num2str( matrix' ));
    
    % all possible combinations of two symbols
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
    
    % map bigrams to numbers starting from 1
    [g,gn] = grp2idx([xy;ngrams]);
    s1 = g(((M^order)+1):end);
    
    % items following the bigrams
    s2 = x((order+1):end);
    
    % transition matrix
    P = full(sparse(s1,s2,1,M^order,M));
    temp = P;

    dim=size(P);
    col_len=dim(1);
    row_len=dim(2);

    s = [];
    for iter=1:col_len
        s(iter)=sum(P(iter,:));
    end

    for iter1=1:col_len
        for iter2=1:row_len
            P(iter1,iter2)=P(iter1,iter2)./s(iter1);
        end
    end

    %% Creating the cumulative transition matrix
    C=zeros(size(P));
    for iter1=1:col_len
        for iter2=1:row_len
            C(iter1,iter2)=sum(P(iter1,1:iter2));
        end
    end

    %% Simulating Wind Data

    % randomly choose wind state at hr 0
    start=randi([1,row_len-1],1);
    %start=1;

    % The following lines of code are in case you want the starting point to be
    % the most frequent wind power value at 0 hrs, in the training data set

    %inter_var=find(states<=start_wind);
    %start=inter_var(end);
  
    chosen_value=states(start) + (states(start+1)-states(start)).*rand(1,1);
    wind_simul(1)=chosen_value;

    start_row=randi([1,col_len-1],1);
    next_state = start;

    for iter=2:simul_len
        u_rand=rand(1,1);
        % finding next state as indicated by u_rand
        for iter1=2:row_len
            if(u_rand<=C(start_row,1))
                next_state=1;
            else 
                if(C(start_row,iter1-1)<u_rand && C(start,iter1)>=u_rand);
                    next_state=iter1;
                end
            end    
        end
        chosen_value=states(next_state) + (states(next_state+1)-states(next_state)).*rand(1,1);
        wind_simul(iter)=chosen_value;

        toAdd = 0;
        for i = 1:order-1
            toAdd = toAdd + (numstates.^i).*(next_state-1);
        end
        
        if(numstates < 10)
            start_row = toAdd + (xy{start_row}(4)-48);
        else
            if(xy{start_row}(5)+0 == 32)
                start_row = toAdd + (xy{start_row}(6)-48);
            else
                start_row = toAdd + str2double(xy{start_row}(5))*10 +(xy{start_row}(6)-48);
            end
        end
    end    
end
   
%% Calculating the Bayesian information criterion (BIC)
% BIC = LL - (phi./2).*ln(k)
% LL = sum((n_ij).*ln(pij))

num_row = numel(P(1:end,1));
num_col = numel(P(1,1:end));

LL = 0;
for i = 1:num_row
    for j = 1:num_col
        if(P(i,j) == 0 || isnan(P(i,j)))
            continue;
        else
            LL = LL + temp(i,j).*log(P(i,j)); 
        end
    end
end

phi = (numstates.^order).*(numstates-1);

BIC = -2.*LL + phi.*log(numel(Wind_10min));

%plotting 'training' and simulated time series
% figure;clf;
% plot(Wind_10min,'g');
% title('Actual wind data');
% ylabel('Wind Power in MW');
% xlabel('Time in hrs');
% 
% figure;clf;
% plot(wind_simul,'r');
% title('Simulated wind data');
% ylabel('Wind Power in MW');
% xlabel('Time in hrs');

%plotting acf
figure;clf;
hold on;
[ACF_orig,~]=autocorr(Wind_10min,6*24*2); %3days
[ACF_simul,~]=autocorr(wind_simul,6*24*2);
plot(1:numel(ACF_orig),ACF_orig)
plot(1:numel(ACF_simul),ACF_simul,'-.')
title('Comparison of autocorrelation function (acf)');
legend('acf of input wind power time series','acf of simulated series');
xlabel('time lag');ylabel('autocorrelation');
hold off;

%plotting pdf
pdf_orig=histc(Wind_10min,states);
pdf_simul=histc(wind_simul,states);
figure;clf;
subplot(2,1,1), bar(states,pdf_orig,'barwidth',1);
set(gca,'XLim',[-80 lim+30])
title ('pdf of input wind power time series');
ylabel('frequency');
subplot(2,1,2), bar(states,pdf_simul,'barwidth',1);
set(gca,'XLim',[-80 lim+30])
title ('pdf of simulated time series');
xlabel('Wind Power Output (MW)');ylabel('frequency');
save('O_w.mat','wind_simul');


end

