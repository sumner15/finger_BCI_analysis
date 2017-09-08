function varargout = datatrendsGUI2(varargin)
% DATATRENDSGUI2 MATLAB code for datatrendsGUI2.fig
%      DATATRENDSGUI2, by itself, creates a new DATATRENDSGUI2 or raises the existing
%      singleton*.
%
%      H = DATATRENDSGUI2 returns the handle to a new DATATRENDSGUI2 or the handle to
%      the existing singleton*.
%
%      DATATRENDSGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATATRENDSGUI2.M with the given input arguments.
%
%      DATATRENDSGUI2('Property','Value',...) creates a new DATATRENDSGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datatrendsGUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datatrendsGUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datatrendsGUI2

% Last Modified by GUIDE v2.5 29-May-2017 18:48:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datatrendsGUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @datatrendsGUI2_OutputFcn, ...
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


% --- Executes just before datatrendsGUI2 is made visible.
function datatrendsGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datatrendsGUI2 (see VARARGIN)


T = varargin{1};
handles.T = T;
VNames = T.Properties.VariableNames;

set(handles.listbox1,'String',VNames)
set(handles.listbox2,'String',VNames)
set(handles.listbox1,'Value',7)
set(handles.listbox2,'Value',8)

plotdata(handles)


% Choose default command line output for datatrendsGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes datatrendsGUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = datatrendsGUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

plotdata(handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% xt = ['apple ';'banana';'orange';'grape ';'plum  ';'pear  '];
% handles.listbox1

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

plotdata(handles)

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotdata(handles)
    T = handles.T;
    VNames = T.Properties.VariableNames;
    VDesc = T.Properties.VariableDescriptions;
    v1 = get(handles.listbox1,'Value');
    v2 = get(handles.listbox2,'Value');

    axes(handles.axes1)
    cla; hold on; grid on

    goodSubs = {'CHEA','RAZT','TRUL','VANT'};
    noControl = {'MCCL','MAUA'};
    emgControl = {'HATA','PHIC'};
    
    xGood = T{goodSubs,VNames(v1)};
    yGood = T{goodSubs,VNames(v2)};
    xNoControl = T{noControl,VNames(v1)};
    yNoControl = T{noControl,VNames(v2)};
    xEmgControl = T{emgControl,VNames(v1)};
    yEmgControl = T{emgControl,VNames(v2)};

    lm = fitlm(xGood,yGood,'linear');
    plot([min(xGood) max(xGood)],...
        [lm.Coefficients{2,1}*(min(xGood))+lm.Coefficients{1,1} ...
         lm.Coefficients{2,1}*(max(xGood))+lm.Coefficients{1,1}],...
         'color',[0 0.447 0.741],'Linewidth',2)
    hold on
    
    plot(xGood,yGood,'ok')    
    plot(xNoControl,yNoControl,'or')        
    plot(xEmgControl,yEmgControl,'ob')

    set(handles.text1,'String',['          p = ' num2str(lm.Coefficients.pValue(2),3)])
    set(handles.text2,'String',['      R^2 = ' num2str(lm.Rsquared.Ordinary,3)])
    set(handles.text3,'String',['R^2 Adj = ' num2str(lm.Rsquared.Adjusted,3)])
    xlabel(VDesc(v1))
    ylabel(VDesc(v2))
