%% Generating electricity price time series by MCMC method

% simulation details
width_state=20;  % this denotes the number of elements in each state of the Markov Chain
simul_len=8784*30; % this is the length of the simulated wind power data
wind_simul=zeros(simul_len,1);
count=1;
%start_wind=0;
% for iter0=1:3
%     % changed to sprintf for faster performance
%     Wind_10min=xlsread(['4431_WindPower' sprintf('%.0f',2003+iter0) '.xlsm'],'G10:G52713'); % Refers to ewits time-series wind data
%     iter=1;k=5;
%     while(iter+k<=numel(Wind_10min))
%         if(iter>1)
%             k=6;
%         end
%         if(iter+k<=numel(Wind_10min))
%             Wind_hourly(count)=sum(Wind_10min(iter:iter+k))/k;
%             count=count+1;
%         end
%         iter=iter+k;
%     end
% end

elec_prices=xlsread('historical-doex-345-kv-gendummy-prices.xls','D2:D9505');

%start_wind=sum(Wind_hourly(1:24:end))/numel(Wind_hourly(1:24:end));
%Wind_hourly=[0 1 22 35 2 18 17 14]; % this is test data

%% creating state transition matrix
max_price=max(elec_prices);
% % changed if/else to ceil
numstates=max_price/width_state;
if (numstates~=round(numstates))
    if(numstates<round(numstates))
        numstates=round(numstates);
    else
        numstates=round(numstates)+1; 
    end
end
lim = 0+width_state*numstates;
states = 0:width_state:lim;
N = histc(elec_prices,states);
P=zeros(numel(N));
for iter=1:numel(elec_prices)-1
    transit=elec_prices(iter:iter+1);
    if(transit(1) < 0)
        state1 = -1;
    else
        state1=floor(transit(1)/width_state);
    end
    
    if(transit(2) < 0)
        state2 = -1;
    else 
        state2=floor(transit(2)/width_state);
    end
    
        P(state1+2,state2+2)=P(state1+2,state2+2)+1;
end
last=elec_prices(end);
state_last=floor(last/width_state);
N(state_last+1)=N(state_last+1)-1;

for iter=1:numel(N)
    P(iter,1:end)=P(iter,1:end)./N(iter);    
end
% P=P(1:end-1,1:end-1);

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

wind_values=linspace(states(start),states(start+1));
chosen_value=wind_values(randi([1,numel(wind_values)],1));
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
     wind_values=linspace(states(next_state),states(next_state+1));
     chosen_value=wind_values(randi([1,numel(wind_values)],1));
     wind_simul(iter)=chosen_value;
     start=next_state;
end



%plotting 'training' and simulated time series
figure;clf;
plot(elec_prices,'g');
title('Actual wind data');
ylabel('Wind Power in MW');
xlabel('Time in hrs');

figure;clf;
plot(wind_simul,'r');
title('Simulated wind data');
ylabel('Wind Power in MW');
xlabel('Time in hrs');

%plotting acf
figure;clf;
hold on;
[ACF_orig,~]=autocorr(elec_prices,24);
[ACF_simul,~]=autocorr(wind_simul,24);
plot(1:numel(ACF_orig),ACF_orig)
plot(1:numel(ACF_simul),ACF_simul,'-.')
title('Comparison of autocorrelation function (acf)');
legend('acf of input wind power time series','acf of simulated series');
xlabel('time lag');ylabel('autocorrelation');
hold off;

%plotting pdf
pdf_orig=histc(elec_prices,states);
pdf_simul=histc(wind_simul,states);
figure;clf;
subplot(2,1,1), bar(states,pdf_orig,'barwidth',1);
title ('pdf of input wind power time series');
ylabel('frequency');
subplot(2,1,2), bar(states,pdf_simul,'barwidth',1);
title ('pdf of simulated time series');
xlabel('Wind Power Output (MW)');ylabel('frequency');
save('O_w.mat','wind_simul');
