function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 20-Aug-2013 17:03:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.GUI);

hMainGui = getappdata(0, 'hMainGui');
filename = getappdata(hMainGui, 'filename');
order_value = getappdata(hMainGui, 'order');
order_value = str2double(order_value);
numstates_value = getappdata(hMainGui, 'num');
numstates_value = str2double(numstates_value);
interval_value = getappdata(hMainGui, 'interval');
interval_value = str2double(interval_value);
unit_value = getappdata(hMainGui, 'unit');
length_value = getappdata(hMainGui, 'length');
length_value = str2double(length_value);

orig_length_value = getappdata(hMainGui, 'orig_length');
orig_length_value = str2double(orig_length_value);
leap_yes = getappdata(hMainGui, 'leap_yes');
leap_no = getappdata(hMainGui, 'leap_no');
leap_value = getappdata(hMainGui, 'leap_value');
no_sample = getappdata(hMainGui, 'no_sample');
seasons_check = getappdata(hMainGui, 'seasons_check');
morn_check = getappdata(hMainGui, 'morn_check');
hourly_sample = getappdata(hMainGui, 'hourly_sample');

% call MCMC_Simul and perform the MCMC simulation
[cap_factors,data_orig,data_simul,states] = MCMC_Simul(filename,order_value,...
    numstates_value,interval_value,unit_value,length_value,orig_length_value,...
    leap_yes,leap_no,leap_value,no_sample,seasons_check,morn_check,hourly_sample);   

handles.data_orig = data_orig;
handles.data_simul = data_simul;
handles.unit_value = unit_value;
handles.interval_value = interval_value;
handles.states = states;
handles.seasons_check = seasons_check;
handles.morn_check = morn_check;
if(isempty(handles.morn_check))
    handles.morn_check = 0;
end
if(isempty(handles.seasons_check))
    handles.seasons_check = 0;
end

guidata(hObject,handles)


% capacity table
set(handles.cap_table,'data',cap_factors);

% set(handles.BIC_text,'String',BIC);
set(handles.data_text,'String',filename);

% %plotting the acf/pdf
if(handles.morn_check == 0 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,4)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,4,handles.states)
elseif(handles.morn_check == 0 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1,handles.states)
elseif(handles.morn_check == 1 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,13)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,13,handles.states)
elseif(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,5)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,5,handles.states)
end

% if(handles.morn_check == 0 && handles.seasons_check == 1)
%     
% elseif(handles.morn_check == 0 && handles.seasons_check == 0)
%     
% elseif(handles.morn_check == 1 && handles.seasons_check == 1)
%     pdf_orig = histc(data_orig{13},states);
%     bar(handles.pdf_plot,pdf_orig,'barwidth',1);
% elseif(handles.morn_check == 1 && handles.seasons_check == 0)
%     
% end
% %plotting the pdf
% pdf_orig=histc(data_orig{13},states);
% pdf_orig=pdf_orig(1:end-1)./numel(data_orig{13});
% pdf_simul=histc(data_simul{13},states);
% pdf_simul=pdf_simul(1:end-1)./numel(data_simul{13});
% pdf = bar(handles.pdf_plot,[pdf_orig,pdf_simul],'barwidth',1);
% % str = strcat('set(handles.pdf_plot,''XTickLabel'',{''',num2str(states(1)),...
% %                 '~',num2str(states(2)),'''');
% % for i = 2:numel(states)-1
% %     str = strcat(str,',''',num2str(states(i)),'~',num2str(states(i+1)),'''');
% % end
% % str = strcat(str,'});');
% % eval(str);
% % axes(handles.pdf_plot);
% % xticklabel_rotate([],45,[],'Fontsize',9);
% 
% str = strcat('set(handles.pdf_plot,''XTickLabel'',{''',num2str(floor(states(1))),'''');
% for i = 2:numel(states)
%     str = strcat(str,',''',num2str(floor(states(i))),'''');
% end
% str = strcat(str,'});');
% eval(str);
% 
% colormap(summer);
% l = cell(1,2);
% l{1}='original';l{2}='simulated';
% legend(pdf,l);
% title (handles.pdf_plot,'pdf of original and simulated time series');
% xlabel(handles.pdf_plot,'Wind Power Output (KW)');ylabel(handles.pdf_plot,'Density');
% grid(handles.pdf_plot,'on');
% 
% % plot training and simulated data
if(handles.morn_check == 0 && handles.seasons_check == 1)
    plot(handles.orig_data,data_orig{4},'g');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.orig_data,'original wind data');
    ylabel(handles.orig_data,'Wind Power in KW');
    xlabel(handles.orig_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
    if(numel(data_simul{4})>numel(data_orig{4}))
        data_simul{4} = data_simul{4}(1:numel(data_orig{4}));
    end
    plot(handles.sim_data,data_simul{4},'b');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.sim_data,'simulated wind data');
    ylabel(handles.sim_data,'Wind Power in KW');
    xlabel(handles.sim_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
elseif(handles.morn_check == 0 && handles.seasons_check == 0)
    plot(handles.orig_data,data_orig{1},'g');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.orig_data,'original wind data');
    ylabel(handles.orig_data,'Wind Power in KW');
    xlabel(handles.orig_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
    if(numel(data_simul{1})>numel(data_orig{1}))
        data_simul{13} = data_simul{1}(1:numel(data_orig{1}));
    end
    plot(handles.sim_data,data_simul{1},'b');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.sim_data,'simulated wind data');
    ylabel(handles.sim_data,'Wind Power in KW');
    xlabel(handles.sim_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
elseif(handles.morn_check == 1 && handles.seasons_check == 1)
    plot(handles.orig_data,data_orig{13},'g');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.orig_data,'original wind data');
    ylabel(handles.orig_data,'Wind Power in KW');
    xlabel(handles.orig_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
    if(numel(data_simul{13})>numel(data_orig{13}))
        data_simul{13} = data_simul{13}(1:numel(data_orig{13}));
    end
    plot(handles.sim_data,data_simul{13},'b');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.sim_data,'simulated wind data');
    ylabel(handles.sim_data,'Wind Power in KW');
    xlabel(handles.sim_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
elseif(handles.morn_check == 1 && handles.seasons_check == 0)
    plot(handles.orig_data,data_orig{5},'g');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.orig_data,'original wind data');
    ylabel(handles.orig_data,'Wind Power in KW');
    xlabel(handles.orig_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
    if(numel(data_simul{5})>numel(data_orig{5}))
        data_simul{5} = data_simul{5}(1:numel(data_orig{5}));
    end
    plot(handles.sim_data,data_simul{5},'b');
    %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
    title(handles.sim_data,'simulated wind data');
    ylabel(handles.sim_data,'Wind Power in KW');
    xlabel(handles.sim_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
end


% plot(handles.sim_data,data_simul{13},'b');
% title(handles.sim_data,'Simulated wind data');
% ylabel(handles.sim_data,'Wind Power in MW');
% xlabel(handles.sim_data,'Time in hrs');

% plot(handles.sim_data,data_simul{13},'b');
% %axis(handles.orig_data,[0 144*7 0 max(max(data_simul{1}), max(data_orig{1}))]);
% title(handles.sim_data,'simulated wind data');
% ylabel(handles.sim_data,'Wind Power in KW');
% xlabel(handles.orig_data,strcat('Time ','(in',num2str(interval_value),unit_value,')'));
% hold(handles.orig_data,'off')





% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%set height of each row of table
table = handles.cap_table;
jUIScrollPane = findjobj(table);
jTable = jUIScrollPane.getViewport.getView;
jTable.setRowHeight(55);



function tabs_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to tabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tabs as text
%        str2double(get(hObject,'String')) returns contents of tabs as a double


% --- Executes during object creation, after setting all properties.
function tabs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in back_push.
function back_push_Callback(hObject, eventdata, handles)
% hObject    handle to back_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Pre_MCMC;
close(handles.GUI);


function plotAcf(acf_plot,data_orig,data_simul,unit_value,interval_value,numdays,index)
    if(strcmp(unit_value,'minute(s)')==1)
        [ACF_orig,~]=autocorr(data_orig{index},(60/interval_value)*24*numdays);
        [ACF_simul,~]=autocorr(data_simul{index},(60/interval_value)*24*numdays);
    elseif(strcmp(unit_value,'hour(s)')==1)
        [ACF_orig,~]=autocorr(data_orig{index},(60/interval_value)*24*numdays);
        [ACF_simul,~]=autocorr(data_simul{index},(60/interval_value)*24*numdays);
    else
        if(interval_value == 1)
            [ACF_orig,~]=autocorr(data_orig{index},(interval_value*numdays));
            [ACF_simul,~]=autocorr(data_simul{index},(interval_value*numdays));
        else
            [ACF_orig,~]=autocorr(data_orig{index},(interval_value));
            [ACF_simul,~]=autocorr(data_simul{index},(interval_value));
        end
    end

    plot(acf_plot, 1:numel(ACF_orig),ACF_orig,'k-',...
                           1:numel(ACF_simul),ACF_simul,'b--');
    title(acf_plot,'Comparison of autocorrelation function (acf)');
    legend(acf_plot,'acf of original time series','acf of simulated series');
    xlabel(acf_plot,strcat('time lag (',num2str(interval_value),unit_value,')'));
    ylabel(acf_plot,'autocorrelation');
    grid(acf_plot, 'on');

    
function plotPdf(pdf_plot,data_orig,data_simul,unit_value,interval_value,numdays,index,states)
    if(strcmp(unit_value,'minute(s)')==1)
        pdf_orig=histc(data_orig{index},states);
        pdf_orig=pdf_orig(1:end-1)./numel(data_orig{index});
        pdf_simul=histc(data_simul{index},states);
        pdf_simul=pdf_simul(1:end-1)./numel(data_simul{index});
        pdf = bar(pdf_plot,[pdf_orig,pdf_simul],'barwidth',1);
        % str = strcat('set(handles.pdf_plot,''XTickLabel'',{''',num2str(states(1)),...
        %                 '~',num2str(states(2)),'''');
        % for i = 2:numel(states)-1
        %     str = strcat(str,',''',num2str(states(i)),'~',num2str(states(i+1)),'''');
        % end
        % str = strcat(str,'});');
        % eval(str);
        % axes(handles.pdf_plot);
        % xticklabel_rotate([],45,[],'Fontsize',9);

        str = strcat('set(pdf_plot,''XTickLabel'',{''',num2str(floor(states(1))),'''');
        for i = 2:numel(states)
            str = strcat(str,',''',num2str(floor(states(i))),'''');
        end
        str = strcat(str,'});');
        eval(str);

        colormap(summer);
        l = cell(1,2);
        l{1}='original';l{2}='simulated';
        legend(pdf,l);
        title (pdf_plot,'pdf of original and simulated time series');
        xlabel(pdf_plot,'Wind Power Output (KW)');ylabel(pdf_plot,'Density');
        grid(pdf_plot,'on');
    end



% --------------------------------------------------------------------


% --- Executes on button press in yearly_toggle.
function yearly_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to yearly_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yearly_toggle

if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end

if(handles.morn_check == 0 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,4)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,4,handles.states)
elseif(handles.morn_check == 0 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1,handles.states)
elseif(handles.morn_check == 1 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,13)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,13,handles.states)
elseif(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,5)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,5,handles.states)
end

% pdf_orig=histc(data_orig{1},states);
% pdf_orig=pdf_orig(1:end-1)./numel(data_orig{1});
% pdf_simul=histc(data_simul{1},states);
% pdf_simul=pdf_simul(1:end-1)./numel(data_simul{1});
% pdf = bar(handles.pdf_plot,[pdf_orig,pdf_simul],'barwidth',1);
% str = strcat('set(handles.pdf_plot,''XTickLabel'',{''',num2str(states(1)),...
%                 '~',num2str(states(2)),'''');
% for i = 2:numel(states)-1
%     str = strcat(str,',''',num2str(states(i)),'~',num2str(states(i+1)),'''');
% end
% str = strcat(str,'});');
% eval(str);
% axes(handles.pdf_plot);
% xticklabel_rotate([],45,[],'Fontsize',9);

% str = strcat('set(handles.pdf_plot,''XTickLabel'',{''',num2str(floor(states(1))),'''');
% for i = 2:numel(states)
%     str = strcat(str,',''',num2str(floor(states(i))),'''');
% end
% str = strcat(str,'});');
% eval(str);
% 
% colormap(summer);
% l = cell(1,2);
% l{1}='original';l{2}='simulated';
% legend(pdf,l);
% title (handles.pdf_plot,'pdf of original and simulated time series');
% xlabel(handles.pdf_plot,'Wind Power Output (KW)');ylabel(handles.pdf_plot,'Density');
% grid(handles.pdf_plot,'on');
    
set(handles.summer_toggle,'Value',0);
set(handles.spring_toggle,'Value',0);
set(handles.winter_toggle,'Value',0);

set(handles.morning_toggle,'Value',0);
set(handles.afternoon_toggle,'Value',0);
set(handles.evening_toggle,'Value',0);
set(handles.night_toggle,'Value',0);


% --- Executes on button press in summer_toggle.
function summer_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to summer_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of summer_toggle

if(get(hObject,'Value')==0)
    set(hObject,'Value',1);
end

set(handles.yearly_toggle,'Value',0);
set(handles.spring_toggle,'Value',0);
set(handles.winter_toggle,'Value',0);

%only season is checked
if(handles.morn_check == 0 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,1,handles.states)
end
    
% pdf_orig=histc(handles.data_orig{1},handles.states);
% pdf_orig=pdf_orig(1:end-1)./numel(handles.data_orig{1});
% 
% pdf_simul=histc(handles.data_simul{1},handles.states);
% pdf_simul=pdf_simul(1:end-1)./numel(handles.data_simul{1});
% 
% parentHandle1 = bar(handles.pdf_plot,pdf_orig,'barwidth',1);
% childHandle1 = get(parentHandle1,'Children');
% set(childHandle1,'FaceAlpha',0.5);
% hold on;
% parentHandle2 = bar(handles.pdf_plot,pdf_simul,'barwidth',1);
% childHandle2 = get(parentHandle2,'Children');
% set(childHandle2,'FaceAlpha',0.5);
% hold off;
% 
% 
% title (handles.pdf_plot,'pdf of input wind power time series');
% ylabel(handles.pdf_plot,'frequency');
% xlabel(handles.pdf_plot,'Wind Power Output (MW)')
% grid(handles.pdf_plot,'on');



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




% --- Executes on button press in spring_toggle.
function spring_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to spring_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spring_toggle

if(get(hObject,'Value')==0)
    set(hObject,'Value',1);
end

set(handles.yearly_toggle,'Value',0);
set(handles.summer_toggle,'Value',0);
set(handles.winter_toggle,'Value',0);    

%only season is checked
if(handles.morn_check == 0 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,2)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,2,handles.states)
end

% pdf_orig=histc(handles.data_orig{2},handles.states);
% pdf_orig=pdf_orig(1:end-1)./numel(handles.data_orig{2});
% 
% pdf_simul=histc(handles.data_simul{2},handles.states);
% pdf_simul=pdf_simul(1:end-1)./numel(handles.data_simul{2});
% 
% bar(handles.pdf_plot,pdf_orig,'barwidth',1);
% title ('pdf of input wind power time series');
% ylabel('frequency');
% % subplot(2,1,2), bar(handles.states,pdf_simul,'barwidth',1);
% % title ('pdf of simulated time series');
% xlabel('Wind Power Output (MW)');ylabel('frequency');  


% --- Executes on button press in winter_toggle.
function winter_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to winter_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of winter_toggle

if(get(hObject,'Value')==0)
    set(hObject,'Value',1);
end

set(handles.yearly_toggle,'Value',0);
set(handles.spring_toggle,'Value',0);
set(handles.summer_toggle,'Value',0);

if(handles.morn_check == 0 && handles.seasons_check == 1)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,3)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
        handles.unit_value,handles.interval_value,2,3,handles.states)
end

% pdf_orig=histc(handles.data_orig{3},handles.states);
% pdf_orig=pdf_orig(1:end-1)./numel(handles.data_orig{3});
% 
% pdf_simul=histc(handles.data_simul{3},handles.states);
% pdf_simul=pdf_simul(1:end-1)./numel(handles.data_simul{3});
% 
% bar(handles.pdf_plot,pdf_orig,'barwidth',1);
% title ('pdf of input wind power time series');
% ylabel('frequency');
% % subplot(2,1,2), bar(handles.states,pdf_simul,'barwidth',1);
% % title ('pdf of simulated time series');
% xlabel('Wind Power Output (MW)');ylabel('frequency');  
    

% --- Executes on button press in morning_toggle.
function morning_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to morning_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of morning_toggle

set(handles.yearly_toggle,'Value',0);
set(handles.afternoon_toggle,'Value',0);
set(handles.evening_toggle,'Value',0);
set(handles.night_toggle,'Value',0);

% both seasons and time of day are checked
if(handles.morn_check == 1 && handles.seasons_check == 1)
    if(get(handles.summer_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,1)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,1,handles.states)
    elseif(get(handles.spring_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,5)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,5,handles.states)    
    elseif(get(handles.winter_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,9)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,9,handles.states)    
    end
end

% only time of day is checked
if(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,1)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,1,handles.states)    
end


% --- Executes on button press in afternoon_toggle.
function afternoon_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to afternoon_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of afternoon_toggle

set(handles.yearly_toggle,'Value',0);
set(handles.morning_toggle,'Value',0);
set(handles.evening_toggle,'Value',0);
set(handles.night_toggle,'Value',0);

% both seasons and time of day are checked
if(handles.morn_check == 1 && handles.seasons_check == 1)
    if(get(handles.summer_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,2)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,2,handles.states)    
    elseif(get(handles.spring_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,6)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,6,handles.states)    
    elseif(get(handles.winter_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,10)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,10,handles.states)    
    end
end

% only time of day is checked
if(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,2)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,2,handles.states)    
end

% --- Executes on button press in evening_toggle.
function evening_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to evening_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of evening_toggle

set(handles.yearly_toggle,'Value',0);
set(handles.morning_toggle,'Value',0);
set(handles.afternoon_toggle,'Value',0);
set(handles.night_toggle,'Value',0);

% both seasons and time of day are checked
if(handles.morn_check == 1 && handles.seasons_check == 1)
    if(get(handles.summer_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,3)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,3,handles.states)    
    elseif(get(handles.spring_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,7)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,7,handles.states)    
    elseif(get(handles.winter_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,11)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,11,handles.states)    
    end
end

% only time of day is checked
if(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,3)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,3,handles.states)    
end


% --- Executes on button press in night_toggle.
function night_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to night_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of night_toggle

set(handles.yearly_toggle,'Value',0);
set(handles.morning_toggle,'Value',0);
set(handles.afternoon_toggle,'Value',0);
set(handles.evening_toggle,'Value',0);

% both seasons and time of day are checked
if(handles.morn_check == 1 && handles.seasons_check == 1)
    if(get(handles.summer_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,4)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,4,handles.states)    
    elseif(get(handles.spring_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,8)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,4,handles.states)    
    elseif(get(handles.winter_toggle,'Value')==1)
        plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,12)
        plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
                handles.unit_value,handles.interval_value,2,12,handles.states)    
    end
end

% only time of day is checked
if(handles.morn_check == 1 && handles.seasons_check == 0)
    plotAcf(handles.acf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,4)
    plotPdf(handles.pdf_plot,handles.data_orig,handles.data_simul,...
            handles.unit_value,handles.interval_value,2,4,handles.states)    
end


% --- Executes on button press in simul_data_push.
function simul_data_push_Callback(hObject, eventdata, handles)
% hObject    handle to simul_data_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
simulated_data = handles.data_simul(end);
f = uiputfile('*.csv','Save Simulated Data As');
if(any(f))
    csvwrite(f,simulated_data);
end
