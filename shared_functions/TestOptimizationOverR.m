 
% Initializations
clear all
clc

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')
clk = clock;

%N = 3;
%d = 2;
%CG = [0 1 0;1 0 0;0 0 0];
%Xp = [1 1 2 ; 1 2 2];

% Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false,'Weighted',true,...
%     'Box',100, 'RefineX',true);

InputFile = '../BGFS_optimization/Inputs/RPGMScenario.one'
[Path Name Ext]=fileparts(InputFile);
[Xreal, N, d, tm, Box] = Matricize(InputFile);

% Test Value for R
RVector=horzcat(5:10:95,100,105:10:150,200:50:600);

for Rvalue = RVector
    clear XX Res Parameters name
    % Set Simulation Parameter
    % CSV4
    Parameters = struct('R',Rvalue,'Vm',10, 'InitLoc', false,'Weighted',true,...
        'Box',100, 'RefineX',false,'MaxIter',300,'Epsilon',0.0);
    
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
    
    %% Saving Module
    Res{1} = Xreal;
    Res{2} = XX;
    Res{3} = Parameters;
    name = sprintf('./Results2/%s%d%d%d.mat',Name,Rvalue,clk(2),clk(3));
    save(name,'Res');
    
    %% Export to ONE format
    name = sprintf('./Results2/%s%d%d%d.one',Name,Rvalue,clk(2),clk(3));
    ExportToOne(XX, name, Parameters.Box)
end
