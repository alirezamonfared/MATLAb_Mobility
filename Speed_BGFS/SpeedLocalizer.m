function  XX = SpeedLocalizer(Xreal, SimPars, XRef);

% Initlizalization 
    R = SimPars.R;
    Vm = SimPars.Vm;
    SimPars.d = size(Xreal,1);
    d =  SimPars.d;
    N = size(Xreal,2);
    InitLoc = SimPars.InitLoc;
    
    tm = size(Xreal,3) - 1;
    XX = zeros(d, N, tm-1);
    
    Xp = Xreal(:,:,1);
    Xreal = Xreal(:,:,2:end);
    
    if nargin < 3
        XRef = [];
    end

%% Function run
    if InitLoc
        disp('Initial Locations are Known')
        for t = 1:tm
            Xc = Xreal(:,:,t);
            CG = DeriveCG(Xc, R);
            if (~isempty(XRef))
                Xref = XRef(:,:,t+1);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SpeedMinimizer(CG, Xp, SimPars, Xref);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end
        
    else
        disp('No Initial Locations Given')
        CG = DeriveCG(Xp, R);
        if (~isempty(XRef))
            Xref = XRef(:,:,1);
            disp('Reference Points Given')
        else
            Xref = [];
            disp('No Reference Points Given')
        end
        Xp = SpeedMinimizerRelaxed(CG, SimPars, Xref);
        for t = 1:tm
            Xc = Xreal(:,:,t);
            CG = DeriveCG(Xc, R);
            if (XRef ~= [])
                Xref = XRef(:,:,t+1);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SpeedMinimizer(CG, Xp, SimPars, Xref);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end
        
    end
    
    
    

end