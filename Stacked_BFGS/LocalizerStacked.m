function  XX = LocalizerStacked(Xreal, SimPars, XRef);

% Initlizalization 
    R = SimPars.R;
    Vm = SimPars.Vm;
    TW = SimPars.TW;
    SimPars.d = size(Xreal,1);
    d =  SimPars.d;
    N = size(Xreal,2);
    InitLoc = SimPars.InitLoc;
    
    tm = size(Xreal,3) - 1;
    XX = zeros(d, N, tm);
    
    Xp = Xreal(:,:,1);
    Xreal = Xreal(:,:,2:end);
    
    if nargin < 3
        XRef = [];
    end

%% Function run
    t = 1
    if InitLoc
        disp('Initial Locations are Known')
        while (t+TW-1 <= tm)
            Xc = Xreal(:,:,t:t+TW-1);
            for W = 1 : TW
                CG(:,:,W) = DeriveCG(Xc(:,:,W), R);
            end
            if (~isempty(XRef))
                Xref = XRef(:,:,t+1:t+TW);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SDPMinimizerStacked(CG, Xp, SimPars, Xref);
            Xp = Xinf(:,:,end);
            size(Xinf)
            XX(:,:,t:t+TW-1) = Xinf;
            t
            t = t + TW;
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
        Xp = SDPMinimizerRelaxed(CG, SimPars, Xref);
        while (t+TW-1 <= tm)
            Xc = Xreal(:,:,t:t+TW-1);
            for W = 1 : TW
                CG(:,:,W) = DeriveCG(Xc(:,:,W), R);
            end
            if (~isempty(XRef))
                Xref = XRef(:,:,t+1:t+TW);
                disp('Reference Points Given')
            else
                Xref = [];
                disp('No Reference Points Given')
            end
            Xinf = SDPMinimizerStacked(CG, Xp, SimPars, Xref);
            Xp = Xinf(:,:,end);
            XX(:,:,t:t+TW-1) = Xinf;
            t
            t = t + TW;
        end        
    end
end