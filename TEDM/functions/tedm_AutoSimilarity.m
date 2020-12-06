%+------------------------------------------------------------------------+
%|                         Automatic Similarity                           |
%+------------------------------------------------------------------------+
%|   This function determines the suitable values for the parameter cδ    |
%| based on the convolutinal model for the different selected models.     |
%|                                                                        |
%+------------------------------------------------------------------------+
%|   27 Jul 12019                                                 -mMm-   |
%--------------------------------------------------------------------------
function [cdl] = tedm_AutoSimilarity(SPM,ss)

	%=== Determines the variation per regressor===
	% Check Session
	if(nargin==1)
		ss = 1;
	end

	%--- Parameters ---
	RT = SPM.xY.RT;
	NS = SPM.nscan(ss);
	UNITS = SPM.xBF.UNITS;
	K = SPM.TEDM.Param(ss).NSrc_A;

	

	% Remove constant atom (if it exists)
    if(~isempty(SPM.xX.iB))
  		K = K-1;
    end

	for i = 1:K
		R.names{i}     = SPM.Sess(ss).U(i).name;
		R.onsets{i}    = SPM.Sess(ss).U(i).ons;
		R.durations{i} = SPM.Sess(ss).U(i).dur;
	end

	%--- Determine the variation per regressor ---
	[cd_all] = tedm_cdelta_fun(RT,NS,UNITS,R);

	%=== Apply Similarity mode ==?
	switch SPM.TEDM.Param(ss).SimMode
		case 'Conservative'
			cdl = min(cd_all);

		case 'Average'
			cdl = mean(cd_all);

		case 'Relaxed'
			cdl = max(cd_all);

		otherwise
			error('Ups! Something wentn wrong with the similarity mode \(u u )\n' );
	end

end