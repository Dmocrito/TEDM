function varargout = TEDM(varargin)
% TEDM MATLAB code for TEDM.fig
%      TEDM, by itself, creates a new TEDM or raises the existing
%      singleton*.
%
%      H = TEDM returns the handle to a new TEDM or the handle to
%      the existing singleton*.
%
%      TEDM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEDM.M with the given input arguments.
%
%      TEDM('Property','Value',...) creates a new TEDM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TEDM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TEDM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TEDM

% Last Modified by GUIDE v2.5 31-Jul-2019 20:23:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TEDM_OpeningFcn, ...
                   'gui_OutputFcn',  @TEDM_OutputFcn, ...
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


% --- Executes just before TEDM is made visible.
function TEDM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TEDM (see VARARGIN)

% Wellcome call
tedm_Info;

% Choose default command line output for TEDM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TEDM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TEDM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Info.
function Info_Callback(hObject, eventdata, handles)
% hObject    handle to Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tt = '--- Information ---';
msg = {'‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾';...
       '   TEDM - Toolbox for Enhanced Design Matrix';...
       '___________________________________________________';...
       ['   ',tedm_Info('Ver'),' - ', tedm_Info('email')];
       '‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'};
msgbox(msg,tt);



% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Any resistence is futile!
	close all force
%---------------------------



% --- Executes on button press in SetExp.
function SetExp_Callback(hObject, eventdata, handles)
% hObject    handle to SetExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call the funtcion for setting the experiment
tedm_FileExplorer('SetParam');


% --- Executes on button press in IADL.
function IADL_Callback(hObject, eventdata, handles)
% hObject    handle to IADL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tedm_FileExplorer('RunIADL');


% --- Executes on button press in Selection.
function Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tedm_FileExplorer('SelectRegressor')
