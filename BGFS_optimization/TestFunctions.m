% Initializations
clear all
clc

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')

%N = 3;
%d = 2;
%CG = [0 1 0;1 0 0;0 0 0];
%Xp = [1 1 2 ; 1 2 2];

% Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false,'Weighted',true,...
%     'Box',100, 'RefineX',true);


InputFile = './Inputs/CSV4Original.one'
[Path Name Ext]=fileparts(InputFile);
[Xreal, N, d, tm, Box] = Matricize(InputFile);


% Set Simulation Parameter
% CSV4
Parameters = struct('R',100,'Vm',100, 'InitLoc', false,'Weighted',true,...
     'Box',100, 'RefineX',false,'MaxIter',300,'Epsilon',0.5);

% Message ferry
%Parameters = struct('R',3,'Vm',6, 'InitLoc', false,'Weighted',true,...
%    'Box',100, 'RefineX',false,'MaxIter',300);

if (~isnan(Box))
    Parameters.Box = Box;
end

% Get R, Vm for insider calls, as well as other parameters to save
R = Parameters.R;
Vm = Parameters.Vm;
Parameters.Date = datestr(now);
Parameters.dim = d;
Parameters.N = N;
Parameters.tm = tm;
% Save input file name
Parameters.InputFile = InputFile;

%X = UnconstrainedLocalizer(CG, Xp, R, Vm, d);


%Xreal = zeros(2,3,2);
%Xreal(:,:,1) = [0 3 20; 0 5 20];
%Xreal(:,:,2) = [0 3 20; 0 5 20];


%% Reference Points
% Use reference points, if any
NRef = 0;
if (NRef ~= 0)
    XRef = Xreal(:,1:NRef,:);
else
    XRef = [];
end

Parameters.NRef = NRef;

%% Main Function call
% Call the main localizer
XX = Localizer(Xreal, Parameters,XRef);

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
name = sprintf('./Results/%s%d%d%d.mat',Name,clk(1),clk(2),clk(3));
save(name,'Res');

%% Export to ONE format
name = sprintf('./Results/%s%d%d%d.one',Name,clk(1),clk(2),clk(3));
ExportToOne(XX, name, Parameters.Box)
