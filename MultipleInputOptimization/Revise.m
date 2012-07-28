addpath('../../BGFS_optimization/')
DestFolder = 'MultiRangesBestRPGM';

% InputFile = './Inputs/CSV4Original.one'
InputFile = './Inputs/RPGMScenario.one'
%InputFile = './Inputs/DA.one'

[Path Name Ext]=fileparts(InputFile);
%RMaster = [10 25 50 75 100 120];
RMaster = [14 31 58 86 102 131];
for i1 = 1:length(RMaster)
    for i2 = i1+1:length(RMaster)
        R = [RMaster(i1) RMaster(i2)];
        name1 = sprintf('./%s/%s_R_%d_%d.mat',DestFolder,Name,round(R(1)),round(R(2)));
        [Xreal, XX, Parameters] = LoadResults(name1);
        name = sprintf('./%s/%s_R_%d_%d.one',DestFolder,Name,round(R(1)),round(R(2)));
        ExportToOne(XX, name, Parameters.Box)
    end
end