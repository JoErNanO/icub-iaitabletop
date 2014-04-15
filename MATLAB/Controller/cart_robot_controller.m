function varargout = cart_robot_controller(varargin)
% CART_ROBOT_CONTROLLER M-file for cart_robot_controller.fig
%      CART_ROBOT_CONTROLLER, by itself, creates a new CART_ROBOT_CONTROLLER or raises the existing
%      singleton*.
%
%      H = CART_ROBOT_CONTROLLER returns the handle to a new CART_ROBOT_CONTROLLER or the handle to
%      the existing singleton*.
%
%      CART_ROBOT_CONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CART_ROBOT_CONTROLLER.M with the given input arguments.
%
%      CART_ROBOT_CONTROLLER('Property','Value',...) creates a new CART_ROBOT_CONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cart_robot_controller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cart_robot_controller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cart_robot_controller

% Last Modified by GUIDE v2.5 19-Oct-2009 14:07:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cart_robot_controller_OpeningFcn, ...
                   'gui_OutputFcn',  @cart_robot_controller_OutputFcn, ...
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


% --- Executes just before cart_robot_controller is made visible.
function cart_robot_controller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cart_robot_controller (see VARARGIN)

% Ensure model is open.
%%%model_open(handles)

% Open serial port
global s % because we need it in timer, and otherwise I don't know how to give parameter
%s = serial('COM5'); %this causes problems if somebody else is already using th port, so instead we use:
% s = instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', ''); %Find a serial port object.
s = instrfind('Type', 'serial', 'Port', '/dev/ttyUSB0', 'Tag', ''); %Find a serial port object.
if isempty(s) % Create the serial port object if it does not exist
%     s = serial('COM5');
    s = serial('/dev/ttyUSB0');
else % otherwise use the object that was found.
    fclose(s);
    s = s(1);
end
fopen(s)
set(s,'BaudRate',115200,'DataBits',8,'StopBits',1,'Parity','none')
handles.s=s;
%%fprintf(s,'*IDN?')
%%idn = fscanf(s);

% create timer, it waits 0.001 seconds after the previous execution has
% finished, so I hope that it basically runs all the time
%%%t = timer('TimerFcn',@timercallback, 'Period', 0.001, 'executionMode', 'fixedSpacing');
%%%stop(t)
%%%handles.t=t;

% Choose default command line output for cart_robot_controller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cart_robot_controller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cart_robot_controller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function x_slider_Callback(hObject, eventdata, handles)
% hObject    handle to x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get the new value from the slider.
NewVal = num2str(get(hObject, 'Value')); 
% Set the value of the textbox
set(handles.x_edit,'String',NewVal)

if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
    moveX(handles)
end


% --- Executes during object creation, after setting all properties.
function x_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function y_slider_Callback(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get the new value from the slider.
NewVal = num2str(get(hObject, 'Value')); 
% Set the value of the textbox
set(handles.y_edit,'String',NewVal)

if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
    moveY(handles)
end



% --- Executes during object creation, after setting all properties.
function y_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get the new value from the slider.
NewVal = num2str(get(hObject, 'Value')); 
% Set the value of the textbox
set(handles.z_edit,'String',NewVal)

if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
    moveZ(handles)
end


% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_edit as text
%        str2double(get(hObject,'String')) returns contents of x_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 && ...
   val >= get(handles.x_slider,'Min') && ...
   val <= get(handles.x_slider,'Max')
   set(handles.x_slider,'Value',val);
   
   if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
       moveX(handles)
   end
   
else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_edit as text
%        str2double(get(hObject,'String')) returns contents of y_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 && ...
   val >= get(handles.y_slider,'Min') && ...
   val <= get(handles.y_slider,'Max')
   set(handles.y_slider,'Value',val);
   
   if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
        moveY(handles)
   end

else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_edit as text
%        str2double(get(hObject,'String')) returns contents of z_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 && ...
   val >= get(handles.z_slider,'Min') && ...
   val <= get(handles.z_slider,'Max')
   set(handles.z_slider,'Value',val);
   
   if get(handles.move_always_checkbox, 'Value') == get(handles.move_always_checkbox,'Max')
        moveZ(handles)
   end
   
else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in homing_pushbutton.
function homing_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homing_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.s,['!99232071@@' 13 10])
pause(2) %don't do one right after the other!
fprintf(handles.s,['!9923307000000@@' 13 10]) 


% --- Executes on button press in moveOnce_pushbutton.
function moveOnce_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveOnce_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


moveAll(handles)


% --- Executes on button press in moveTriangle_pushbutton.
function moveTriangle_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveTriangle_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in StartSim_pushbutton.
function StartSim_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StartSim_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stop_pushbutton.
function stop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%if strcmp(handles.s.status, 'closed')
%    fopen(handles.s)
%end


function periode_edit_Callback(hObject, eventdata, handles)
% hObject    handle to periode_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of periode_edit as text
%        str2double(get(hObject,'String')) returns contents of periode_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 
   
else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function periode_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periode_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amplitude_edit_Callback(hObject, eventdata, handles)
% hObject    handle to amplitude_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amplitude_edit as text
%        str2double(get(hObject,'String')) returns contents of amplitude_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 
   
else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function amplitude_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function speed_edit_Callback(hObject, eventdata, handles)
% hObject    handle to speed_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_edit as text
%        str2double(get(hObject,'String')) returns contents of speed_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 && ...
   val >= 0 && ...
   val <= 1000

else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function speed_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function acceleration_edit_Callback(hObject, eventdata, handles)
% hObject    handle to acceleration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acceleration_edit as text
%        str2double(get(hObject,'String')) returns contents of acceleration_edit as a double

val = str2double(get(hObject,'String'));
% Determine whether val is a number between 0 and max.
if isnumeric(val) && length(val)==1 && ...
   val >= 0.01 && ...
   val <= 10

else
   set(hObject,'String','Invalid entry ');
end


% --- Executes during object creation, after setting all properties.
function acceleration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acceleration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fclose(handles.s)

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function moveAll(handles)

if strcmp(handles.s.status, 'closed')
    fopen(handles.s)
end

fprintf(handles.s,['!9923407' ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.speed_edit,'String'))), 4) ...
    dec2hex(round(str2double(get(handles.x_edit,'String'))*1000), 8) ...
    dec2hex(round(str2double(get(handles.y_edit,'String'))*1000), 8) ...
    dec2hex(round(str2double(get(handles.z_edit,'String'))*1000), 8) ...
    64 64 13 10])

function moveX(handles)

if strcmp(handles.s.status, 'closed')
    fopen(handles.s)
end

fprintf(handles.s,['!9923401' ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.speed_edit,'String'))), 4) ...
    dec2hex(round(str2double(get(handles.x_edit,'String'))*1000), 8) ...
    64 64 13 10])

function moveY(handles)

if strcmp(handles.s.status, 'closed')
    fopen(handles.s)
end

fprintf(handles.s,['!9923402' ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.speed_edit,'String'))), 4) ...
    dec2hex(round(str2double(get(handles.y_edit,'String'))*1000), 8) ...
    64 64 13 10])

function moveZ(handles)

if strcmp(handles.s.status, 'closed')
    fopen(handles.s)
end

fprintf(handles.s,['!9923404' ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.acceleration_edit,'String'))*100), 4) ...
    dec2hex(round(str2double(get(handles.speed_edit,'String'))), 4) ...
    dec2hex(round(str2double(get(handles.z_edit,'String'))*1000), 8) ...
    64 64 13 10])


% --- Executes on button press in move_always_checkbox.
function move_always_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to move_always_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of move_always_checkbox

if get(hObject, 'Value') == get(hObject,'Max')
    moveAll(handles)
end
