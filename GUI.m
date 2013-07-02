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

% Last Modified by GUIDE v2.5 20-Jun-2013 00:24:13

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
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
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

[BIC,data_orig,data_simul,states] = MCMC_Simul(filename,order_value,...
    numstates_value,interval_value,unit_value,length_value);   

set(handles.BIC_text,'String',BIC);
set(handles.data_text,'String',filename);

%plotting the acf
if(strcmp(unit_value,'minute(s)')==1)
    [ACF_orig,~]=autocorr(data_orig,(60/interval_value)*24*2); %2 days
    [ACF_simul,~]=autocorr(data_simul,(60/interval_value)*24*2);
elseif(strcmp(unit_value,'hour(s)')==1)
    [ACF_orig,~]=autocorr(data_orig,(60/interval_value)*24*2); %2 days
    [ACF_simul,~]=autocorr(data_simul,(60/interval_value)*24*2);
else
    if(interval_value == 1)
        [ACF_orig,~]=autocorr(data_orig,(interval_value*2)); %2 days
        [ACF_simul,~]=autocorr(data_simul,(interval_value*2));
    else
        [ACF_orig,~]=autocorr(data_orig,(interval_value));
        [ACF_simul,~]=autocorr(data_simul,(interval_value));
    end
end

plot(handles.acf_plot, 1:numel(ACF_orig),ACF_orig,'k-',...
                       1:numel(ACF_simul),ACF_simul,'b--');
title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
legend(handles.acf_plot,'acf of original time series','acf of simulated series');
xlabel(handles.acf_plot,strcat('time lag (',num2str(interval_value),unit_value,')'));
ylabel(handles.acf_plot,'autocorrelation');
grid(handles.acf_plot, 'on');

%plotting the pdf
pdf_orig=histc(data_orig,states);
pdf_orig=pdf_orig(1:end-1)./numel(data_orig);
pdf_simul=histc(data_simul,states);
pdf_simul=pdf_simul(1:end-1)./numel(data_simul);
pdf = bar(handles.orig_pdf,[pdf_orig,pdf_simul],'barwidth',1);
% str = strcat('set(handles.orig_pdf,''XTickLabel'',{''',num2str(states(1)),'~',num2str(states(2)),'''');
% for i = 2:numel(states)-1
%     str = strcat(str,',''',num2str(states(i)),'~',num2str(states(i+1)),'''');
% end
% 
% str = strcat(str,'});');

str = strcat('set(handles.orig_pdf,''XTickLabel'',{''',num2str(states(1)),'''');
for i = 2:numel(states)
    str = strcat(str,',''',num2str(states(i)),'''');
end

str = strcat(str,'});');

eval(str);
colormap(summer);
l = cell(1,2);
l{1}='original';l{2}='simulated';
legend(pdf,l);
title (handles.orig_pdf,'pdf of original and simulated time series');
xlabel(handles.orig_pdf,'Wind Power Output (MW)');ylabel(handles.orig_pdf,'Density');
grid(handles.orig_pdf,'on');

%plot training and simulated data
plot(handles.orig_data,data_orig,'g');
title(handles.orig_data,'Actual wind data');
ylabel(handles.orig_data,'Wind Power in MW');
xlabel(handles.orig_data,'Time in hrs');

if(numel(data_simul)>numel(data_orig))
    data_simul = data_simul(1:numel(data_orig));
end
plot(handles.sim_data,data_simul,'b');
title(handles.sim_data,'Simulated wind data');
ylabel(handles.sim_data,'Wind Power in MW');
xlabel(handles.sim_data,'Time in hrs');


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function tabs_Callback(hObject, eventdata, handles)
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in back_push.
function back_push_Callback(hObject, eventdata, handles)
% hObject    handle to back_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MCMC_pre;
close(handles.GUI);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
