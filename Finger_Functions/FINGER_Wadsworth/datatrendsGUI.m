function varargout = datatrendsGUI(varargin)
% DATATRENDSGUI MATLAB code for datatrendsGUI.fig
%      DATATRENDSGUI, by itself, creates a new DATATRENDSGUI or raises the existing
%      singleton*.
%
%      H = DATATRENDSGUI returns the handle to a new DATATRENDSGUI or the handle to
%      the existing singleton*.
%
%      DATATRENDSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATATRENDSGUI.M with the given input arguments.
%
%      DATATRENDSGUI('Property','Value',...) creates a new DATATRENDSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datatrendsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datatrendsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datatrendsGUI

% Last Modified by GUIDE v2.5 14-Oct-2016 11:11:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datatrendsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @datatrendsGUI_OutputFcn, ...
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


% --- Executes just before datatrendsGUI is made visible.
function datatrendsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datatrendsGUI (see VARARGIN)


T = varargin{1};
handles.T = T;
VNames = T.Properties.VariableNames;

set(handles.listbox1,'String',VNames)
set(handles.listbox2,'String',VNames)
set(handles.listbox1,'Value',2)
set(handles.listbox2,'Value',14)

plotdata(handles)


% Choose default command line output for datatrendsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes datatrendsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = datatrendsGUI_OutputFcn(hObject, eventdata, handles) 
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
x = T{:,VNames(v1)};
y = T{:,VNames(v2)};
axes(handles.axes1)
cla; hold on; grid on
plot(x,y,'bo','LineWidth',2,'MarkerSize',6); 
lm = fitlm(x,y,'linear')
plot([min(x) max(x)],[lm.Coefficients{2,1}*(min(x))+lm.Coefficients{1,1} lm.Coefficients{2,1}*(max(x))+lm.Coefficients{1,1}],'r-','Linewidth',2,'LineWidth',2)
%         if lm.Coefficients.pValue(2)<=0.05
%             xlabel(['Trend (R^2=',num2str(lm.Rsquared.Ordinary,3),', p = ',num2str(lm.Coefficients.pValue(2),3),')'],'BackgroundColor','y')
%         else
%             xlabel(['Trend (R^2=',num2str(lm.Rsquared.Ordinary,3),', p = ',num2str(lm.Coefficients.pValue(2),3),')'])
%         end
set(handles.text1,'String',['          p = ' num2str(lm.Coefficients.pValue(2),3)])
set(handles.text2,'String',['      R^2 = ' num2str(lm.Rsquared.Ordinary,3)])
set(handles.text3,'String',['R^2 Adj = ' num2str(lm.Rsquared.Adjusted,3)])
xlabel(VDesc(v1))
ylabel(VDesc(v2))
