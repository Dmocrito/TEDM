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

% Last Modified by GUIDE v2.5 04-Aug-2020 14:09:43

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

% Set SPM file from the input---
handles.SPM = varargin{1};

% Identify number of sessions
Sess = length(handles.SPM.nscan);
set(handles.SessionText,'String',num2str(Sess,'%02i'));

%--- Session Menu Update ---
handles.SS = 1; % Session 1 as default

UpdateSessionMenu(hObject, eventdata, handles);
 

%-- Remove navigation buttons for a single session ---
if(Sess==1)
  set(handles.ButSessNext,'Visible','off');
  set(handles.ButSessPrev,'Visible','off');
end

% Input file info
file = handles.SPM.TEDM.hist.file;
set(handles.InputText,'String',file{1});

%=== Set default prefix ===
outfile = handles.SPM.TEDM.hist.outfile;
set(handles.outPrefix,'String',[outfile '.mat']);

%===================================================================

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


% --- Executes on button press in ButEDM.
function ButEDM_Callback(hObject, eventdata, handles)
% hObject    handle to ButEDM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%=== Sessions ===
Sess = length(handles.SPM.nscan);

for ss = 1:Sess

  %=== Prepare Parameter ====
  c = fix(clock);
  fprintf('------------------------------------------------------------------------\n');
  fprintf('   Session %02i                                                  %2i:%2i\n',ss,c(4),c(5));
  fprintf('========================================================================\n');

  % Defien progress var
  Pbar = waitbar(0.0,'Setting Parameters','Name','Initialization');
  for i=1:72; fprintf('_'); end
  fprintf('\n\n');


  %===== MAIN PARAMETERS =====================================================

  %Information Progreess

  waitbar(0.1,Pbar,'Reading parameters','Name','Initialization');
  fprintf('   Reading parameters --------------------------- [  ]');

  %--- Parameters ---
  Opt.K   = handles.SPM.TEDM.Param(ss).K;
  Opt.Del = handles.SPM.TEDM.Param(ss).Del; 
  Opt.L_A = handles.SPM.TEDM.Param(ss).Sp_A;
  Opt.L_F = handles.SPM.TEDM.Param(ss).Sp_F;
  Opt.cdl = handles.SPM.TEDM.Param(ss).cdl; 

  VY    = handles.SPM.xY.VY;
  xM    = handles.SPM.xM;
  nScan = handles.SPM.nscan(1);
  iScan = 1; 

  % Check sessions
  if(ss>1)
  	% Update total number of scans
  	nScan = handles.SPM.nscan(ss);

  	% Update first scan position
    iScan = 1 + sum(handles.SPM.nscan(1:(ss-1)));

  end

  DIM   = VY(iScan).dim;
  mask = true(DIM);

  fprintf('\b\b\bOk]\n');

  %===== MASCARADA ===========================================================
  waitbar(0.2,Pbar,'Get data and apply mask');
  fprintf('   Get data and apply mask ---------------------- [  ]');

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
        
      idS = iScan + j-1;
      
      if ~any(cmask), break, end       % - Break if empty mask

      % Read chunk of data
      Y(j,cmask) = spm_data_read(VY(idS),chunk(cmask)); 

      cmask(cmask) = Y(j,cmask) > xM.TH(idS);

      if xM.I && ~YNaNrep && xM.TH(idS) < 0  % Use implicit mask
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
  fprintf('   Detrending ----------------------------------- [  ]');
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
  fprintf('   Checking parameters -------------------------- [  ]');
  waitbar(0.95,Pbar,'Checking Parameters');


  %--- Defaluts --------------------------------------------
  %param.iter  = 3000;           % Number of iterations
  param.iter  = 10; %<====================================================================== Just for testing =b
  param.Ini   = 'Jdr';          % Initialization mode
  param.mgreg = 'n';            % No post-processing
  param.Preg  = 'n';            % No data reduction
  param.Verb  = 'y';            % Display verbose
  %---------------------------------------------------------

  param.data  = Opt.Dat;           % Data
  param.K     = Opt.K;             % Total number of components
  param.Lam   = [Opt.L_A Opt.L_F]; % Sparsity parameters
  param.Del   = Opt.Del;           % Task-related time courses
  param.cdl   = Opt.cdl;           % Similarity parameter

  clear('Opt');

  fprintf('\b\b\bOk]\n');
  for i=1:72; fprintf('_'); end
  fprintf('\n\n');
  close(Pbar);

  %=== CALL IADL ============================================================

  [D,s] = tedm_IADL(param);

  clear('param');

  %=== SAVE REGRESSORS =======================================================
  for i=1:72; fprintf('_'); end
  fprintf('\n\n');
  fprintf('   Saving results ------------------------------- [  ]');
  Pbar = waitbar(0,'Save Mask...','Name','Save Results');

  %-Initialise mask file
  %--------------------------------------------------------------------------
  % Parameters dimensions and orientation
  file_ext = '.nii';
  DIM  = handles.SPM.xY.VY(iScan).dim;
  M    = handles.SPM.xY.VY(iScan).mat;
  metadata = {};

  VM = struct(...
    'fname',   ['tedm_mask-Ss_' num2str(ss,'%02i') file_ext],...
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
  K  = handles.SPM.TEDM.Param(ss).K;
  iB = handles.SPM.TEDM.Param(ss).iB;

  D(:,iB) = [];
  s(iB,:) = [];

  % Update names
  handles.SPM.TEDM.Param(ss).names(iB) = [];

  K = K-1;

  Pbar = waitbar(1,Pbar);

  %-Save spatial maps
  %---------------------------------------------------------------------------
  Pbar = waitbar(0,Pbar,'Saving spatial maps...');

  %--- Initalise map file ---
  % Parameters, dimensions and orientation
  file_ext = '.nii';
  DIM  = handles.SPM.xY.VY(iScan).dim;
  M    = handles.SPM.xY.VY(iScan).mat;

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
    cmpnames        = handles.SPM.TEDM.Param(ss).names;
    name            = [sprintf(['tedm-Ss' num2str(ss,'%02i') '_' cmpnames{i}],i) file_ext];
    Vmap(i).fname   = name;
    Vmap(i).descrip = sprintf('spm_spm:beta (%04d) - %s',i,name);

    % Save names
    handles.SPM.TEDM.Res(ss).xS{i} = name;

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
  clear('Cmp','msk','Vmap');
  close(Pbar);

  %===== Store spatial components in a signle 4D-nii file =====

  % Take names
  for i=1:K
    fname{i} = handles.SPM.TEDM.Res(ss).xS{i};
  end

  %--- Create 4D file ---
  NiiName = ['tedm-AllComps-Ss_' num2str(ss,'%02i') '.nii'];
  spm_file_merge(fname,NiiName,64);

  % Remove old 3d files
  for i=1:K
    spm_unlink(fname{i});
  end

  % Clear stuff
  clear('Cmp','msk','Vmap');

  fprintf('\b\b\bOk]\n');

  %===== Update Design matrix =====
  fprintf('   Store Enhanced Design Matrix ----------------- [  ]');

  %--- Save Temporal Components
  handles.SPM.TEDM.Res(ss).xD = D;

  %--- Selct all the regressors
  for(k = 1:K)
    handles.SPM.TEDM.Param(ss).SetReg{k} = true;
  end


  fprintf('\b\b\bOk]\n');
end

%--- Create a new SPM file with the Enhacned design matrix ---

tedm_Update_fMRI_design(handles.SPM);

msgbox('The matrix was succesfully enhacned','Operation Completed','help');

%--- Create new SPM file with the Enhanced Design matrix
%tedm_Update_fMRI_design(handles.SPM);
%
%upDM = questdlg('Do you want to use the full enhacned design matrix?',...
%                  'Selection of the regressors',...
%                  'Yes','No','Yes');
%
%fprintf('\b\b\bOk]\n');
%
%switch upDM
%  case 'No'
%    fprintf('   - Call Menu for manual selection -\n');
%
%    tedm_SelectRegressor(SPM);
%
%  otherwise
%    fprintf('   - Full design matrix succesfully updated \\(^ ^)/\n');
%end
%
%fprintf('\n\n______________________________________________________________');



function textcdl_Callback(hObject, eventdata, handles)
% hObject    handle to textcdl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textcdl as text
%        str2double(get(hObject,'String')) returns contents of textcdl as a double


% --- Executes during object creation, after setting all properties.
function textcdl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textcdl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to outPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outPrefix as text
%        str2double(get(hObject,'String')) returns contents of outPrefix as a double

% Update outPrefix
prefix = get(hObject,'String');

handles.SPM.TEDM.hist.outfile = prefix;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function outPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InputText_Callback(hObject, eventdata, handles)
% hObject    handle to InputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InputText as text
%        str2double(get(hObject,'String')) returns contents of InputText as a double


% --- Executes during object creation, after setting all properties.
function InputText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SessionText_Callback(hObject, eventdata, handles)
% hObject    handle to SessionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SessionText as text
%        str2double(get(hObject,'String')) returns contents of SessionText as a double


% --- Executes during object creation, after setting all properties.
function SessionText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SessionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButSessNext.
function ButSessNext_Callback(hObject, eventdata, handles)
% hObject    handle to ButSessNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess = length(handles.SPM.nscan);
ss   = handles.SS;

% Move Session
ss = ss + 1;

if(ss>Sess)
  ss = 1;
end

handles.SS = ss;

% Update session menu
UpdateSessionMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButSessPrev.
function ButSessPrev_Callback(hObject, eventdata, handles)
% hObject    handle to ButSessPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameters
Sess = length(handles.SPM.nscan);
ss   = handles.SS;

% Move Session
ss = ss - 1;

if(ss<1)
  ss = Sess;
end

handles.SS = ss;

% Update session menu
UpdateSessionMenu(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);


%===== Extra Functions ======================================

% Update Session Function
function UpdateSessionMenu(hObject, eventdata, handles)
% This function update the Session Menu with all the 
% required parameters

% Parameters
ss = handles.SS;
Sp_A   = handles.SPM.TEDM.Param(ss).Sp_A;
Sp_F   = handles.SPM.TEDM.Param(ss).Sp_F;
K      = handles.SPM.TEDM.Param(ss).K;
NSrc_A = handles.SPM.TEDM.Param(ss).NSrc_A;

Sp_Vct = [Sp_A Sp_F];

%--- Session Panel ----
set(handles.PanelSS,'Title',['Session ' num2str(ss,'%02i')]);

%--- Similarity parameter ---
cdl = handles.SPM.TEDM.Param(ss).cdl;
set(handles.textcdl,'String',num2str(cdl));

%----- Task related time courses -----
% Reference Dictionary
Del = handles.SPM.TEDM.Param(ss).Del;

% Plot
axes(handles.axesTask);
axT = imagesc(Del);

% Features
axT = colormap(flipud(bone));
set(handles.axesTask,'XTick',[1:1:NSrc_A]);
set(handles.axesTask,'YTick',[]);
set(handles.axesTask,'XAxisLocation','top');
set(handles.axesTask,'YGrid','off');

%--- Sparsity Parameters ---
for kk = 1:K
  Tnames{kk} = handles.SPM.TEDM.Param(ss).names{kk};
  Tspars{kk} = Sp_Vct(kk);
  
  if(kk<=NSrc_A) 
    Tpoint{kk} = 'A';
  else
    Tpoint{kk} = 'F';
  end
end

% Update Table

columnname     = {'Component', 'A/F', 'Sp'};
columnformat   = {'char', 'char', 'numeric'};
columneditable = [false false false];
columnwidth    = {150,30,40};

%--- Update table ---
set(handles.TableParam,'ColumnEditable',columneditable);
set(handles.TableParam,'ColumnName',columnname);
set(handles.TableParam,'ColumnFormat',columnformat);
set(handles.TableParam,'ColumnWidth',columnwidth);
set(handles.TableParam,'Data',[Tnames' Tpoint' Tspars']);

% Update handles structure
guidata(hObject, handles);
