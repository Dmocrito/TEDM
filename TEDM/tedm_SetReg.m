function varargout = tedm_SetReg(varargin)
% TEDM_SETREG MATLAB code for tedm_SetReg.fig
%      TEDM_SETREG, by itself, creates a new TEDM_SETREG or raises the existing
%      singleton*.
%
%      H = TEDM_SETREG returns the handle to a new TEDM_SETREG or the handle to
%      the existing singleton*.
%
%      TEDM_SETREG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEDM_SETREG.M with the given input arguments.
%
%      TEDM_SETREG('Property','Value',...) creates a new TEDM_SETREG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tedm_SetReg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tedm_SetReg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tedm_SetReg

% Last Modified by GUIDE v2.5 28-Nov-2020 19:26:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tedm_SetReg_OpeningFcn, ...
                   'gui_OutputFcn',  @tedm_SetReg_OutputFcn, ...
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


% --- Executes just before tedm_SetReg is made visible.
function tedm_SetReg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tedm_SetReg (see VARARGIN)

% Choose default command line output for tedm_SetReg
handles.output = hObject;

%=== DEFAULT SETTINGS ==============================================

%--- Set SPM file from the input---
handles.SPM = varargin{1};

% Identify number of sessions
Sess = length(handles.SPM.nscan);

%--- Session Menu Update ---
handles.SS = 1; % Session 1 as default

UpdateSessionMenu(hObject, eventdata, handles);

%-- Remove navigation buttons for a single session ---
if(Sess==1)
  set(handles.ButPrevSess,'Visible','off');
  set(handles.ButNextSess,'Visible','off');
end

%----- Update Regressor's Figure -----
handles.ShowReg = 1;

UpdateRegressorMenu(hObject, eventdata, handles);

%=== Set default prefix ===
outfile = handles.SPM.TEDM.hist.outfile;
set(handles.OupPrefix,'String',['Rg_' outfile '.mat']);

% Update handles structure
guidata(hObject, handles);

%===================================================================

% UIWAIT makes tedm_SetReg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tedm_SetReg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ButCheck.
function ButCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ButCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ButSave.
function ButSave_Callback(hObject, eventdata, handles)
% hObject    handle to ButSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%=== Update Regressors ====
% Parameters
Sess = length(handles.SPM.nscan);

for ss = 1:Sess
  % Store old parameters
  o_xD = handles.SPM.TEDM.Res(ss).xD;
  o_names = handles.SPM.TEDM.Param(ss).names;


  % Selected regressors 
  Regs = handles.SPM.TEDM.Param(ss).SetReg;

  %--- Update the the corresponding regressors ---
  cnt = 1;
  for k=1:length(Regs)
    if(Regs{k})
      AuxD(:,cnt)   = o_xD(:,k);
      AuxNames{cnt} = o_names{k};

      cnt = cnt+1;
    end
  end

  % Store the new selected regressors
  handles.SPM.TEDM.Res(ss).xD = AuxD;
  handles.SPM.TEDM.Param(ss).names = AuxNames;

end

%=== Update SPM file ===
tedm_Update_fMRI_design(handles.SPM);

msgbox('Regressors updated correctly.','Operation Completed','help');



function OupPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to OupPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OupPrefix as text
%        str2double(get(hObject,'String')) returns contents of OupPrefix as a double

% Update outPrefix
prefix = get(hObject,'String');

handles.SPM.TEDM.hist.outfile = prefix;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function OupPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OupPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButNext.
function ButNext_Callback(hObject, eventdata, handles)
% hObject    handle to ButNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
ss   = handles.SS; % Current studied session
sReg = handles.ShowReg;
[~,nK] = size(handles.SPM.TEDM.Res(ss).xD);

% Move component
sReg = sReg + 1;

if(sReg>nK)
  sReg = 1;
end

handles.ShowReg = sReg;

% Update menu
UpdateRegressorMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButPrev.
function ButPrev_Callback(hObject, eventdata, handles)
% hObject    handle to ButPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
ss   = handles.SS; % Current studied session
sReg = handles.ShowReg;
[~,nK] = size(handles.SPM.TEDM.Res(ss).xD);

% Move component
sReg = sReg - 1;

if(sReg<1)
  sReg = nK;
end

handles.ShowReg = sReg;

% Update menu
UpdateRegressorMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


% Update Regressor's menu Function
function UpdateRegressorMenu(hObject, eventdata, handles)
% This function update the Session Menu with all the 
% required parameters

%--- Current Session ---
ss = handles.SS; % Current studied session

%--- Set default components ---
enhD    = handles.SPM.TEDM.Res(ss).xD;
[tp,nK] = size(enhD);
sReg    = handles.ShowReg;


% Reference Dictionary
Del = handles.SPM.TEDM.Param(ss).Del;

%--- Update Regressor's Figure ----

% Name of the regressr
set(handles.SetReg,'String',handles.SPM.TEDM.Param(ss).names{sReg});

% Draw figure
axes(handles.axesTime);

% Normalyze regresor
tReg = enhD(:,sReg);
tReg = tReg/max(abs(tReg(:)));

% Plot stuff
axT = plot(tReg,'LineWidth',1.5);
axis ([0 tp -inf inf]);
yticks ([-1 0 1]);
grid on;

%--- Update Regresors pointer ---
Dat    = get(handles.RegTable,'Dat');
Tpoint = repmat({'-'},1,nK);
Tpoint{sReg} = '>';

Dat(:,1) = Tpoint;

set(handles.RegTable,'Data',Dat);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButNextSess.
function ButNextSess_Callback(hObject, eventdata, handles)
% hObject    handle to ButNextSess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess = length(handles.SPM.nscan);
ss   = handles.SS; % Current studied session

% Move session
ss = ss + 1;

if(ss > Sess)
  ss = 1;
end

handles.SS = ss;


% Set regresors to the first one
handles.ShowReg = 1;

% Update menus
UpdateSessionMenu(hObject, eventdata, handles);
UpdateRegressorMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButPrevSess.
function ButPrevSess_Callback(hObject, eventdata, handles)
% hObject    handle to ButPrevSess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess = length(handles.SPM.nscan);
ss   = handles.SS; % Current studied session

% Move session
ss = ss - 1;

if(ss <= 0)
  ss = Sess;
end

handles.SS = ss;


% Set regresors to the first one
handles.ShowReg = 1;

% Update menus
UpdateSessionMenu(hObject, eventdata, handles);
UpdateRegressorMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in RegTable.
function RegTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to RegTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
% Indices: row and column indices of the cell(s) edited
% PreviousData: previous data for the cell(s) edited
% EditData: string(s) entered by the user
% NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
% Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

currentCell = eventdata.Indices;

% Check for a selected cell
if(~isempty(currentCell))

  ss   = handles.SS;
  TabData = get(handles.RegTable,'Data');

  handles.SPM.TEDM.Param(ss).SetReg = TabData(:,4)';

  % Update handles structure
  guidata(hObject, handles);

end



%===== Extra Functions ======================================

% Update Session Function
function UpdateSessionMenu(hObject, eventdata, handles)
% This function update the Session Menu with all the 
% required parameters

% Parameters
ss = handles.SS; % Current studied session

% Set Session name
set(handles.SessionText,'String',['Session ' num2str(ss,'%02i')]);

% Number of sources
enhD = handles.SPM.TEDM.Res(ss).xD;
[tp,nK] = size(enhD);
SrcA = handles.SPM.TEDM.Param(ss).NSrc_A;

% Fill the table
for k= 1:nK
  Tpoint{k} = '-';
  Tnames{k} = handles.SPM.TEDM.Param(ss).names{k};
  Tcheck{k} = handles.SPM.TEDM.Param(ss).SetReg{k};
  Tpart {k} = ['S' num2str(ss,'%02i')];

end

% Table Info.
columnname     = {'', 'Regressor', 'Sess.', 'Set'};
columnformat   = {'char', 'char', 'char', 'logical'};
columneditable = [false, false, false, true];
columnwidth    = {15,150,50,40};

%--- Update Table ---
set(handles.RegTable,'ColumnEditable',columneditable);
set(handles.RegTable,'ColumnName',columnname);
set(handles.RegTable,'ColumnFormat',columnformat);
set(handles.RegTable,'ColumnWidth',columnwidth);
set(handles.RegTable,'Data',[Tpoint' Tnames' Tpart' Tcheck']);

% Update handles structure
guidata(hObject, handles);
