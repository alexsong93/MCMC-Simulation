function varargout = MCMC_gui(varargin)
% MCMC_GUI MATLAB code for MCMC_gui.fig
%      MCMC_GUI, by itself, creates a new MCMC_GUI or raises the existing
%      singleton*.
%
%      H = MCMC_GUI returns the handle to a new MCMC_GUI or the handle to
%      the existing singleton*.
%
%      MCMC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MCMC_GUI.M with the given input arguments.
%
%      MCMC_GUI('Property','Value',...) creates a new MCMC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MCMC_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MCMC_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MCMC_gui

% Last Modified by GUIDE v2.5 06-Jun-2013 15:03:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MCMC_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @MCMC_gui_OutputFcn, ...
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


% --- Executes just before MCMC_gui is made visible.
function MCMC_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MCMC_gui (see VARARGIN)

title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
xlabel(handles.acf_plot,'time lag');ylabel(handles.acf_plot,'autocorrelation');
grid(handles.acf_plot, 'on');

title(handles.orig_pdf,'pdf of input wind power time series');
xlabel(handles.orig_pdf,'Wind Power Output (MW)');ylabel(handles.orig_pdf,'frequency');
grid(handles.orig_pdf,'on');

title (handles.sim_pdf,'pdf of simulated time series');
xlabel(handles.sim_pdf,'Wind Power Output (MW)');ylabel(handles.sim_pdf,'frequency');
grid(handles.sim_pdf,'on');


% Choose default command line output for MCMC_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MCMC_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MCMC_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in timeseries_popup.
function timeseries_popup_Callback(hObject, eventdata, handles)
% hObject    handle to timeseries_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timeseries_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from timeseries_popup
    

% --- Executes during object creation, after setting all properties.
function timeseries_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeseries_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FOMC_pushbutton.
function FOMC_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FOMC_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WindMCMC_new

%plotting the acf
[ACF_orig,~]=autocorr(Wind_hourly,24);
[ACF_simul,~]=autocorr(wind_simul,24);
plot(handles.acf_plot, 1:numel(ACF_orig),ACF_orig,1:numel(ACF_simul),ACF_simul,'-.')
title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
legend(handles.acf_plot,'acf of original time series','acf of simulated series');
xlabel(handles.acf_plot,'time lag');ylabel(handles.acf_plot,'autocorrelation');
grid(handles.acf_plot, 'on');

%plotting the pdf
pdf_orig=histc(Wind_hourly,states);
pdf_simul=histc(wind_simul,states);

bar(handles.orig_pdf,states,pdf_orig,'barwidth',1);
title(handles.orig_pdf,'pdf of input wind power time series');
xlabel(handles.orig_pdf,'Wind Power Output (MW)');ylabel(handles.orig_pdf,'frequency');
grid(handles.orig_pdf,'on');

bar(handles.sim_pdf,states,pdf_simul,'barwidth',1);
title (handles.sim_pdf,'pdf of simulated time series');
xlabel(handles.sim_pdf,'Wind Power Output (MW)');ylabel(handles.sim_pdf,'frequency');
grid(handles.sim_pdf,'on');

save('O_w.mat','wind_simul');

% --- Executes on button press in SOMC_pushbutton.
function SOMC_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SOMC_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WindMCMC_2ndO

%plotting the acf
[ACF_orig,~]=autocorr(Wind_hourly,24);
[ACF_simul,~]=autocorr(wind_simul,24);
plot(handles.acf_plot, 1:numel(ACF_orig),ACF_orig,1:numel(ACF_simul),ACF_simul,'-.')
title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
legend(handles.acf_plot,'acf of original time series','acf of simulated series');
xlabel(handles.acf_plot,'time lag');ylabel(handles.acf_plot,'autocorrelation');
grid(handles.acf_plot, 'on');

%plotting the pdf
pdf_orig=histc(Wind_hourly,states);
pdf_simul=histc(wind_simul,states);

bar(handles.orig_pdf,states,pdf_orig,'barwidth',1);
title(handles.orig_pdf,'pdf of input wind power time series');
xlabel(handles.orig_pdf,'Wind Power Output (MW)');ylabel(handles.orig_pdf,'frequency');
grid(handles.orig_pdf,'on');

bar(handles.sim_pdf,states,pdf_simul,'barwidth',1);
title (handles.sim_pdf,'pdf of simulated time series');
xlabel(handles.sim_pdf,'Wind Power Output (MW)');ylabel(handles.sim_pdf,'frequency');
grid(handles.sim_pdf,'on');

save('O_w.mat','wind_simul');

% --- Executes on button press in TOMC_pushbutton.
function TOMC_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TOMC_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WindMCMC_3rdO

%plotting the acf
[ACF_orig,~]=autocorr(Wind_hourly,24);
[ACF_simul,~]=autocorr(wind_simul,24);
plot(handles.acf_plot, 1:numel(ACF_orig),ACF_orig,1:numel(ACF_simul),ACF_simul,'-.')
title(handles.acf_plot,'Comparison of autocorrelation function (acf)');
legend(handles.acf_plot,'acf of original time series','acf of simulated series');
xlabel(handles.acf_plot,'time lag');ylabel(handles.acf_plot,'autocorrelation');
grid(handles.acf_plot, 'on');

%plotting the pdf
pdf_orig=histc(Wind_hourly,states);
pdf_simul=histc(wind_simul,states);

bar(handles.orig_pdf,states,pdf_orig,'barwidth',1);
title(handles.orig_pdf,'pdf of input wind power time series');
xlabel(handles.orig_pdf,'Wind Power Output (MW)');ylabel(handles.orig_pdf,'frequency');
grid(handles.orig_pdf,'on');

bar(handles.sim_pdf,states,pdf_simul,'barwidth',1);
title (handles.sim_pdf,'pdf of simulated time series');
xlabel(handles.sim_pdf,'Wind Power Output (MW)');ylabel(handles.sim_pdf,'frequency');
grid(handles.sim_pdf,'on');

save('O_w.mat','wind_simul');

