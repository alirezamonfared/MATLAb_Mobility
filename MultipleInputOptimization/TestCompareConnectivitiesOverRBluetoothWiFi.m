%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../shared_functions/')

%% Setting up Destination Folder
%% Set Scenario Name and Destination Folder
%ScenarioName = 'CSV4'
%ScenarioName = 'RPGM'
ScenarioName = 'DA'

DestFolder = sprintf('%sPercentilePair', ScenarioName);
if(~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end

%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    InputFile = './Inputs/CSV4Original.one'
    Baseline = {'./CSV4_100/CSV4Original_R_10.one','./CSV4_100/CSV4Original_R_100.one'};
    TwowayFile = './CSV4MultiRanges/CSV4Original_R_10_100.one';
    TitleStr = 'Total Link Erros for Random Waypoint';
elseif(strcmp(ScenarioName,'RPGM'))
    InputFile = './Inputs//RPGMScenario.one'
    Baseline = {'./RPGM100/RPGM_R_10.one', './RPGM100/RPGM_R_100.one'};
    TwowayFile = './RPGMMultiRanges/RPGMScenario_R_10_100.one'
    TitleStr = 'Total Link Erros for RPGM';
elseif(strcmp(ScenarioName,'DA'))
    InputFile = './Inputs/DA.one'
    Baseline = {'./DA/DA_10.one', './DA/DA_100.one'};
    TwowayFile = './DAMultiRanges/DA_10_100.one'
    TitleStr = 'Total Link Erros for Disaster Area Model';
else
    error('Something wrong with DestFolder')
end

[Path Name Ext]=fileparts(InputFile);

%% Setting up the range values
mode = 0;
Range = [0 150];
NormMode = 0;
PlotContent = 0;

Parameters = struct('NormMode',NormMode, 'PlotContent', PlotContent,...
    'DestFolder',DestFolder,'TitleStr',TitleStr ,'AxisClipMode' ,3 );

%Adjustments
if (strcmp(ScenarioName,'DA')|| strcmp(ScenarioName,'RWP'))
    Parameters.LegendLocation = 'NorthEast';
end

Parameters.CustomLegend{1}='Baseline w/ R=10';
Parameters.CustomLegend{2}='Baseline w/ R=100';
Parameters.CustomLegend{3}='Mulit Input w/ R=10,100';
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, InputFile,Baseline{1},...
    Baseline{2},TwowayFile);