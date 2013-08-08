function varargout = Pre_MCMC(varargin)
% PRE_MCMC MATLAB code for Pre_MCMC.fig
%      PRE_MCMC, by itself, creates a new PRE_MCMC or raises the existing
%      singleton*.
%
%      H = PRE_MCMC returns the handle to a new PRE_MCMC or the handle to
%      the existing singleton*.
%
%      PRE_MCMC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRE_MCMC.M with the given input arguments.
%
%      PRE_MCMC('Property','Value',...) creates a new PRE_MCMC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pre_MCMC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pre_MCMC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pre_MCMC

% Last Modified by GUIDE v2.5 29-Jul-2013 02:58:01

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pre_MCMC (see VARARGIN)

% Choose default command line output for Pre_MCMC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pre_MCMC wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(0, 'hMainGui', gcf);


% --- Outputs from this function are returned to the command line.
function varargout = Pre_MCMC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function browse_text_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to browse_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of browse_text as text
%        str2double(get(hObject,'String')) returns contents of browse_text as a double

hMainGui = getappdata(0, 'hMainGui');
filename = get(hObject,'String');
setappdata(hMainGui, 'filename', filename);
filename = getappdata(hMainGui, 'filename'); %#ok<*NASGU>


% --- Executes during object creation, after setting all properties.
function browse_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to browse_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_push.
function browse_push_Callback(hObject, eventdata, handles)
% hObject    handle to browse_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
filename = uigetfile('*.csv');
set(handles.browse_text,'String',filename);
setappdata(hMainGui, 'filename', filename);
filename = getappdata(hMainGui, 'filename');


function interval_text_Callback(hObject, eventdata, handles)
% hObject    handle to interval_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval_text as text
%        str2double(get(hObject,'String')) returns contents of interval_text as a double

hMainGui = getappdata(0, 'hMainGui');
interval_value = get(hObject,'String');
setappdata(hMainGui, 'interval', interval_value);
interval_value = getappdata(hMainGui, 'interval');


% --- Executes during object creation, after setting all properties.
function interval_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in unit_popup.
function unit_popup_Callback(hObject, eventdata, handles)
% hObject    handle to unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unit_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unit_popup

hMainGui = getappdata(0, 'hMainGui');
unit_value = cellstr(get(hObject,'String'));
unit_value = unit_value{get(hObject,'Value')};
setappdata(hMainGui, 'unit', unit_value);
unit_value = getappdata(hMainGui, 'unit');


% --- Executes during object creation, after setting all properties.
function unit_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in order_popup.
function order_popup_Callback(hObject, eventdata, handles)
% hObject    handle to order_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns order_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from order_popup

hMainGui = getappdata(0, 'hMainGui');
order_value = cellstr(get(hObject,'String'));
order_value = order_value{get(hObject,'Value')};
setappdata(hMainGui, 'order', order_value);
order_value = getappdata(hMainGui, 'order');


% --- Executes during object creation, after setting all properties.
function order_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to order_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_states_text_Callback(hObject, eventdata, handles)
% hObject    handle to num_states_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_states_text as text
%        str2double(get(hObject,'String')) returns contents of num_states_text as a double

hMainGui = getappdata(0, 'hMainGui');
num_value = get(hObject,'String');
setappdata(hMainGui, 'num', num_value);
num_value = getappdata(hMainGui, 'num');


% --- Executes during object creation, after setting all properties.
function num_states_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_states_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sim_length_popup.
function sim_length_popup_Callback(hObject, eventdata, handles)
% hObject    handle to sim_length_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sim_length_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sim_length_popup

hMainGui = getappdata(0, 'hMainGui');
length_value = cellstr(get(hObject,'String'));
length_value = length_value{get(hObject,'Value')};
setappdata(hMainGui, 'length', length_value);
length_value = getappdata(hMainGui, 'length');


% --- Executes during object creation, after setting all properties.
function sim_length_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sim_length_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in orig_len_popup.
function orig_len_popup_Callback(hObject, eventdata, handles)
% hObject    handle to orig_len_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns orig_len_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from orig_len_popup

hMainGui = getappdata(0, 'hMainGui');
orig_length_value = cellstr(get(hObject,'String'));
orig_length_value = orig_length_value{get(hObject,'Value')};
setappdata(hMainGui, 'orig_length', orig_length_value);
orig_length_value = getappdata(hMainGui, 'orig_length');


% --- Executes during object creation, after setting all properties.
function orig_len_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orig_len_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in no_radio.
function no_radio_Callback(hObject, eventdata, handles)
% hObject    handle to no_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_radio
if(~get(handles.no_radio,'Value'))
    set(handles.no_radio,'Value',1);
end
set(handles.yes_radio,'Value',0);
set(handles.leap_popup,'Enable','off')

hMainGui = getappdata(0, 'hMainGui');
leap_no = get(hObject,'Value');
setappdata(hMainGui, 'leap_no', leap_no);
leap_no = getappdata(hMainGui, 'leap_no'); %#ok<*NASGU>

leap_yes = get(handles.yes_radio,'Value');
setappdata(hMainGui, 'leap_yes', leap_yes);
leap_yes = getappdata(hMainGui, 'leap_yes'); %#ok<*NASGU>


% --- Executes on button press in yes_radio.
function yes_radio_Callback(hObject, eventdata, handles)
% hObject    handle to yes_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yes_radio
if(~get(handles.yes_radio,'Value'))
    set(handles.yes_radio,'Value',1);
end
set(handles.no_radio,'Value',0);
set(handles.leap_popup,'Enable','on')

hMainGui = getappdata(0, 'hMainGui');
leap_yes = get(hObject,'Value');
setappdata(hMainGui, 'leap_yes', leap_yes);
leap_yes = getappdata(hMainGui, 'leap_yes'); %#ok<*NASGU>

leap_no = get(handles.no_radio,'Value');
setappdata(hMainGui, 'leap_no', leap_no);
leap_no = getappdata(hMainGui, 'leap_no'); %#ok<*NASGU>


% --- Executes on selection change in leap_popup.
function leap_popup_Callback(hObject, eventdata, handles)
% hObject    handle to leap_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns leap_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from leap_popup

hMainGui = getappdata(0, 'hMainGui');
leap_value = cellstr(get(hObject,'String'));
leap_value = leap_value{get(hObject, 'Value')};
setappdata(hMainGui, 'leap_value', leap_value);
leap_value = getappdata(hMainGui, 'leap_value');


% --- Executes during object creation, after setting all properties.
function leap_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leap_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'Enable','off');


% --- Executes on button press in yes_sample.
function yes_sample_Callback(hObject, eventdata, handles)
% hObject    handle to yes_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yes_sample

if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end

set(handles.seasons_check,'Enable','on');
set(handles.morn_check,'Enable','on');
set(handles.no_sample,'Value',0);

hMainGui = getappdata(0, 'hMainGui');
no_sample = get(handles.no_sample,'Value');
setappdata(hMainGui, 'no_sample', no_sample);
no_sample = getappdata(hMainGui, 'no_sample'); %#ok<*NASGU>


% --- Executes on button press in seasons_check.
function seasons_check_Callback(hObject, eventdata, handles)
% hObject    handle to seasons_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of seasons_check

hMainGui = getappdata(0, 'hMainGui');
seasons_check = get(hObject, 'Value');
setappdata(hMainGui, 'seasons_check', seasons_check);
seasons_check = getappdata(hMainGui, 'seasons_check');


% --- Executes during object creation, after setting all properties.
function seasons_check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leap_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Enable','off');


% --- Executes on button press in morn_check.
function morn_check_Callback(hObject, eventdata, handles)
% hObject    handle to morn_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of morn_check

hMainGui = getappdata(0, 'hMainGui');
morn_check = get(hObject,'Value');
setappdata(hMainGui, 'morn_check', morn_check);
morn_check = getappdata(hMainGui, 'morn_check'); %#ok<*NASGU>


% --- Executes during object creation, after setting all properties.
function morn_check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to morn_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Enable','off');


% --- Executes on button press in no_sample.
function no_sample_Callback(hObject, eventdata, handles)
% hObject    handle to no_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_sample

if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end
set(handles.yes_sample,'Value',0);

set(handles.seasons_check,'Enable','off');
set(handles.morn_check,'Enable','off');

hMainGui = getappdata(0, 'hMainGui');
no_sample = get(hObject,'Value');
setappdata(hMainGui, 'no_sample', no_sample);
no_sample = getappdata(hMainGui, 'no_sample'); %#ok<*NASGU>

set(handles.seasons_check,'Value',0);
seasons_check = get(handles.seasons_check, 'Value');
setappdata(hMainGui, 'seasons_check', seasons_check);
seasons_check = getappdata(hMainGui, 'seasons_check');

set(handles.morn_check,'Value',0);
morn_check = get(handles.morn_check,'Value');
setappdata(hMainGui, 'morn_check', morn_check);
morn_check = getappdata(hMainGui, 'morn_check'); %#ok<*NASGU>


% --- Executes on button press in rolling_no_radio.
function rolling_no_radio_Callback(hObject, eventdata, handles)
% hObject    handle to rolling_no_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rolling_no_radio

if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end
set(handles.rolling_yes_radio,'Value',0);


% --- Executes on button press in rolling_yes_radio.
function rolling_yes_radio_Callback(hObject, eventdata, handles)
% hObject    handle to rolling_yes_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rolling_yes_radio

if(~get(hObject,'Value'))
    set(hObject,'Value',1);
end
set(handles.rolling_no_radio,'Value',0);



% --- Executes on selection change in type_popup.
function type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type_popup


% --- Executes during object creation, after setting all properties.
function type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function type_unit_text_Callback(hObject, eventdata, handles)
% hObject    handle to type_unit_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of type_unit_text as text
%        str2double(get(hObject,'String')) returns contents of type_unit_text as a double


% --- Executes during object creation, after setting all properties.
function type_unit_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type_unit_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit_push.
function submit_push_Callback(hObject, eventdata, handles)
% hObject    handle to submit_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(findobj('type','figure','name','GUI'));
GUI;
