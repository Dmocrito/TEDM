%--------------------------------------------------------------------------
%|                     function tedm_SinMed                               |
%+------------------------------------------------------------------------+
%|   This program subtracts the mean value of a data matrix Y             |
%|                                                                        |
%|       PARAEMTERS:                                                      |
%|   Y   => double TxN data matrix                                        |
%|                                                                        |
%|   opt => 't' mean subracted by columns                                 |
%|          's' mean subracted by rows   (default)                        |
%|                                                                        |
%|   lam => Damping factor for the subtraction of the mean                |
%|                                                                -mMm-   |
%--------------------------------------------------------------------------
function [dat,ym] = tedm_SinMed(Y,opt,lam)

if(nargin==1) % Setting direction by default
	opt ='s';
	lam = 1;
elseif(nargin==2) % Sett damping lambda factor to 1 by default
	lam = 1;
end      

if(opt=='s')
	ym = mean(Y,2);
	dat = Y-lam*ym*ones(1,size(Y,2));
elseif (opt=='t')
	[aux,yaux] = (SinMed(Y','s',lam));
	dat = aux';
	ym = yaux';
else
	error('Please specify the direction');
end