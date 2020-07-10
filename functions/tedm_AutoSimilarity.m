%+------------------------------------------------------------------------+
%|                         Automatic Similarity                           |
%+------------------------------------------------------------------------+
%|   This function determines the suitable values for the parameter cδ    |
%| based on the convolutinal model for the different selected models.     |
%|                                                                        |
%+------------------------------------------------------------------------+
%|   27 Jul 12019                                                 -mMm-   |
%--------------------------------------------------------------------------
function [cdl] = tedm_AutoSimilarity(SPM)

	%=== Determines the variation per regressor===
	%--- Parameters ---
	RT = SPM.xY.RT;
	NS = SPM.nscan;
	UNITS = SPM.xBF.UNITS;
	K = SPM.TEDM.Param.NSrc_A;

	% Remove constant atom (if it exists)
    if(~isempty(SPM.xX.iB))
  		K = K-1;
    end

	for i = 1:K
		R.names{i}     = SPM.Sess.U(i).name;
		R.onsets{i}    = SPM.Sess.U(i).ons;
		R.durations{i} = SPM.Sess.U(i).dur;
	end

	%--- Determine the variation per regressor ---
	[cd_all] = tedm_cdelta_fun(RT,NS,UNITS,R);

	%=== Apply Similarity mode ==?
	switch SPM.TEDM.Param.SimMode
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