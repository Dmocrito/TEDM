%+------------------------------------------------------------------------+
%|                          cδ Function                                   |
%+------------------------------------------------------------------------+
%|   This function determines the suitable values for the parameter cδ    |
%| based on the convolutinal model and implementing sevreal HRFs. These   |
%| HRFs was generated using the two-gamma distribution model.             |
%|                                                                        |
%|     IMPORTANT: The current function requires to have SPM installed and |
%| added in the main path of matlab.                                      |
%+------------------------------------------------------------------------+
%|   11 Jan 12019                                                 -mMm-   |
%--------------------------------------------------------------------------
function [cd] = tedm_cdelta_fun(RT,NS,UNITS,R)

	%=== Parameters ====
	xBF.UNITS = UNITS;    % Units of the conditions
	xBF.RT    = RT;       % Repetition time [TR]
	Nscans    = NS;       % Number of Scans

	% Conditions
	names  = R.names;
	onsets = R.onsets;
	durations = R.durations;

	Ncnd = numel(names);

	%=== Default parameters ===
	xBF.T    = 16;     % Microtime resolution
	xBF.T0   = 8;      % Microtime onset
	xBF.name = 'hrf';  % Standard HRF, no derivatives

	%=== Set pHRF parameters ===
	% These parameter was defined according to the study developed in 
	% [1] -> Add Ref later
	%----------------------------
	pHRF{1} = [6;16;1;1;6;0;32];
	pHRF{2} = [6.754660098;14.71323792;0.54320383;0.6972621034;4.2964120;0.932744464;32];

	%-Construct Design matrix [X]
	%==========================================================================

	%-Microtime onset and microtime resolution
	fMRI_T     = xBF.T;
    fMRI_T0    = xBF.T0;

	%-Time units, dt = time bin {secs}
	xBF.dt     = xBF.RT/xBF.T;

	cnt = 1;
	for hp =[1 2]

		%-Create basis functions
		%==========================================================================
   
		% Canonical hemodynamic response function
		[bf,~]      = spm_hrf(xBF.dt,pHRF{hp},fMRI_T);
 
		% Length and order
		xBF.length   = size(bf,1)*xBF.dt;
		xBF.order    = size(bf,2);

		% Orthogonalise and fill in basis function structure
		xBF.bf = spm_orth(bf);

		%-Get session specific design parameters
		%==========================================================================
		Xx    = [];
    
    	k = Nscans;    % Total number of scans
    
    	%-Create convolved stimulus functions or inputs
    	%======================================================================
    	SPM.nscan = Nscans;
    	SPM.xBF = xBF;

   		% Init U
    	for i=1:Ncnd
       		U(i).name = names{i};
    		U(i).ons  = onsets{i};
    		U(i).dur  = durations{i};
    		U(i).orth = true;
    		U(i).P.name = 'none';
    		U(i).P.h    = 0;
    	end
    
    	SPM.Sess(1).U = U;
    
   		%-Get inputs, neuronal causes or stimulus functions U
    	U = spm_get_ons(SPM,1);
    
    	%-Convolve stimulus functions with basis functions
    	[X,~,Fc] = spm_Volterra(U, SPM.xBF.bf, 1);
    
    	%-Resample regressors at acquisition times (32 bin offset)
    	%----------------------------------------------------------------------
    	if ~isempty(X)
    	    X = X((0:(k - 1))*fMRI_T + fMRI_T0 + 32,:);
    	end
    
    	%-Orthogonalise (within trial type)
    	%----------------------------------------------------------------------
    	for i = 1:length(Fc)
        	if i<= numel(U) && ... % for Volterra kernels
            	    (~isfield(U(i),'orth') || U(i).orth)
            	p = ones(size(Fc(i).i));
       		else
            	p = Fc(i).p;
        	end
        	for j = 1:max(p)
            	X(:,Fc(i).i(p==j)) = spm_orth(X(:,Fc(i).i(p==j)));
        	end
    	end

    	% Save
    	CanD{cnt} = X;

    	cnt = cnt+1;
    end


    %- Determine differences between components
	%==========================================================================
	for i = 1:Ncnd
		cd(i) = norm(CanD{1}(:,i)-CanD{2}(:,i))^2;
	end 
end