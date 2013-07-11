% Plotting the results - uncomment when testing/not using the GUI
%plotting 'training' and simulated time series
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
