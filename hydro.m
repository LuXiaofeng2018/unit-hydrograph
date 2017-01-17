function varargout = hydro(varargin)
% HYDRO MATLAB code for hydro.fig
%      HYDRO, by itself, creates a new HYDRO or raises the existing
%      singleton*.
%
%      H = HYDRO returns the handle to a new HYDRO or the handle to
%      the existing singleton*.
%
%      HYDRO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYDRO.M with the given input arguments.
%
%      HYDRO('Property','Value',...) creates a new HYDRO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hydro_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hydro_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hydro

% Last Modified by GUIDE v2.5 30-Nov-2014 20:14:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @hydro_OpeningFcn, ...
    'gui_OutputFcn',  @hydro_OutputFcn, ...
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


% --- Executes just before hydro is made visible.
function hydro_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hydro (see VARARGIN)

% Choose default command line output for hydro
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hydro wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hydro_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in search.
function search_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.*','Pick FLOW data');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(msgbox('User pressed cancel'))
    return
else
    data = xlsread(filename);
end
time = data(:,1);
tStep = data(2,1);
base_sq = data(1,2)*(data(1,end))*3600; % Base flow square
data = data(:,2)-data(1,2);
base_tri = length(data)*data(end)/2*3600; % Base flow triangle

vol_base = base_sq+base_tri; % Volume of base flow
set(handles.result4,'String',num2str(vol_base))

% Separate the entire base flow
better_data = zeros(length(data),1);
for k = 2:length(data)
    better_data(k,1) = data(k)-(data(end)*time(k)/time(end));
end

data_c = better_data*3600; % converting to flow/hour

area = str2double(get(handles.area_edit,'String'));
vol = integralNum(data_c,tStep);
set(handles.result2,'String',num2str(vol))

UH = uHyd(better_data,area,vol);
cla
handles.graph2 = plot(time,UH,'color','b','linewidth',2,'marker','o');
xlabel('Time (hrs)','fontsize',14)
ylabel('Flow','fontsize',14)
set(gca,'YGrid','on');
set(handles.title,'String','Unit Hydrograph')

[peak, t] = max(UH);
set(handles.result1,'String',num2str(peak*3600))
set(handles.result3,'String',num2str(t*tStep-tStep))
set(handles.search_prec,'Enable','on')
handles.UH = UH;
handles.data = data;
handles.time = time;
handles.tStep = tStep;
guidata(hObject,handles)

function precEdit_Callback(hObject, eventdata, handles)
% hObject    handle to precEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of precEdit as text
%        str2double(get(hObject,'String')) returns contents of precEdit as a double

% --- Executes during object creation, after setting all properties.
function precEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to precEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in search_prec.
function search_prec_Callback(hObject, eventdata, handles)
% hObject    handle to search_prec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.*','Pick PRECIPITATION data');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(msgbox(('User pressed cancel')));
    return
else
    data = xlsread(filename);
end
data(:,1) = data(:,1)-data(1,1);
bar(handles.graph1,data(:,1),data(:,2),0.4);
ylabel(handles.graph1,'Precipitation (cm)','fontsize',14)
set(handles.hydrograph,'Enable','on')
handles.precData = data;
guidata(hObject,handles)

% --- Executes on button press in hydrograph.
function hydrograph_Callback(hObject, eventdata, handles)
% hObject    handle to hydrograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UH = handles.UH;
data = handles.precData;
time = handles.time;
tStep = handles.tStep;
set(handles.title,'String','Unit Response')

cla
[timex, grph, ind] = unResp(UH,data,time);
hold on
figure(10)
plot((0:tStep:(ind*tStep-tStep)),grph,'linewidth',2,'marker','s');
set(gca,'YGrid','on');
xlabel('Time (hrs)','fontsize',14)
ylabel('Flow (cu.m/hr.cm)','fontsize',14)
title('Hydrograph','fontsize',15)
hold off
[peak, t] = max(grph);
set(handles.result1,'String',num2str(peak*3600))
set(handles.result3,'String',num2str(t*handles.tStep-handles.tStep))
vol = integralNum(data*3600,handles.tStep);
set(handles.result2,'String',num2str(vol))
axis(handles.graph1,[0 max(timex) 0 max(handles.precData(:,2))]);

handles.hy = figure(10);
guidata(hObject,handles)

function area_edit_Callback(hObject, eventdata, handles)
% hObject    handle to area_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of area_edit as text
%        str2double(get(hObject,'String')) returns contents of area_edit as a double
if ~isempty(get(hObject,'String'))
    set(handles.search,'Enable','on')
else
    set(handles.search,'Enable','off')
end

% --- Executes during object creation, after setting all properties.
function area_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to area_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UH.
function UH_Callback(hObject, eventdata, handles)
% hObject    handle to UH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time = handles.time;
UH = handles.UH;
mult = str2double(get(handles.precEdit,'String'));
newUH = mult*UH;
hold on
plot(time,newUH,'color','r','linewidth',2,'marker','s')
set(gca,'YGrid','on');
hold off
[peak] = max(newUH);
set(handles.result1,'String',num2str(peak*3600))

% --- Executes on button press in search.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function prec_edit_Callback(hObject, eventdata, handles)
% hObject    handle to precEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of precEdit as text
%        str2double(get(hObject,'String')) returns contents of precEdit as a double


% --- Executes during object creation, after setting all properties.
function prec_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to precEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveas(handles.hy,'hydrograph','bmp')
