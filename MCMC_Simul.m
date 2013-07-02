function [BIC,data_orig,data_simul,states] = MCMC_Simul(data,order,num,intv,unit,len)

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

% if(nargin~=6)                       % no/incorrect number of arguments
%     errordlg('Please input 6 arguments.');
% end

% calculate length of simulated data based on time interval and unit
if(strcmp(unit,'minute(s)')==1)
    len = floor((525949*len)/intv);
elseif(strcmp(unit,'hour(s)')==1)
    len = floor((8766*len)/intv);
else
    len = floor((365*len)/intv);
end

simul_len = len;
data_simul=zeros(simul_len,1);
data_orig = csvread(data);         % original data in csv form

min_data = min(data_orig);
data_orig = data_orig + -1.*min_data;

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
        next_state = sum(C(start_row,:)<u_rand)+1;
        %next_state = pickNextState(n,start,C);
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
        %next_state = pickNextState(row_len,start_row,C);
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
        %toAdd = (numstates.^(order-1)).*(next_state-1);

%         if(numstates < 10)
%             last = (xy{start_row}(4)-48);
%             start_row = toAdd + last;
%         else
%             if(xy{start_row}(5)+0 == 32)
%                 last = (xy{start_row}(6)-48);
%                 start_row = toAdd +last;
%             else
%                 last = str2double(xy{start_row}(5))*10 +(xy{start_row}(6)-48);
%                 start_row = toAdd + last;
%             end
%         end

%         out = isValid(start_row,C); %check if start_row is not all zeros
%         while(out==0)
%             start_row = randi([1,col_len-1],1);
%             out = isValid(start_row,C);
%         end
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


data_orig = data_orig - -1.*min_data;
data_simul = data_simul - -1.*min_data;
states = states - -1.*min_data;


% % Plotting the results - uncomment when testing/not using the GUI
% %plotting 'training' and simulated time series
% figure;clf;
% plot(data_orig,'g');
% title('Actual wind data');
% ylabel('Wind Power in MW');
% xlabel('Time in hrs');
% 
% figure;clf;
% plot(data_simul,'r');
% title('Simulated wind data');
% ylabel('Wind Power in MW');
% xlabel('Time in hrs');
% 
% %plotting acf
% figure(1);clf;
% hold on;
% [ACF_orig,~]=autocorr(data_orig,6*24*2); %2days
% [ACF_simul,~]=autocorr(data_simul,6*24*2);
% plot(1:numel(ACF_orig),ACF_orig)
% plot(1:numel(ACF_simul),ACF_simul,'-.')
% title('Comparison of autocorrelation function (acf)');
% legend('acf of input wind power time series','acf of simulated series');
% xlabel('time lag');ylabel('autocorrelation');
% hold off;
% 
% 
% %plotting pdf
% 
% pdf_orig=histc(data_orig,states)./numel(data_orig);
% pdf_simul=histc(data_simul,states)./numel(data_simul);
% figure(2);clf;
% pdf = bar(states,[pdf_orig,pdf_simul],'barwidth',1);
% colormap(summer)
% grid on
% l = cell(1,2);
% l{1}='original';l{2}='simulated';
% legend(pdf,l);
% hold on
% %subplot(2,1,1)
% parentHandle1 = bar(states,pdf_orig,'barwidth',1);
% childHandle1 = get(parentHandle1,'Children');
% set(childHandle1,'FaceAlpha',0.5);
% %set(gca,'XLim',[-80 lim+30])
% %subplot(2,1,2)
% parentHandle2 = bar(states,pdf_simul,'barwidth',1);
% childHandle2 = get(parentHandle2,'Children');
% set(childHandle2,'FaceAlpha',0.5);
% %set(gca,'XLim',[-80 lim+30])
% title ('pdf of original and simulated time series');
% xlabel('Wind Power Output (MW)');ylabel('Density');
% hold off


end

% pick the next state based on u_rand
function next_state = pickNextState(row_len,start_row,C)
    u_rand=rand(1,1);
    % finding next state as indicated by u_rand
%     next_state = 0;
%     for iter1=2:row_len
%         if(u_rand<=C(start_row,1))
%             next_state=1;
%         elseif(C(start_row,iter1-1)<u_rand && C(start_row,iter1)>=u_rand);
%              next_state=iter1; 
%         end
%     end
    next_state = 1;
    for j=1:row_len-1
        if(C(start_row,j) < u_rand && u_rand <= C(start_row,j+1))
            next_state = j+1;
        end
    end
end

% check to see if all elements of start_row are zero - means the state
% transition never happened so choose a different start_row
function out = isValid(start_row,C)
    if(C(start_row,:)==0)
        out = 0;
    else
        out = 1;
    end
end

