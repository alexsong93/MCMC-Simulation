% steps = 100000;
m = 3;
steps = 130000;
progressbar('Monte Carlo Trials','Simulation');
for num = 1:m
    count = 0;
    for step = 1:steps
        count = count + 1;
        frac2 = count / steps;  
        frac1 = ((num-1) + frac2) / m;
        if(mod(count,100)==0)
            progressbar(frac1, frac2);
        end
    end
end


% m = 4;
% n = 3;
% p = 100;
% progressbar('Monte Carlo Trials','Simulation','Component') % Init 3 bars
% for i = 1:m
%     for j = 1:n
%         for k = 1:p
%             pause(0.01) % Do something important
%             % Update all bars
%             frac3 = k/p;
%             frac2 = ((j-1) + frac3) / n;
%             frac1 = ((i-1) + frac2) / m;
%             progressbar(frac1, frac2, frac3)
%         end
%     end
% end

%statusbar;  % delete status bar from current figure
%statusbar('Desktop status: processing...');
% statusbar([hFig1,hFig2], 'Please wait while processing...');
% statusbar('Processing %d of %d (%.1f%%)...',idx,total,100*idx/total);
% statusbar('Running... [%s%s]',repmat('*',1,fix(N*idx/total)),repmat('.',1,N-fix(N*idx/total)));
% existingText = get(statusbar(myHandle),'Text');


% % Single bar
% m = 500;
% progressbar % Init single bar
% for i = 1:m
%   pause(0.01) % Do something important
%   progressbar(i/m) % Update progress bar
% end