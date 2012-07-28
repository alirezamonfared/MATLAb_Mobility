% Test Multiple Inputs with combination of transformation and real inputs
% Initializations
clear all
clc

addpath('../BGFS_optimization/')
addpath('../BGFS_optimization/fminlbfgs_version2c')

% Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false,'Weighted',true,...
%     'Box',100, 'RefineX',true);


InputFile = './Inputs/CSV4Original.one'
InferredFile='../shared_functions/Results/CSV4OriginalBase10021.one'

OtherRs = [50 150];
MainR = 100;
Rs = [OtherRs MainR];
[Path Name Ext]=fileparts(InputFile);
[Xreal, N, d, tm, Box] = Matricize(InputFile);
[Xinf, N, d, tm, Box] = Matricize(InferredFile);


% Set Simulation Parameter
% CSV4
Parameters = struct('R',Rs,'Vm',10, 'InitLoc', false,'Weighted',true,...
     'Box',1000, 'RefineX',false,'MaxIter',300,'Epsilon',0,...
     'Transformation',1,'MainInputIndex',3);

% Message ferry
%Parameters = struct('R',3,'Vm',6, 'InitLoc', false,'Weighted',true,...
%    'Box',100, 'RefineX',false,'MaxIter',300);

if (~isnan(Box))
    Parameters.Box = Box;
end

% Get R, Vm for insider calls, as well as other parameters to save
NInputs = length(Rs);
R = Parameters.R;
Vm = Parameters.Vm;
Parameters.Date = datestr(now);
Parameters.dim = d;
Parameters.N = N;
Parameters.tm = tm;
% Save input file name
Parameters.InputFile = InputFile;


%% Reference Points
% Use reference points, if any
NRef = 0;
if (NRef ~= 0)
    XRef = Xreal(:,1:NRef,:);
else
    XRef = [];
end

Parameters.NRef = NRef;

CGs = zeros(N,N,NInputs,tm);
% First NInputs -1 inputs come from Xinf (output of previous step) with
% given value of R
for it = 1:NInputs-1
    for t=1:tm
        CGs(:,:,it,t) = DeriveCG(Xinf(:,:,t),Rs(it));
    end
end
% Last input is the origianl contact trace given as input
for t = 1:tm
    CGs(:,:,NInputs,t) = DeriveCG(Xreal(:,:,t),Rs(NInputs));
end
CheckCGsValidity(CGs,Rs);
%% Main Function call
% Call the main localizer
%XX = LinkLocalizerMultiInput(CGs, Parameters,XRef);

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
name = sprintf('./ResultsNew/%s%d%d%d.mat',Name,clk(1),clk(2),clk(3));
save(name,'Res');

%% Export to ONE format
name = sprintf('./ResultsNew/%s%d%d%d.one',Name,clk(1),clk(2),clk(3));
ExportToOne(XX, name, Parameters.Box)