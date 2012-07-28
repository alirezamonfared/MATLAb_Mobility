% test Histogram Percentiles vs Gaussian Percentiles



%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../BGFS_optimization/')
addpath('../BGFS_optimization/fminlbfgs_version2c')
addpath('../shared_functions/')

%% Set Scenario Name and Destination Folder
%ScenarioName = 'CSV4'
%ScenarioName = 'RPGM'
ScenarioName = 'DA'


DestFolder = sprintf('%sPercentilePair', ScenarioName);
SDestFolder = sprintf('%sSynthPtile', ScenarioName);

%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    InputFile = './Inputs/CSV4Original.one'
    RValues = {[34,146],[27,123],[38,112]};
    Percenties = [5 5 10];
    TitleStr = 'Total Link Erros for Random Waypoint';
elseif (strcmp(ScenarioName,'RPGM'))
    InputFile = './Inputs/RPGMScenario.one'
    RValues = {[0,150],[0,150],[0,150]};
    Percenties = [0 0 0];
    TitleStr = 'Total Link Erros for RPGM';
elseif (strcmp(ScenarioName,'DA'))
    InputFile = './Inputs/DA.one'
    RValues = {[43,68],[64,86],[60,90]};
    Percenties = [35 35 30];
    TitleStr = 'Total Link Erros for Disaster Area Model';
else
    error('Invalid Scenario Name')
end

[Path Name Ext]=fileparts(InputFile);

%% Setting up the range values
mode = 0;
Range = [0 150];
NormMode = 0;
PlotContent = 0;

 %% Main run
Parameters = struct('NormMode',NormMode,'SpecialVarargin',1, 'PlotContent',...
    PlotContent,'DestFolder','GaussianComp','TitleStr',TitleStr);
Inputs = cell(1,length(Percenties)+1);
Inputs{1} = InputFile;
Parameters.CustomLegend = cell(1,length(Percenties));

i = 1;
for i1 = Percenties
    if (i==1)
        Parameters.CustomLegend{i} = sprintf('Best Case Histogram Percentile %d',i1);
    elseif (i==2)
        Parameters.CustomLegend{i} = sprintf('Corresponding from Gaussian');
    elseif (i == 3)
        Parameters.CustomLegend{i} = sprintf('Best case Gaussian Percentile %d',i1);
    else
        continue
    end
    Rs=RValues{i};
    if (i == 1)
        Folder = DestFolder;
    else 
        Folder = SDestFolder;
    end
    name = sprintf('./%s/%s_R_%d_%d_P_%d.one',Folder,Name,round(Rs(1)),round(Rs(2)),i1)
    Inputs{i+1} = name;
    i = i + 1;
end
%RVector=horzcat(1:19,20:5:150);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, Inputs);
        