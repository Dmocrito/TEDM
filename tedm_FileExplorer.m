function varargout = tedm_FileExplorer(varargin)
% TEDM_FILEEXPLORER MATLAB code for tedm_FileExplorer.fig
%      TEDM_FILEEXPLORER, by itself, creates a new TEDM_FILEEXPLORER or raises the existing
%      singleton*.
%
%      H = TEDM_FILEEXPLORER returns the handle to a new TEDM_FILEEXPLORER or the handle to
%      the existing singleton*.
%
%      TEDM_FILEEXPLORER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEDM_FILEEXPLORER.M with the given input arguments.
%
%      TEDM_FILEEXPLORER('Property','Value',...) creates a new TEDM_FILEEXPLORER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tedm_FileExplorer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tedm_FileExplorer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tedm_FileExplorer

% Last Modified by GUIDE v2.5 01-Aug-2019 10:53:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tedm_FileExplorer_OpeningFcn, ...
                   'gui_OutputFcn',  @tedm_FileExplorer_OutputFcn, ...
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


% --- Executes just before tedm_FileExplorer is made visible.
function tedm_FileExplorer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tedm_FileExplorer (see VARARGIN)

% Choose default command line output for tedm_FileExplorer
handles.output = hObject;

handles.Init.SPMfile = false;

Case = varargin{1};
handles.Case = Case;

switch handles.Case
  case 'SetParam'
    % Menu initialization
    set(handles.MainPanel,'Title','Select SPM reference file');

  case 'RunIADL'
    % Menu parameters
    set(handles.MainPanel,'Title','Initialized TEDM file');

case 'SelectRegressor'
	% Menu parameters
    set(handles.MainPanel,'Title','Select file with the Enhanced Design matrix');

  otherwise
    error('Ups... It seems that something went wrong \(u u)');
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tedm_FileExplorer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tedm_FileExplorer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in But_Clear.
function But_Clear_Callback(hObject, eventdata, handles)
% hObject    handle to But_Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--- Reset the main dialogue ---

% Init parameters
handles.Init.SPMfile = false;

% SPM file path
set(handles.SPM_File,'Style','pushbutton');
set(handles.SPM_File,'String','Select');
set(handles.SPM_File,'Enable','on');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in But_Next.
function But_Next_Callback(hObject, eventdata, handles)
% hObject    handle to But_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.Init.SPMfile)
	file   = handles.SPM_path;

	% Load File
	name = [file{2} file{1}];
	load(name);

	switch handles.Case
  		case 'SetParam'
        % Close window
        close;

    		% Generate New SPM file
   			SPM = DefaultTEDM(SPM);

    		% Save parameter Info
    		SPM.TEDM.hist.file   = file;

    		SetExp_Par(SPM);

  		case 'RunIADL'
        % Check if the file was Initialized
        touch = false;
        if(isfield(SPM,'TEDM'));
          if(isfield(SPM.TEDM,'Touch'));
            if(SPM.TEDM.Touch == 1);
              touch = true;
            end
          end
        end

        if(touch)
          % Close window
          close;

          % Call Visual Interface
    		  tedm_RunIADL(SPM);

        else
          Line1 = 'It seems that this file was not initialized (o-o?)';
          Line2 = 'Plese, set the experimet before enhancing the design matrix.';
          warndlg({Line1,Line2},'Missing Initialization');

        end

    	case 'SelectRegressor'
    		% Call guy for Select Regressors
    		tedm_SelectRegressor(SPM);

  		otherwise
    		error('Ups... It seems that something went wrong. \(u u)');

  	end
else
	warndlg('No file was selected  -_(o_o )_-   ','Warning');
    
  set(handles.SPM_File,'String','Select');

end
	


function SPM_File_Callback(hObject, eventdata, handles)
% hObject    handle to SPM_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open dialogue to select file 
[file,path] = uigetfile('*.mat','Select a SPM file','SPM.mat');

if(file==0)
    warndlg('No SPM file was selected  -_(o_o )_-   ','Warning');
    
    cad = get(hObject,'String');
    set(handles.SPM_File,'String',[cad '!']);
    
else
    set(handles.SPM_File,'Style','edit');
    set(handles.SPM_File,'Enable','off');
    set(handles.SPM_File,'String',path);

    handles.Init.SPMfile = true;
end

handles.SPM_path{1} = file;
handles.SPM_path{2} = path;

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SPM_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPM_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%=== Set Defaults Settings =====================================================

function SPM = DefaultTEDM(SPM)

% Check the number of sessions
Sess = length(SPM.nscan);

if(Sess==1) %======== Single-Session Experiment ========

  K_A = length(SPM.xX.iC); 
  Sp_A = 85*ones(1,K_A);

  % Check for constrant component
  if(~isempty(SPM.xX.iB))

    SPM.TEDM.Param.iB = SPM.xX.iB;
    K_A  = K_A + 1;
    Sp_A = [Sp_A 0];

  else
  
    SPM.TEDM.Param.iB = 0;

  end

  % Update parameters
  SPM.TEDM.Touch = false;

  SPM.TEDM.hist.prefix  = 'Setup_';
  SPM.TEDM.hist.outfile = 'Enh_SPM';

  SPM.TEDM.Param.K      = K_A;
  SPM.TEDM.Param.NSrc_A = K_A;

  SPM.TEDM.Param.Sp_A = Sp_A;
  SPM.TEDM.Param.SpMode = 'Auto';

  SPM.TEDM.Param.Del  = SPM.xX.X;

  SPM.TEDM.Param.SimMode = 'Conservative';
  SPM.TEDM.Param.cdl = [];

  %--- Take names ---
  for i=1:numel(SPM.Sess.U);
    name{i} = char(SPM.Sess.U(i).name);
  end

  % Check constnant atom
  iB = SPM.xX.iB;
  if(~isempty(iB))
    name{iB} = 'constant';
  end

  SPM.TEDM.Param.name = name;

else %======== Multi-session experiment =========

  % Set Sessions
  SPM.TEDM.Sess = Sess;

  % Prefix
  SPM.TEDM.hist.prefix  = 'Setup_';

  % Parameters
  Dur = cumsum([0 SPM.nscan]);

  for ss = 1:Sess

    % Identify Sources
    K_A = length(SPM.Sess(ss).col); 
    Sp_A = 85*ones(1,K_A);

    % Check for constrant component
    if(~isempty(SPM.xX.iB(ss)))
      SPM.TEDM.Param.iB(ss) = SPM.xX.iB(ss);
      K_A  = K_A + 1;
      Sp_A = [Sp_A 0];

    else
  
      SPM.TEDM.Param.iB(ss) = 0;

    end

    % Update parameters
    SPM.TEDM.Touch(ss) = false;

    SPM.TEDM.Param(ss).K      = K_A;
    SPM.TEDM.Param(ss).NSrc_A = K_A;

    SPM.TEDM.Param(ss).Sp_A   = Sp_A;
    SPM.TEDM.Param(ss).SpMode = 'Auto';

    SPM.TEDM.Param(ss).SimMode = 'Conservative';
    SPM.TEDM.Param(ss).cld     = [];

    % Select task-related time courses
    Cols = [SPM.Sess(ss).col, SPM.xX.iB(ss)];
    Tdur = [1+Dur(ss):Dur(ss+1)];

    Del = SPM.xX.X(Tdur,Cols);

    SPM.TEDM.Param(ss).Del = Del;

    % Take names
    for i=1:numel(SPM.Sess(ss).U);
      name{i} = char(SPM.Sess(ss).U(i).name);
    end

    % Check constant atoms
    iB = SPM.xX.iB(ss);
    if(~isempty(iB))
    name{K_A(end)} = 'constant';
    end

    SPM.TEDM.Param(ss).name = name;
  end

end