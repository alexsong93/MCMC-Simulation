%% Generating wind power time series by MCMC method
clc; clear all;

% simulation details
width_state=150;  % this denotes the number of elements in each state of the Markov Chain
simul_len=8784*30; % this is the length of the simulated wind power data
wind_simul=zeros(simul_len,1);
count=1;
start_wind=0;
for iter0=1:3
    Wind_10min=xlsread(['4431_WindPower' num2str(2003+iter0) '.xlsm'],'G10:G52713'); % Refers to ewits time-series wind data
    iter=1;k=5;
    while(iter+k<=numel(Wind_10min))
        if(iter>1)
            k=6;
        end
        if(iter+k<=numel(Wind_10min))
            Wind_hourly(count)=sum(Wind_10min(iter:iter+k))/k;
            count=count+1;
        end
        iter=iter+k;
    end
end

start_wind=sum(Wind_hourly(1:24:end))/numel(Wind_hourly(1:24:end));
%Wind_hourly=[0 1 22 35 2 18 17 14]; % this is test data

%% creating state transition matrix
max_wind=max(Wind_hourly);
numstates=max_wind/width_state;
if (numstates~=round(numstates))
    if(numstates<round(numstates))
        numstates=round(numstates);
    else
        numstates=round(numstates)+1; 
    end
end
lim = 0+width_state*numstates;
states = 0:width_state:lim;
N = histc(Wind_hourly,states);
P=zeros(numel(N));

for iter=1:numel(Wind_hourly)-1
    transit=Wind_hourly(iter:iter+1);
    state1=floor(transit(1)/width_state);
    state2=floor(transit(2)/width_state);
    P(state1+1,state2+1)=P(state1+1,state2+1)+1;
end

last=Wind_hourly(end);
state_last=floor(last/width_state);
N(state_last+1)=N(state_last+1)-1;
for iter=1:numel(N)
    P(iter,1:end)=P(iter,1:end)./N(iter);    
end
P=P(1:end-1,1:end-1);


