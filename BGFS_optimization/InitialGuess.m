function  Xo = InitialGuess(CG, SimPars, version);
% Initializations
R = SimPars.R;
Vm = SimPars.Vm;
d = SimPars.d;

dp = d + 4;
N = size(CG,2);

%% Switch-case over version
switch version
    case 1
        disp('V1')
        %Dist = (ones(N)-eye(N)) * Box;
        %Xp = mdscale(Dist, dp)';
        Xp = rand(dp, N) * Box;
        
        Xo = SDPMinimizer(CG, Xp, R, Vm, dp,40);
        Xo = MultiDimensionalScale(Xo, d);
        Xo = SDPMinimizer(CG, Xo, R, Vm, d);
    case 2
        disp('V2')
        Xo = SDPMinimizerRelaxed(CG, SimPars);      
    otherwise
        disp('Wrong Version');
        return
end

end


%Ones Start
% tv =
% 
%     0.2172
% 
% 
% irv =
% 
%     0.2818
% 
% 
% orv =
% 
%     0.1943
% 
% 
% sv =
% 
%      1

%Random Start
% tv =
% 
%     0.1881
% 
% 
% irv =
% 
%     0.3267
% 
% 
% orv =
% 
%     0.1581
% 
% 
% sv =
%
%     1