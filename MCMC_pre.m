function varargout = MCMC_pre(varargin)
% MCMC_PRE MATLAB code for MCMC_pre.fig
%      MCMC_PRE, by itself, creates a new MCMC_PRE or raises the existing
%      singleton*.
%
%      H = MCMC_PRE returns the handle to a new MCMC_PRE or the handle to
%      the existing singleton*.
%
%      MCMC_PRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MCMC_PRE.M with the given input arguments.
%
%      MCMC_PRE('Property','Value',...) creates a new MCMC_PRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MCMC_pre_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MCMC_pre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MCMC_pre

% Last Modified by GUIDE v2.5 27-Jun-2013 16:42:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MCMC_pre_OpeningFcn, ...
                   'gui_OutputFcn',  @MCMC_pre_OutputFcn, ...
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


% --- Executes just before MCMC_pre is made visible.
function MCMC_pre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MCMC_pre (see VARARGIN)

% Choose default command line output for MCMC_pre
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MCMC_pre wait for user response (see UIRESUME)
% uiwait(handles.MCMC_pre);

setappdata(0, 'hMainGui', gcf);
setappdata(gcf, 'fhUpdateData', @updateData);


% --- Outputs from this function are returned to the command line.
function varargout = MCMC_pre_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
%updateData;

% function updateData
% hMainGui = getappdata(0, 'hMainGui');
% filename = getappdata(hMainGui, 'filename')
% order_value = getappdata(hMainGui, 'order')
% width_value = getappdata(hMainGui, 'width')
% length_value = getappdata(hMainGui, 'length')


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
%updateData;


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



function num_text_Callback(hObject, eventdata, handles)
% hObject    handle to num_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_text as text
%        str2double(get(hObject,'String')) returns contents of num_text as a double

hMainGui = getappdata(0, 'hMainGui');
num_value = get(hObject,'String');
setappdata(hMainGui, 'num', num_value);
num_value = getappdata(hMainGui, 'num');
%updateData;

% --- Executes during object creation, after setting all properties.
function num_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function length_text_Callback(hObject, eventdata, handles)
% hObject    handle to length_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length_text as text
%        str2double(get(hObject,'String')) returns contents of length_text as a double

hMainGui = getappdata(0, 'hMainGui');
length_value = get(hObject,'String');
setappdata(hMainGui, 'length', length_value);
length_value = getappdata(hMainGui, 'length');
%updateData;

% --- Executes during object creation, after setting all properties.
function length_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function browse_text_Callback(hObject, eventdata, handles)
% hObject    handle to browse_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of browse_text as text
%        str2double(get(hObject,'String')) returns contents of browse_text as a double

hMainGui = getappdata(0, 'hMainGui');
filename = get(hObject,'String');
setappdata(hMainGui, 'filename', filename);
filename = getappdata(hMainGui, 'filename');
%updateData;

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


% --- Executes on button press in submit_push.
function submit_push_Callback(hObject, eventdata, handles)
% hObject    handle to submit_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of submit_push

GUI;


% --- Executes on selection change in length_popup.
function length_popup_Callback(hObject, eventdata, handles)
% hObject    handle to length_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns length_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from length_popup

hMainGui = getappdata(0, 'hMainGui');
length_value = cellstr(get(hObject,'String'));
length_value = length_value{get(hObject,'Value')};
setappdata(hMainGui, 'length', length_value);
length_value = getappdata(hMainGui, 'length');


% --- Executes during object creation, after setting all properties.
function length_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
