function  XX = Localizer(Xreal, SimPars);

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

%% Function run
    if InitLoc
        disp('Initial Locations are Known')
        for t = 1:tm
            Xc = Xreal(:,:,t);
            CG = DeriveCG(Xc, R);
            Xinf = Fmincon(CG, Xp, SimPars);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end
        
    else
        disp('No Initial Locations Given')
        addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/');
        addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c/');
        CG = DeriveCG(Xp, R);
        Xp = SDPMinimizerRelaxed(CG, SimPars);
        for t = 1:tm
            Xc = Xreal(:,:,t);
            CG = DeriveCG(Xc, R);
            Xinf = Fmincon(CG, Xp, SimPars);
            Xp = Xinf;
            XX(:,:,t) = Xinf;
            t
        end
        
    end
    
    
    

end