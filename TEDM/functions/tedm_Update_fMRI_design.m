function [SPM] = tedm_Update_fMRI_design(SPM_old)

% Prepare basic parameter to create a new SMP file with the enhanced DM


if(~isfield(SPM_old.TEDM,'Res'))
	error('Well, something went wrong: No Enhanced Design Matrix detected');
end

%--- Number of sessions ---
nSess = numel(SPM_old.nscan);

%--- Update basic parameter set up ---
SPM.xY.RT  = SPM_old.xY.RT;
SPM.xY.P   = SPM_old.xY.P;

SPM.xBF.UNITS    = SPM_old.xBF.UNITS;
SPM.xBF.T        = SPM_old.xBF.T;
SPM.xBF.T0       = SPM_old.xBF.T0;
SPM.xBF.name     = SPM_old.xBF.name;
SPM.xBF.Volterra = SPM_old.xBF.Volterra;

SPM.nscan = SPM_old.nscan;

SPM.factor = SPM_old.factor;

SPM.xGX.iGXcalc = SPM_old.xGX.iGXcalc;

SPM.xM.gMT = SPM_old.xM.gMT;

SPM.xX.K.HParam = SPM_old.xX.K.HParam;

SPM.xVi.form = SPM_old.xVi.form;

% Save TEDM Information
SPM.TEDM = SPM_old.TEDM;

%=== Set Enhanced Design Matrix ===
for ss = 1:nSess
    SPM.Sess(ss).U = [];
    SPM.Sess(ss).C.C = SPM.TEDM.Res(ss).xD;
    SPM.Sess(ss).C.name = SPM.TEDM.Param(ss).names;
end

%=== Call SPM parametrization ===
[SPM] = tedm_fMRI_spm_ui(SPM);