function varargout = GUI(varargin)

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
% Choose default command line output for GUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.GUI);

hMainGui = getappdata(0, 'hMainGui');
filename = getappdata(hMainGui, 'filename');
filename = strcat(filename);
order_value = getappdata(hMainGui, 'order');
order_value = str2double(order_value);
numstates_value = getappdata(hMainGui, 'num');
numstates_value = str2double(numstates_value);
interval_value = getappdata(hMainGui, 'interval');
interval_value = str2double(interval_value);
unit_value = getappdata(hMainGui, 'unit_value');
length_value = getappdata(hMainGui, 'length');
length_value = str2double(length_value);
orig_length_value = getappdata(hMainGui, 'orig_length');
orig_length_value = str2double(orig_length_value);
leap_yes = getappdata(hMainGui, 'leap_yes');
leap_value = getappdata(hMainGui, 'leap_value');
yes_sample = getappdata(hMainGui, 'yes_sample');

[BIC,data_orig,data_simul,states,cap_factors] = MCMC_Simul(filename,order_value,...
    numstates_value,interval_value,unit_value,length_value,orig_length_value,...
    leap_yes,leap_value,yes_sample);   

% capacity table
set(handles.cap_table,'data',cap_factors);
%set(handles.BIC_text,'String',BIC);
set(handles.data_text,'String',filename);

handles.unit_value = unit_value;
handles.data_orig = data_orig;
handles.data_simul = data_simul;
handles.interval_value = interval_value;
handles.states = states;
handles.yes_sample = yes_sample;

data = guidata(hObject);

set(handles.time_buttongroup,'SelectionChangeFcn',...
    {@time_buttongroup_SelectionChangeFcn,handles,data});

plotACF(handles,unit_value,data_orig,data_simul,interval_value,13);
plotPMF(handles,data_orig,data_simul,states,13);
plotData(handles,data_orig,data_simul,13);

function plotACF(handles,unit_value,data_orig,data_simul,interval_value,index)
    if(strcmp(unit_value,'minute(s)')==1)
        [ACF_orig,~]=autocorr(data_orig{index},(60/interval_value)*24*2); %2 days
        [ACF_simul,~]=autocorr(data_simul{index},(60/interval_value)*24*2);
    elseif(strcmp(unit_value,'hour(s)')==1)
        [ACF_orig,~]=autocorr(data_orig{index},(60/interval_value)*24*2); %2 days
        [ACF_simul,~]=autocorr(data_simul{index},(60/interval_value)*24*2);
    end

    plot(handles.acf_plot, 1:numel(ACF_orig),ACF_orig,'k-',...
                           1:numel(ACF_simul),ACF_simul,'b--');
    title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
    legend(handles.acf_plot,'acf of original time series','acf of simulated series');
    xlabel(handles.acf_plot,strcat('time lag (',num2str(interval_value),unit_value,')'));
    ylabel(handles.acf_plot,'autocorrelation');
    grid(handles.acf_plot, 'on');
    

function plotPMF(handles,data_orig,data_simul,states,index)
    pdf_orig=histc(data_orig{13},states);
    pdf_orig=pdf_orig(1:end-1)./numel(data_orig{13});
    pdf_simul=histc(data_simul{13},states);
    pdf_simul=pdf_simul(1:end-1)./numel(data_simul{13});
    pdf = bar(handles.orig_pdf,[pdf_orig,pdf_simul],'barwidth',1);
    str = strcat('set(handles.orig_pdf,''XTickLabel'',{''',num2str(floor(states(1))),...
                    '~',num2str(floor(states(2))),'''');
    for i = 2:numel(states)-1
        str = strcat(str,',''',num2str(floor(states(i))),'~',num2str(floor(states(i+1))),'''');
    end
    str = strcat(str,'});');
    eval(str);
    axes(handles.orig_pdf);
    xticklabel_rotate([],45,[],'Fontsize',9);

    colormap(summer);
    l = cell(1,2);
    l{1}='original';l{2}='simulated';
    legend(pdf,l);
    title (handles.orig_pdf,'pmf of original and simulated time series');
    xlabel(handles.orig_pdf,'Wind Power Output (KW)');ylabel(handles.orig_pdf,'Density');
    grid(handles.orig_pdf,'on');


function plotData(handles,data_orig,data_simul,index)
    %plot training and simulated data
    plot(handles.orig_data,data_orig{13},'g');
    title(handles.orig_data,'Actual wind data');
    ylabel(handles.orig_data,'Wind Power in KW');
    xlabel(handles.orig_data,'Time in hrs');

    if(numel(data_simul)>numel(data_orig{13}))
        data_simul = data_simul(1:numel(data_orig{13}));
    end
    plot(handles.sim_data,data_simul{13},'b');
    title(handles.sim_data,'Simulated wind data');
    ylabel(handles.sim_data,'Wind Power in KW');
    xlabel(handles.sim_data,'Time in hrs');





% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
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

% --- Executes during object creation, after setting all properties.
function tabs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Displaying acf/pdf of different times if sample selection is selected
function time_buttongroup_SelectionChangeFcn(hObject,eventdata, handles, data)
if(handles.yes_sample==1)
    switch get(eventdata.NewValue,'Tag')
        case 'default'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,13);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,13);
        case 'summerMorning'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,1);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,1);
        case 'summerAfternoon'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,2);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,2);
        case 'summerEvening'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,3);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,3);
        case 'summerNight'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,4);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,4);
        case 'sprfallMorning'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,5);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,5);
        case 'sprfallAfternoon'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,6);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,6);
        case 'sprfallEvening'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,7);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,7);
        case 'sprfallNight'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,8);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,8);
        case 'winterMorning'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,9);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,9);
        case 'winterAfternoon'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,10);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,10);
        case 'winterEvening'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,11);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,11);
        case 'winterNight'
            plotACF(handles,handles.unit_value,handles.data_orig,...
                handles.data_simul,handles.interval_value,12);
            plotPMF(handles,handles.data_orig,handles.data_simul,...
                handles.states,12);
    end
end

% --- Executes on button press in back_push.
function back_push_Callback(hObject, eventdata, handles)
Pre_MCMC;
close(handles.GUI);

