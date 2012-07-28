%Test MeltX
clear all
clc

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/')
addpath('/home/alireza/Applications/MATLAB_Optimization/minConf/')
addpath('/home/alireza/Applications/MATLAB_Optimization/minConf/minConf/')
addpath('/home/alireza/Applications/MATLAB_Optimization/minConf/minFunc/')
%N = 3;
%d = 2;
%CG = [0 1 0;1 0 0;0 0 0];
%Xp = [1 1 2 ; 1 2 2];

% Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false,'Weighted',true,...
%     'Box',100, 'RefineX',true);
Parameters = struct('R',100,'Vm',10, 'InitLoc', false,'Weighted',true,...
    'Box',1000, 'RefineX',false,'MaxIter',300);

R = Parameters.R;
Vm = Parameters.Vm;
N = 50;
d = 2;
tm = 100;
InputFile = '../BGFS_optimization/Inputs/CSV3.csv'
%X = UnconstrainedLocalizer(CG, Xp, R, Vm, d);
[Xreal M] = Matricize(InputFile, N, d, tm+1);
Parameters.InputFile = InputFile;
%Xreal = zeros(2,3,2);
%Xreal(:,:,1) = [0 3 20; 0 5 20];
%Xreal(:,:,2) = [0 3 20; 0 5 20];


%% Complete Test
NRef = 0;
if (NRef ~= 0)
    XRef = Xreal(:,1:NRef,:);
else
    XRef = [];
end
XX = SpeedLocalizer(Xreal, Parameters,XRef);
[dim N tm] = size(XX);
Parameters.Date = datestr(now);
Parameters.dim = dim;
Parameters.N = N;
Parameters.tm = tm;
Parameters.NRef = NRef;

%% One-step test
% Xr = Xreal(:,:,2);
% Xp = Xreal(:,:,1);
% CG = DeriveCG(Xr,R);
%Xo = SDPMinimizerRelaxed(CG,Parameters);
%Xo = SDPMinimizerGlobal(CG,Xp, Parameters);
% Xo = SDPSolverGGPLAB(CG,Xp, Parameters);
%[Xo TR]= Refinement(Xo,Xp,Parameters);
% [Violations InRangeViolation OutofRangeViolation...
%      SpeedViolation] = ValidilityCheck(Xo, Xp, CG, R, Vm);

% plots for one-step
% figure;
% hold on
% scatter(Xo(1,:),Xo(2,:),'r','o')
% scatter(Xr(1,:),Xr(2,:),'b','+')
% title('Sample Iteration for Fmincon()')
% legend('Inferred Location','Real Location')
% hold off

%% Saving Module
Res{1} = Xreal;
Res{2} = XX;
Res{3} = Parameters;
clk = clock;
name = sprintf('./Results/ResultBig%d%d%d.mat',clk(1),clk(2),clk(3));
save(name,'Res');

