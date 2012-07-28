% Initializations
clear all
clc

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')

clk = clock;

InputFile = './Inputs/pmtr_links.one'
[Path Name Ext]=fileparts(InputFile);
[CGs TSeq] = ImportPMTR(InputFile);

% Test Value for R
RVector=horzcat(5:2:30,30:10:100,200:50:600);


for Rvalue = RVector
    clear XX Res Parameters name
    % Set Simulation Parameter
    % CSV4
    Parameters = struct('R',Rvalue,'Vm',10, 'InitLoc', false,'Weighted',true,...
        'Box',100, 'RefineX',false,'MaxIter',300,'Epsilon',0.0);
    
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
    name = sprintf('./Results/%s%d%d%d.mat',Name,Rvalue,clk(2),clk(3));
    save(name,'Res');
    
    %% Export to ONE format
    name = sprintf('./Results/%s%d%d%d.one',Name,Rvalue,clk(2),clk(3));
    ExportToOne(XX, name, Parameters.Box)
    
end