function [SPM] = tedm_Update_fMRI_design(SPM_old)

% Prepare basic parameter to create a new SMP file with the enhanced DM


if(~isfield(SPM_old.TEDM,'Res'))
	error('Well, something went wrong: No Enhanced Design Matrix detected');
end

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
SPM.TEDM.hist.Enh = true;

%=== Set Enhanced Design Matrix ===
SPM.Sess.U = [];
SPM.Sess.C.C = SPM.TEDM.Res.xD;
SPM.Sess.C.name = SPM.TEDM.Param.names;

%=== Call SPM parametrization ===
[SPM] = tedm_fMRI_spm_ui(SPM);