% Figures for the paper
%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../shared_functions/')

%% Setting up Destination Folder
%% Set Scenario Name and Destination Folder
%ScenarioName = 'CSV4'
ScenarioName = 'RPGM'
%ScenarioName = 'DA'

DestFolder = sprintf('%sPercentilePair', ScenarioName);
if(~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end

%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    InputFile = './Inputs/CSV4Original.one'
    Baseline = {'./CSV4_100/CSV4Original_R_10.one','./CSV4_100/CSV4Original_R_100.one'};
    TwowayFile = './CSV4MultiRanges/CSV4Original_R_10_100.one';

elseif(strcmp(ScenarioName,'RPGM'))
    InputFile = './Inputs//RPGMScenario.one'
    Baseline = {'./RPGM100/RPGM_R_10.one', './RPGM100/RPGM_R_100.one'};
    TwowayFile = './RPGMMultiRanges/RPGMScenario_R_10_100.one'
elseif(strcmp(ScenarioName,'DA'))
    InputFile = './Inputs/DA.one'
    Baseline = {'./DA/DA_10.one', './DA/DA_100.one'};
    TwowayFile = './DAMultiRanges/DA_10_100.one'
else
    error('Something wrong with DestFolder')
end

[Path Name Ext]=fileparts(InputFile);



%% Setting up the range values
mode = 0;
Range = [0 150];
NormMode = 0;
PlotContent = 0;

% Figure 1, Bluetooth 
%TitleStr = sprintf('Total Link Errors for Single Bluetooth Trace')
TitleStr = [];
Parameters = struct('NormMode',NormMode, 'PlotContent', PlotContent,...
    'DestFolder',DestFolder,'TitleStr',TitleStr ,'IgnoreLegend',1,'Range',Range);
Parameters.OutputFilename = sprintf('./%s/%sb1.svg',DestFolder,ScenarioName);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, InputFile,Baseline{1});


% Figure 2, WiFi 
%TitleStr = sprintf('Total Link Errors for Single WiFi Trace');
TitleStr = [];
Parameters.TitleStr = TitleStr;
Parameters.OutputFilename = sprintf('./%s/%sb2.svg',DestFolder,ScenarioName);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, InputFile,Baseline{2});


% Figure 3, BlueTooth + WiFi 
%TitleStr = sprintf('Total Link Errors for Bluetooth + WiFi Trace');
TitleStr = [];
Parameters.TitleStr = TitleStr;
Parameters.OutputFilename = sprintf('./%s/%sbb.svg',DestFolder,ScenarioName);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, InputFile,TwowayFile);