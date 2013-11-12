function varargout = Pre_MCMC(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pre_MCMC_OpeningFcn, ...
                   'gui_OutputFcn',  @Pre_MCMC_OutputFcn, ...
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


% --- Executes just before Pre_MCMC is made visible.
function Pre_MCMC_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pre_MCMC wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(0, 'hMainGui', gcf);


% --- Outputs from this function are returned to the command line.
function varargout = Pre_MCMC_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function browse_text_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
hMainGui = getappdata(0, 'hMainGui');
filename = get(hObject,'String');
setappdata(hMainGui, 'filename', filename);

% --- Executes during object creation, after setting all properties.
function browse_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_push.
function browse_push_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
filename = uigetfile('*.csv');
set(handles.browse_text,'String',filename);
setappdata(hMainGui, 'filename', filename);


function interval_text_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
interval_value = get(hObject,'String');
setappdata(hMainGui, 'interval', interval_value);


% --- Executes on selection change in order_popup.
function order_popup_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
order_value = cellstr(get(hObject,'String'));
order_value = order_value{get(hObject,'Value')};
setappdata(hMainGui, 'order', order_value);

% --- Executes during object creation, after setting all properties.
function order_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function num_states_text_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
num_value = get(hObject,'String');
setappdata(hMainGui, 'num', num_value);

% --- Executes during object creation, after setting all properties.
function num_states_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sim_length_popup.
function sim_length_popup_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
length_value = cellstr(get(hObject,'String'));
length_value = length_value{get(hObject,'Value')};
setappdata(hMainGui, 'length', length_value);

% --- Executes during object creation, after setting all properties.
function sim_length_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit_push.
function submit_push_Callback(hObject, eventdata, handles)
GUI;

% --- Executes on selection change in orig_len_popup.
function orig_len_popup_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
orig_length_value = cellstr(get(hObject,'String'));
orig_length_value = orig_length_value{get(hObject,'Value')};
setappdata(hMainGui, 'orig_length', orig_length_value);

% --- Executes during object creation, after setting all properties.
function orig_len_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in no_radio.
function no_radio_Callback(hObject, eventdata, handles)
if(~get(handles.no_radio,'Value'))
    set(handles.no_radio,'Value',1);
end
set(handles.yes_radio,'Value',0);
set(handles.leap_popup,'Enable','off')

hMainGui = getappdata(0, 'hMainGui');
leap_yes = get(handles.yes_radio,'Value');
setappdata(hMainGui, 'leap_yes', leap_yes);


% --- Executes on button press in yes_radio.
function yes_radio_Callback(hObject, eventdata, handles)
if(~get(handles.yes_radio,'Value'))
    set(handles.yes_radio,'Value',1);
end
set(handles.no_radio,'Value',0);
set(handles.leap_popup,'Enable','on')

hMainGui = getappdata(0, 'hMainGui');
leap_yes = get(hObject,'Value');
setappdata(hMainGui, 'leap_yes', leap_yes);


% --- Executes on selection change in leap_popup.
function leap_popup_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
leap_value = cellstr(get(hObject,'String'));
leap_value = leap_value{get(hObject,'Value')};
setappdata(hMainGui, 'leap_value', leap_value);

% --- Executes during object creation, after setting all properties.
function leap_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');


% --- Executes on button press in yes_sample.
function yes_sample_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end
set(handles.no_sample,'Value',0);

hMainGui = getappdata(0, 'hMainGui');
yes_sample = get(hObject,'Value');
setappdata(hMainGui, 'yes_sample', yes_sample);


% --- Executes on button press in no_sample.
function no_sample_Callback(hObject, eventdata, handles)
if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end
set(handles.yes_sample,'Value',0);

hMainGui = getappdata(0, 'hMainGui');
yes_sample = get(handles.yes_sample,'Value');
setappdata(hMainGui, 'yes_sample', yes_sample);


% --- Executes during object creation, after setting all properties.
function unit_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in unit_popup.
function unit_popup_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0, 'hMainGui');
unit_value = cellstr(get(hObject,'String'));
unit_value = unit_value{get(hObject,'Value')};
setappdata(hMainGui, 'unit_value', unit_value);

