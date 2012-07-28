%Test MeltX
clear all
clc

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')

%N = 3;
%d = 2;
%CG = [0 1 0;1 0 0;0 0 0];
%Xp = [1 1 2 ; 1 2 2];
Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false,'Weighted',true,...
    'Box',100, 'RefineX',true);
R = Parameters.R;
Vm = Parameters.Vm;

%X = UnconstrainedLocalizer(CG, Xp, R, Vm, d);
[Xreal M] = Matricize('CSV2.csv', 100, 2, 51);
%Xreal = zeros(2,3,2);
%Xreal(:,:,1) = [0 3 20; 0 5 20];
%Xreal(:,:,2) = [0 3 20; 0 5 20];

%% Complete Test
% XX = Localizer(Xreal, Parameters);
% [dim N tm] = size(XX);
% Parameters.Date = datestr(now);
% Parameters.dim = dim;
% Parameters.N = N;
% Parameters.tm = tm;

%% One-step test
Xr = Xreal(:,:,2);
Xp = Xreal(:,:,1);
CG = DeriveCG(Xr,R);
%Xo = SDPMinimizerRelaxed(CG,Parameters);
%Xo = SDPMinimizerGlobal(CG,Xp, Parameters);
Xo = SDPSolverGGPLAB(CG,Xp, Parameters);
%[Xo TR]= Refinement(Xo,Xp,Parameters);
[Violations InRangeViolation OutofRangeViolation...
     SpeedViolation] = ValidilityCheck(Xo, Xp, CG, R, Vm);

% plots for one-step
% figure;
% hold on
% scatter(Xo(1,:),Xo(2,:),'r','o')
% scatter(Xr(1,:),Xr(2,:),'b','+')
% title('Sample Iteration for Fmincon()')
% legend('Inferred Location','Real Location')
% hold off

% %% Saving Module
% Res{1} = Xreal;
% Res{2} = XX;
% Res{3} = Parameters;
% clk = clock;
% name = sprintf('ResultBig%d%d%d.mat',clk(1),clk(2),clk(3));
% save(name,'Res');

