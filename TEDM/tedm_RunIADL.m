function varargout = tedm_RunIADL(varargin)
% TEDM_RUNIADL MATLAB code for tedm_RunIADL.fig
%      TEDM_RUNIADL, by itself, creates a new TEDM_RUNIADL or raises the existing
%      singleton*.
%
%      H = TEDM_RUNIADL returns the handle to a new TEDM_RUNIADL or the handle to
%      the existing singleton*.
%
%      TEDM_RUNIADL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEDM_RUNIADL.M with the given input arguments.
%
%      TEDM_RUNIADL('Property','Value',...) creates a new TEDM_RUNIADL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tedm_RunIADL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tedm_RunIADL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tedm_RunIADL

% Last Modified by GUIDE v2.5 23-Aug-2019 19:15:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tedm_RunIADL_OpeningFcn, ...
                   'gui_OutputFcn',  @tedm_RunIADL_OutputFcn, ...
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


% --- Executes just before tedm_RunIADL is made visible.
function tedm_RunIADL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tedm_RunIADL (see VARARGIN)

% Choose default command line output for tedm_RunIADL
handles.output = hObject;

%=== DEFAULT SETTINGS ==============================================

%--- Set SPM file from the input---
handles.SPM = varargin{1};

%--- Information ---
set(handles.InfoPrefix,'String',handles.SPM.TEDM.hist.file{1});
set(handles.InfoAssisted,'String',num2str(handles.SPM.TEDM.Param.NSrc_A));
set(handles.InfoComponent,'String',num2str(handles.SPM.TEDM.Param.NSrc_F));
set(handles.InfoSimilarity,'String',num2str(handles.SPM.TEDM.Param.cdl));
set(handles.InfoOutput,'String',handles.SPM.TEDM.hist.outfile);

%=== Info. Figures ===
% Parameters
Sp_A   = handles.SPM.TEDM.Param.Sp_A;
Sp_F   = handles.SPM.TEDM.Param.Sp_F;
K      = handles.SPM.TEDM.Param.K;
NSrc_A = handles.SPM.TEDM.Param.NSrc_A;

%----- Task related time courses -----
% Reference Dictionary
Del = handles.SPM.TEDM.Param.Del;

% Plot
axes(handles.axesTask);
axT = imagesc(Del);

% Features
axT = colormap(flipud(bone));
set(handles.axesTask,'XTick',[1:1:NSrc_A]);
set(handles.axesTask,'YTick',[]);
set(handles.axesTask,'XAxisLocation','top');
set(handles.axesTask,'YGrid','off');


%----- Sparsity Percentage -----

% Plot
axes(handles.axesSp);

bar([Sp_A Sp_F],'b');
hold on
bar(Sp_A,'r');

% Features

if (K<=30)
	stp = 1;
else
	stp = 2;
end

set(handles.axesSp,'XLim',[0.5 K+0.5]);
set(handles.axesSp,'XTick',[1:stp:K]);
set(handles.axesSp,'YGrid','on');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tedm_RunIADL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tedm_RunIADL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in But_EDM.
function But_EDM_Callback(hObject, eventdata, handles)
% hObject    handle to But_EDM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%=== Prepare Parameter ====
% Defien progress var
Pbar = waitbar(0.0,'Setting Parameters','Name','Initialization');
fprintf('Setting parameters\n');
for i=1:50; fprintf('_'); end

Param.data = 1;

%===== MAIN PARAMETERS =====================================================

% Information Progreess

waitbar(0.1,Pbar,'Reading Parameters','Name','Initialization');
fprintf('_______________________________________________\n\n');
fprintf('   Reading Parameters ----------- [  ]');

%--- Parameters ---
Opt.K   = handles.SPM.TEDM.Param.K;
Opt.Del = handles.SPM.TEDM.Param.Del; 
Opt.L_A = handles.SPM.TEDM.Param.Sp_A;
Opt.L_F = handles.SPM.TEDM.Param.Sp_F;
Opt.cdl = handles.SPM.TEDM.Param.cdl; 

VY    = handles.SPM.xY.VY;
xM    = handles.SPM.xM;
DIM   = VY(1).dim;
nScan = handles.SPM.nscan;

mask = true(DIM);

fprintf('\b\b\bOk]\n');

%===== MASCARADA ===========================================================
waitbar(0.2,Pbar,'Get Data and Applaying Mask');
fprintf('   Get Data and Applying Mask --- [  ]');

%--- Split data into chuncks ---
chunksize = floor(spm_get_defaults('stats.maxmem') / 8 / nScan);
N_chunks  = ceil(prod(DIM) / chunksize);
chunks    = min(cumsum([1 repmat(chunksize,1,N_chunks)]),prod(DIM)+1);

lns = linspace(0.2,0.8,N_chunks);

% Chuck's Loop
for i = 1:N_chunks

  chunk = chunks(i):chunks(i+1)-1;

  % Get data and costruct analysis mask
  Y     = zeros(nScan,numel(chunk));
  cmask = mask(chunk);

  for j = 1:nScan
    if ~any(cmask), break, end       % - Break if empty mask

    % Read chunk of data
    Y(j,cmask) = spm_data_read(VY(j),chunk(cmask)); 

    cmask(cmask) = Y(j,cmask) > xM.TH(j);

    if xM.I && ~YNaNrep && xM.TH(j) < 0  % Use implicit mask
      cmask(cmask) = abs(Y(:,cmask)) > eps;
    end
  end

  cmask(cmask) = any(diff(Y(:,cmask),1)); % Mask constant data
  mask(chunk)  = cmask;

  if ~any(cmask), continue, end
  
  % Store chunks of data
  if i==1
    Dat = Y(:,cmask);
  else
    Dat = [Dat Y(:,cmask)];
  end

  waitbar(lns(i),Pbar);
end

% Store data
Opt.Dat = Dat;

clear('Dat','Y','cmask');

fprintf('\b\b\bOk]\n'); 

%=== DETRENDING =======================================================
fprintf('   - Detrending ----------------- [  ]');
waitbar(0.81,Pbar,'Detrending');

AuxDat = double(Opt.Dat);

% Subtract the mean
AuxDat = tedm_SinMed(AuxDat);

% Subtract trends
AuxDat = detrend(AuxDat);

% Update data
Opt.Dat = AuxDat;

clear('AuxDat');

fprintf('\b\b\bOk]\n');
waitbar(0.9,Pbar);

%=== CHEKING PARAMETERS ==========================================
fprintf('   - Checking parameters -------- [  ]');
waitbar(0.95,Pbar,'Checking Parameters');


%--- Defaluts --------------------------------------------
param.iter  = 50;           % Number of iterations
param.Ini   = 'Jdr';          % Initialization mode
param.mgreg = 'n';            % No post-processing
param.Preg  = 'n';            % No data reduction
param.Verb  = 'y';         % Display verbose
%---------------------------------------------------------

param.data  = Opt.Dat;           % Data
param.K     = Opt.K;             % Total number of components
param.Lam   = [Opt.L_A Opt.L_F]; % Sparsity parameters
param.Del   = Opt.Del;           % Task-related time courses
param.cdl   = Opt.cdl;           % Similarity parameter

clear('Opt');

fprintf('\b\b\bOk]\n');
fprintf('_______________________________________________\n\n\n');
close(Pbar);

%=== CALL IADL ============================================================

    [D,s] = tedm_IADL(param);

clear('param');

%=== SAVE REGRESSORS =======================================================
fprintf('   - Saving Results -------- [  ]');
Pbar = waitbar(0,'Save Mask...','Name','Save Results');

%-Initialise mask file
%--------------------------------------------------------------------------
% Parameters dimensions and orientation
file_ext = '.nii';
DIM  = handles.SPM.xY.VY(1).dim;
M    = handles.SPM.xY.VY(1).mat;
metadata = {};

VM = struct(...
    'fname',   ['tedm_mask' file_ext],...
    'dim',     DIM,...
    'dt',      [spm_type('uint8') spm_platform('bigend')],...
    'mat',     M,...
    'pinfo',   [1 0 0]',...
    'descrip', 'spm_spm:resultant analysis mask',...
    metadata{:});
VM = spm_data_hdr_write(VM);

% Save mask file
VM = spm_data_write(VM,mask);

Pbar = waitbar(1,Pbar);

%-Remove constant atom
%---------------------------------------------------------------------------
Pbar = waitbar(0,Pbar,'Remove constant atom...');
K = handles.SPM.TEDM.Param.K;
iB = handles.SPM.TEDM.Param.iB;

D(:,iB) = [];
s(iB,:) = [];

% Update names
handles.SPM.TEDM.Param.names(iB) = [];

K = K-1;

Pbar = waitbar(1,Pbar);

%-Save spatial maps
%---------------------------------------------------------------------------
Pbar = waitbar(0,Pbar,'Saving spatial maps...');

%--- Initalise map file ---
% Parameters, dimensions and orientation
file_ext = '.nii';
DIM  = handles.SPM.xY.VY(1).dim;
M    = handles.SPM.xY.VY(1).mat;

% Initialize spatial maps
Vmap(1:K) = deal(struct(...
  'fname',   [],...
  'dim',     DIM,...
  'dt',      [spm_type('float32') spm_platform('bigend')],...
  'mat',     M,...
  'pinfo',   [1 0 0]',...
  'descrip', 'spm_spm:beta',...
  metadata{:}));

for i = 1:K
  cmpnames        = handles.SPM.TEDM.Param.names;
  name            = [sprintf(['tedm_' cmpnames{i}],i) file_ext];
  Vmap(i).fname   = name;
  Vmap(i).descrip = sprintf('spm_spm:beta (%04d) - %s',i,name);

  % Save names
  handles.SPM.TEDM.Res.xS{i} = name;

end

% Write info
Vmap = spm_data_hdr_write(Vmap);


% Components
Pbar = waitbar(0.1,Pbar);
lns = linspace(0.1,1,K);

for i = 1:K
  Cmp = NaN(size(mask));

  % Save Components
  Cmp(mask) = s(i,:)';
  Vmap(i) = spm_data_write(Vmap(i),Cmp);

  Pbar = waitbar(lns(i),Pbar);
end
   

% Clear stuff
clear('Cmp','msk');

fprintf('\b\b\bOk]\n');
close(Pbar);


%=== Update Design matrix ======================================================
fprintf('   - Update Design Matrix -- [  ]');

%--- Save Temporal Components
handles.SPM.TEDM.Res.xD = D;

%--- Create new SPM file with the Enhanced Design matrix
tedm_Update_fMRI_design(handles.SPM);

upDM = questdlg('Do you want to use the full enhacned design matrix?',...
	                'Selection of the regressors',...
	                'Yes','No','Yes');

fprintf('\b\b\bOk]\n');

switch upDM
  case 'No'
    fprintf('   - Call Menu for manual selection -\n');

    tedm_SelectRegressor(SPM);

  otherwise
    fprintf('   - Full design matrix succesfully updated \\(^ ^)/\n');
end

fprintf('\n\n______________________________________________________________');



function InfoPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to InfoPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoPrefix as text
%        str2double(get(hObject,'String')) returns contents of InfoPrefix as a double


% --- Executes during object creation, after setting all properties.
function InfoPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InfoAssisted_Callback(hObject, eventdata, handles)
% hObject    handle to InfoAssisted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoAssisted as text
%        str2double(get(hObject,'String')) returns contents of InfoAssisted as a double


% --- Executes during object creation, after setting all properties.
function InfoAssisted_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoAssisted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InfoComponent_Callback(hObject, eventdata, handles)
% hObject    handle to InfoComponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoComponent as text
%        str2double(get(hObject,'String')) returns contents of InfoComponent as a double


% --- Executes during object creation, after setting all properties.
function InfoComponent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoComponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InfoSimilarity_Callback(hObject, eventdata, handles)
% hObject    handle to InfoSimilarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoSimilarity as text
%        str2double(get(hObject,'String')) returns contents of InfoSimilarity as a double


% --- Executes during object creation, after setting all properties.
function InfoSimilarity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoSimilarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axesTask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2axes(handles.axes);



function InfoOutput_Callback(hObject, eventdata, handles)
% hObject    handle to InfoOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoOutput as text
%        str2double(get(hObject,'String')) returns contents of InfoOutput as a double

% Update output
out = get(hObject,'String');

handles.SPM.TEDM.hist.outfile = out;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function InfoOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
