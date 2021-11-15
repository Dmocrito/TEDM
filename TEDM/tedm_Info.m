%--------------------------------------------------------------------------
%|                            tedm_Info                                   |
%+------------------------------------------------------------------------+
%|   Function than summarizes the main details regarding the toolbox.     |
%|                                                                        |
%+------------------------------------------------------------------------+
%| M. Morante                                   Last Update: 12 Nov 12021 |                                           
%+------------------------------------------------------------------------+
function Info = tedm_info(varargin)

    if(nargin == 0)
        Action = 'Welcome';
    else
        Action = varargin{1};
    end

    switch Action
    case 'Ver'
        Info = 'vs 2.0.1';

    case 'Author'
        Info = 'M. Morante';
    
    case 'email'
        Info = 'manuelm@es.aau.dk';

    case 'GitRep'
        Info = 'https://github.com/Dmocrito/TEDM';

    case 'Welcome'
        % TEDM Asscii welcome  
        disp(' _____ ____  _____ _____                                     ');
        disp('|_   _|    \|   __|     |                                    ');
        disp('  | | |  |  |   __| | | | Toolbox for Enhanced Design Matrix ');
        disp(['  |_| |____/|_____|_|_|_| ', tedm_Info('Ver'), ' - ', tedm_Info('GitRep')]);
        fprintf('\n');
    end     
end