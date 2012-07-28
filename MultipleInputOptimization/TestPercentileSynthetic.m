% Test Percentile Approach

%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../BGFS_optimization/')
addpath('../BGFS_optimization/fminlbfgs_version2c')
addpath('../shared_functions/')

%% Setting up Destination Folder
DestFolder = 'CSV4SynthPtile';
if(~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end

%% Setting up the input file
 InputFile = './Inputs/CSV4Original.one'
% InputFile = './Inputs//RPGMScenario.one'
% InputFile = './Inputs/DA.one'


[Path Name Ext]=fileparts(InputFile);
[Xreal, N, d, tm, Box] = Matricize(InputFile);
%% Setting up the rnage values
 mode = 0;
 NBins = 50
 Range = [0 150];

 %% To set normal distribution parameters, we wuld like the 1st and 99th
 %% percentiles to occur at 0 and 150 respectively. We also want the mean
 %% mu=75. Since the corresponding z-score for 1st and 99th percentile is
 %% 2.58, we have 75-sigma*(2.58)=0 or 75+sigma*(2.58)=150 which yields
 %% sigma=29.0698

%% Main run
Percenties = 0:5:50;
mu = mean(Range)
sigma = mu/2.58
X = mu+sigma.*randn(1e6,1);
for i1 = Percenties
        PercentileValues = [i1 100-i1]
        Rs=prctile(X,PercentileValues)
        if (i1 == 0)
            Rs = [1e-6,150];
        end
        % Set Simulation Parameter
        % CSV4
        Parameters = struct('R',Rs,'Vm',10, 'InitLoc', false,'Weighted',true,...
            'Box',1000, 'RefineX',false,'MaxIter',300,'Epsilon',0);        
        %DA
        %Parameters = struct('R',Rs,'Vm',20, 'InitLoc', false,'Weighted',true,...
        %     'Box',350, 'RefineX',false,'MaxIter',300,'Epsilon',0);
        
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
        for it = 1:NInputs
            for t=1:tm
                CGs(:,:,it,t) = DeriveCG(Xreal(:,:,t),Rs(it));
            end
        end
        CheckCGsValidity(CGs,Rs);
        %% Main Function call
        % Call the main localizer
        XX = LinkLocalizerMultiInput(CGs, Parameters,XRef);
        
        %% Export to ONE format
        name = sprintf('./%s/%s_R_%d_%d_P_%d.one',DestFolder,Name,round(R(1)),round(R(2)),i1);
        ExportToOne(XX, name, Parameters.Box)
        %% Saving Module
        Res{1} = Xreal;
        Res{2} = XX;
        Res{3} = Parameters;
        name = sprintf('./%s/%s_R_%d_%d_P_%d.mat',DestFolder,Name,round(R(1)),round(R(2)),i1);
        save(name,'Res');

end
