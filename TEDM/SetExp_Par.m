function varargout = SetExp_Par(varargin)
% SETEXP_PAR MATLAB code for SetExp_Par.fig
%      SETEXP_PAR, by itself, creates a new SETEXP_PAR or raises the existing
%      singleton*.
%
%      H = SETEXP_PAR returns the handle to a new SETEXP_PAR or the handle to
%      the existing singleton*.
%
%      SETEXP_PAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETEXP_PAR.M with the given input arguments.
%
%      SETEXP_PAR('Property','Value',...) creates a new SETEXP_PAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetExp_Par_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetExp_Par_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetExp_Par

% Last Modified by GUIDE v2.5 20-Oct-2019 22:24:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SetExp_Par_OpeningFcn, ...
                   'gui_OutputFcn',  @SetExp_Par_OutputFcn, ...
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


% --- Executes just before SetExp_Par is made visible.
function SetExp_Par_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetExp_Par (see VARARGIN)

% Choose default command line output for SetExp_Par
handles.output = hObject;

%=== DEFAULT SETTINGS ==============================================

% Set SPM file from the input---
handles.SPM = varargin{1};

% Identify number of sessions
Sess = length(handles.SPM.nscan);

%===== Set Session Panel Menu =====

%--- Session Panel ---
for ss = 1:Sess
	Tpoint{ss} = '-';
	Tnames{ss} = ['Session ' num2str(ss,'%02i')];
	Tnscan{ss} = handles.SPM.nscan(ss);
	Tcheck{ss} = false;
end

columnname     = {'' , 'Session', 'N.Scans', 'Set'};
columnformat   = {'char', 'char', 'numeric', 'logical'};
columneditable = [false false false false];
columnwidth    = {20,110,75,40};

%--- Update table ---
set(handles.SsTable,'ColumnEditable',columneditable);
set(handles.SsTable,'ColumnName',columnname);
set(handles.SsTable,'ColumnFormat',columnformat);
set(handles.SsTable,'ColumnWidth',columnwidth);
set(handles.SsTable,'Data',[Tpoint' Tnames' Tnscan' Tcheck'])


%===== Initialize Default Session Menu =====
handles.SS = 1;

%--- Initialize Sparsity Menu ---
for ss = 1:Sess

	NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;

	Tcheck = repmat({true},1,NSrc_A);
	Tnames = handles.SPM.TEDM.Param(ss).name;
	Tdata  = num2cell(handles.SPM.TEDM.Param(ss).Sp_A);

	handles.SPM.TEDM.Param(ss).SpDat = [Tcheck' Tnames' Tdata'];
end

%--- Set Common format ---
columnname     = {'', 'Condition', 'Sp %'};
columnformat   = {'logical', 'char', 'numeric'};
columneditable = [true true true];
columnwidth    = {30, 110, 40};

set(handles.SpTable,'ColumnEditable',columneditable);
set(handles.SpTable,'ColumnName',columnname);
set(handles.SpTable,'ColumnFormat',columnformat);
set(handles.SpTable,'ColumnWidth',columnwidth);


UpdateSessionMenu(hObject, eventdata, handles);
 

%-- Remove navigation buttons for a single session ---
if(Sess==1)
	set(handles.ButNext,'Enable','off');
	set(handles.ButBack,'Enable','off');
end

%=== Set default prefix ===
set(handles.Prefix,'String',handles.SPM.TEDM.hist.prefix);

%===================================================================

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SetExp_Par wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SetExp_Par_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function NSrc_A_Callback(hObject, eventdata, handles)
% hObject    handle to NSrc_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NSrc_A as text
%        str2double(get(hObject,'String')) returns contents of NSrc_A as a double


% --- Executes during object creation, after setting all properties.
function NSrc_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NSrc_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NSrc_F_Callback(hObject, eventdata, handles)
% hObject    handle to NSrc_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Session
ss     = handles.SS;

NSrc_F = str2double(get(hObject,'String'));
NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;

% Udate
handles.SPM.TEDM.Param(ss).NSrc_F = NSrc_F;
handles.SPM.TEDM.Param(ss).K      = NSrc_A + NSrc_F;

% Update handles structure
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function NSrc_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NSrc_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ValSp_F_Callback(hObject, eventdata, handles)
% hObject    handle to ValSp_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ValSp_F as text
%        str2double(get(hObject,'String')) returns contents of ValSp_F as a double

% Session
% Parameters
ss     = handles.SS;

% Check number of components
SpF = str2num(get(hObject,'String'));
NSrc_F = length(SpF);

NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;
K      = handles.SPM.TEDM.Param(ss).K;

if(NSrc_F~=(K-NSrc_A))

	warndlg(['The number of parameter of the sparsity percentage \n' ...
		' does not macth the number of selected free sources. -_(o_o )_-   '],'Warning');
end


% --- Executes during object creation, after setting all properties.
function ValSp_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValSp_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First, chect the parameters
Touch = prod(handles.SPM.TEDM.Touch);

if(~Touch)
	warndlg('Please, check the all settings to continue.   ','Check Settings');

else

	%--- Save parameters ---
	file   = handles.SPM.TEDM.hist.file;
	prefix = handles.SPM.TEDM.hist.prefix;

	name = [file{2} prefix 'SPM.mat'];

	SPM = handles.SPM;

	save(name,'SPM');

	close
	
	msgbox('Operation completed!','Set Experiment','help');

end



function SimVal_Callback(hObject, eventdata, handles)
% hObject    handle to SimVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SimVal as text
%        str2double(get(hObject,'String')) returns contents of SimVal as a double


% --- Executes during object creation, after setting all properties.
function SimVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Check.
function Check_Callback(hObject, eventdata, handles)
% hObject    handle to Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in Sim_Panel.
function Sim_Panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Sim_Panel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Session
ss     = handles.SS;

% Default
set(handles.SimVal,'Enable','off');

% Select option

ButID = get(eventdata.NewValue,'Tag');

switch ButID

	case 'ButSim_Con'
		handles.SPM.TEDM.Param(ss).SimMode = 'Conservative';

	case 'ButSim_Ave'
		handles.SPM.TEDM.Param(ss).SimMode = 'Average';

	case 'ButSim_Rel'
		handles.SPM.TEDM.Param(ss).SimMode = 'Relaxed';

	otherwise
		handles.SPM.TEDM.Param(ss).SimMode = 'Manual';

		% Enable manual similarity selection
		set(handles.SimVal,'Enable','on');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in ExtraComp_Panel.
function ExtraComp_Panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ExtraComp_Panel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Session
ss     = handles.SS;

% Default setting
set(handles.ValSp_F,'Enable','off');

% Update Selection
ButID = get(eventdata.NewValue,'Tag');

switch ButID
	case 'ButSp_Aut'
		handles.SPM.TEDM.Param(ss).SpMode = 'Auto';

	otherwise
		handles.SPM.TEDM.Param(ss).SpMode = 'Manual';

		% Enable manual selection
		set(handles.ValSp_F,'Enable','on');
end

% Update handles structure
guidata(hObject, handles);

function Prefix_Callback(hObject, eventdata, handles)
% hObject    handle to Prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Prefix as text
%        str2double(get(hObject,'String')) returns contents of Prefix as a double

% Update prefix
prefix = get(hObject,'String');

handles.SPM.TEDM.hist.prefix = prefix;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButConfirm.
function ButConfirm_Callback(hObject, eventdata, handles)
% hObject    handle to ButConfirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
ss     = handles.SS;
% Determine if it was touched
Check = handles.SPM.TEDM.Touch(ss);
Procs = true;

if(Check)
  msg1 = 'The selected session was alreday processed';
  msg2 = 'Do you want to overwrite current session?';

  answer = questdlg({msg1, msg2},'Warning',...
    'Yes','No','Yes');

  switch answer
    case 'Yes'
      Procs = true;
    otherwise
      Procs = false;
  end
end

if(Procs)

	pass = CheckParameters(hObject, eventdata, handles);

	% Confirm checking
	if(pass)

		Dat    = get(handles.SsTable, 'Data');
		Tcheck = Dat(:,4); 

		% Update table ssesion
		Tcheck{ss}=true;
		Dat(:,4) = Tcheck';

		set(handles.SsTable,'Data',Dat);
	end
end


% --- Executes on button press in ButNext.
function ButNext_Callback(hObject, eventdata, handles)
% hObject    handle to ButNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess  = length(handles.SPM.nscan);
SS    = handles.SS;

% Increase session
if(SS>=Sess)
	SS = 1;
else
	SS = SS + 1;
end

handles.SS = SS;

% Update menu
UpdateSessionMenu(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in ButBack.
function ButBack_Callback(hObject, eventdata, handles)
% hObject    handle to ButBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess  = length(handles.SPM.nscan);
SS    = handles.SS;

% Increase session
if(SS<=1)
	SS = Sess;
else
	SS = SS - 1;
end

handles.SS = SS;

% Update menu
UpdateSessionMenu(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);



% --- Executes when entered data in editable cell(s) in SpTable.
function SpTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to SpTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

currentCell = eventdata.Indices;

% Check for a selected cell
if(~isempty(currentCell))

	ss   = handles.SS;
	SpDat = get(handles.SpTable,'Data');

	handles.SPM.TEDM.Param(ss).SpDat = SpDat;

    % Update handles structure
    guidata(hObject, handles);
end


%%==== Auxililar Functions =========
function [pass] = CheckParameters(hObject, eventdata, handles)
% This function check if the parameter were correctly update
% and fullfill the default parameters.

pass = false;
ss = handles.SS;  % Set particular studied session

if(handles.SPM.TEDM.Touch(ss))

	Line = 'Do you want to rewrite the current parameters?';
	answer = questdlg(Line,'Warning!','Yes','No','Yes');

	switch answer
		case 'Yes'
			handles.SPM.TEDM.Touch(ss) = false;

		otherwise
			handles.SPM.TEDM.Touch(ss) = true;
	end
end

if(~handles.SPM.TEDM.Touch(ss))
	%--- Number of components ---
	NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;
	K      = handles.SPM.TEDM.Param(ss).K;

	% Free components
	if(K==NSrc_A)
		handles.SPM.TEDM.Param(ss).FreeCmp = false;
	else
		handles.SPM.TEDM.Param(ss).FreeCmp = true;
	end

	%--- Sparsity Percentage ---
	% Assisted Components
	SpData = get(handles.SpTable,'Data');

	name = SpData(:,2);
	Sp_A = cell2mat(SpData(:,3));

	% Update the selected regressors
	Select = SpData(:,1);
	cnt = 0;

	for i = 1:(NSrc_A-1)
		if(Select{i})
			cnt = cnt + 1;

			up_name{cnt} = name{i};
			up_Sp_A(cnt) = Sp_A(i);

		end
	end

	% Constant atom
	if(Select{NSrc_A})
		cnt = cnt + 1;

		handles.SPM.TEDM.Param(ss).iB = cnt;

		up_name{cnt} = name{NSrc_A};
		up_Sp_A(cnt) = Sp_A(NSrc_A);

	else
		Line1 = 'The constant component for the background was not selected!';
		Line2 = '-------- This option is not recommended ----------';
		Line3 = 'User discretion is advised \(o-o ) ';
		warndlg({Line1,' ', Line2 , ' ',Line3}, 'No Constant Regressor');

		handles.SPM.TEDM.Param(ss).iB = [];
	end

	% Update  components
	handles.SPM.TEDM.Param(ss).Aname = up_name';
	handles.SPM.TEDM.Param(ss).Sp_A = up_Sp_A;

	handles.SPM.TEDM.Param(ss).NSrc_A = cnt;
	handles.SPM.TEDM.Param(ss).K      = K-NSrc_A+cnt;

	% Update names
	cfree = 1;
	for i = 1:handles.SPM.TEDM.Param(ss).K;
		
		Cname = sprintf('Cmp%02i-',i);

		if (i<=cnt)
			Cname = [Cname up_name{i}];
		else
			Cname = [Cname sprintf('Extra%03i',cfree)];
			cfree = cfree+1;
		end

		handles.SPM.TEDM.Param(ss).names{i} = Cname;

	end


	% Update Canonincal Dictionary
	Sl = cell2mat(Select)';
	Del = handles.SPM.TEDM.Param(ss).Del;

	handles.SPM.TEDM.Param(ss).Del = Del(:,Sl);


	% Free components
	if(handles.SPM.TEDM.Param(ss).FreeCmp)

		%Check sparsity mode
		switch handles.SPM.TEDM.Param(ss).SpMode
			case 'Auto'
				% Number of free components
				NSrc_F = handles.SPM.TEDM.Param(ss).NSrc_F;

				SpF = tedm_AutoSparsity(NSrc_F);

			otherwise
				SpF = str2num(get(handles.ValSp_F,'String'));
		end

	else
		% No free components
		SpF = [];
	end

	handles.SPM.TEDM.Param(ss).Sp_F = SpF;

	% Set sparsity of the free components

	%--- Similarity Constraint ---
	Mode = handles.SPM.TEDM.Param(ss).SimMode;

	switch Mode
		case 'Manual'
			cdl = str2num(get(handles.SimVal,'String'));

		otherwise
			cdl = tedm_AutoSimilarity(handles.SPM,ss);
	end

	% Set parameter
	handles.SPM.TEDM.Param(ss).cdl = cdl;

	% Initialization completed
	handles.SPM.TEDM.Touch(ss) = true;


	% Update handles structure
	guidata(hObject, handles);

	pass = true;

end

% Update Session Function
function UpdateSessionMenu(hObject, eventdata, handles)
% This function update the Session Menu with all the 
% required parameters

%--- Set default components ---
ss     = handles.SS;
K      = handles.SPM.TEDM.Param(ss).K;
NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;

set(handles.NSrc_A,'String',num2str(NSrc_A));
set(handles.NSrc_F,'String',num2str(K-NSrc_A));

%--- Sesion title --
set(handles.PanelSs,'Title',['Session ' num2str(ss,'%02i')]);
 
 
%--- Set sparsity percentage ---
SpDat   = handles.SPM.TEDM.Param(ss).SpDat;
set(handles.SpTable,'Data',SpDat);

%--- Update Session pointer ---
Sess   = length(handles.SPM.nscan);
Dat    = get(handles.SsTable,'Dat');
Tpoint = repmat({'-'},1,Sess);
Tpoint{ss} = '>';

Dat(:,1) = Tpoint;

set(handles.SsTable,'Data',Dat);

% Update handles structure
guidata(hObject, handles);
