%--------------------------------------------------------------------------
%|                            tedm_AutoSparsity                           |
%+------------------------------------------------------------------------+
%|   This function set authomatically the sparsity for the free components|
%| given the number of extra sources.                                     |
%|                                                                        |
%|   The automatic selection is based in a sigmoidal model that tries to  |
%| produce an automatic balance bteween sparse and dense sources.         |
%|                                                                        |
%+------------------------------------------------------------------------+
%| M. Morante                                    Last Update: 23 Jul 2019 |                                           
%+------------------------------------------------------------------------+
function [Sp] = tedm_AutoSparsity(K)

	if K < 5  % Low K
		switch K
			case 1
				Sp = 95;

			case 2
				Sp = [95 0];

			case 3 
				Sp = [95 85 0];

			case 4
				Sp = [95 85 10 0];

			otherwise
				K_error
		end
	elseif K<=100

		Sp = SetSparsity(K);

	else
		K_Error;
	end
end


%% ===== Auxiliar functions ============================================ %%
function  [Sp] = SetSparsity(K)

	% Parameters of the sigmoidal model
	a = SetParameter_A(K);
	b = SetParameter_B(K);
    
    % Scale to the number of sources
    b = b*K;

	% Initialization
	Sp = zeros(1,K);

	% Set sparsities
	for k=1:K
		Sp(k) = SigmoidalModel(k,a,b);
	end
end

%--- Sigmiodial Model -----------------------------------------------------
function [Sp] = SigmoidalModel(x,a,b)

	Sp = 100/(1+exp(a*(x-b)))-2;  % <- Basic form
	Sp = 0.5*(Sp+abs(Sp));          % <- Avoid negative parts
	Sp = 5*floor(Sp/5);           % <- Steps function 5 by 5
end

%--- Automatic parametrization of the sigmoidal model ---------------------
function [a] = SetParameter_A(K)

	% Parametrization
	Pa = [5 10 15 20 30 40 50];
	Ca = [2.00 -0.23 0.017 -0.000826666667 2.36e-5 -4.32381e-7 4.62963e-9 ];

	Pb = [100 50 40];
	Cb = [0.075 -0.0021 3.166667e-5];

	if(K<40)
		Ply = 7;
		Nk  = ones(1,Ply);

		for i=2:Ply
			Nk(i) = (K-Pa(i-1))*Nk(i-1);
		end

		% Interpolate parameter
		a = Ca(1);

		for i=2:Ply
			a = a + Ca(i)*Nk(i);
		end

	else
		Ply = 3;
		Nk  = ones(1,Ply);

		for i=2:Ply
			Nk(i) = (K-Pb(i-1))*Nk(i-1);
		end

		% Interpolate parameter
		a = Cb(1);

		for i=2:Ply
			a = a + Cb(i)*Nk(i);
		end
	end
end

function [b] = SetParameter_B(K)

	% Parametrization
	Pa = [5 10 15 20 30 40];
	Ca = [0.6 0.000 -0.0001 6.666667e-6 -2.666667e-7 7.61905e-9];

	Pb = [100 50 40 30];
	Cb = [0.53 0.0006 6.666667e-6 9.52381e-8];

	if(K<30)
		Ply = 6;
		Nk  = ones(1,Ply);

		for i=2:Ply
			Nk(i) = (K-Pa(i-1))*Nk(i-1);
		end

		% Interpolate parameter
		b = Ca(1);

		for i=2:Ply
			b = b + Ca(i)*Nk(i);
		end

	else
		Ply = 4;
		Nk  = ones(1,Ply);

		for i=2:Ply
			Nk(i) = (K-Pb(i-1))*Nk(i-1);
		end

		% Interpolate parameter
		b = Cb(1);

		for i=2:Ply
			b = b + Cb(i)*Nk(i);
		end
    end
end
		

%% --- Error mesage ---------------------------------------------------- %%

function K_Error

	Msg = ['The number of extra free components was not correctly selected! \(u u)_. ' ... 
           'Please, introduce a valid number < K > within the range [1,100].'];
       
    error(Msg);
end
