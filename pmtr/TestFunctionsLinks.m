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


InputFile = './Inputs/pmtr_links.one'
[Path Name Ext]=fileparts(InputFile);
[CGs TSeq] = ImportPMTR(InputFile);


% Set Simulation Parameter
Parameters = struct('R',20,'Vm',10, 'InitLoc', false,'Weighted',true,...
    'Box',500, 'RefineX',false,'MaxIter',300);


% Get R, Vm for insider calls, as well as other parameters to save
R = Parameters.R;
Vm = Parameters.Vm;
Parameters.Date = datestr(now);
Parameters.dim = 2;
Parameters.N = size(CGs,1);
Parameters.tm = size(CGs,3);
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
XX = LinkLocalizer(CGs, Parameters,XRef);

%% Saving Module
Res{1} = [];
Res{2} = XX;
Res{3} = Parameters;
clk = clock;
name = sprintf('./Results/%s%d%d%d.mat',Name,clk(1),clk(2),clk(3));
save(name,'Res');

%% Export to ONE format
name = sprintf('./Results/%s%d%d%d.one',Name,clk(1),clk(2),clk(3));
ExportToOne(XX, name, Parameters.Box)