function  XX = LinkLocalizer(CGs, SimPars, XRef);
addpath('../BGFS_optimization/')
%% Initlizalization 
    R = SimPars.R;
    Vm = SimPars.Vm;
    SimPars.d = 2;
    d =  SimPars.d;
    N = size(CGs,1);
    InitLoc = SimPars.InitLoc;
    
    tm = size(CGs,3);
    XX = zeros(d, N, tm-1);
    
    if nargin < 3
        XRef = [];
    end
%% Function run
    % If initial locations are known, they should be given
    % as a member of SimPars
    if InitLoc
        disp('Initial Locations are Known')
        Xp = SimPars.InitLoc; 
        for t = 1:tm            
            CG = CGs(:,:,t);
            if (~isempty(XRef))
                Xref = XRef(:,:,t+1);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SDPMinimizer(CG, Xp, SimPars, Xref);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end    
    else
        disp('No Initial Locations Given')
        CG = CGs(:,:,1);
        if (~isempty(XRef))
            Xref = XRef(:,:,1);
            disp('Reference Points Given')
        else
            Xref = [];
            disp('No Reference Points Given')
        end
        Xp = SDPMinimizerRelaxed(CG, SimPars, Xref);
        XX(:,:,1) = Xp;
        for t = 2:tm
            CG = CGs(:,:,t);
            if (XRef ~= [])
                Xref = XRef(:,:,t+1);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SDPMinimizer(CG, Xp, SimPars, Xref);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end
        
    end
end