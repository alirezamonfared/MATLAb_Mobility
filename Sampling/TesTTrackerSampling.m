% Test Tracker Sampling Function
addpath('../shared_functions')
addpath('../BGFS_optimization')

SamplingParameters = struct('Box',1000,'phi',0.2, 'W', 3,'MaxTries',1000);

InputFile = './Results/CSV4Original.one';
[Path Name Ext]=fileparts(InputFile);
Output = sprintf('./Results/%sTrkSampled%dphi.one',Name,SamplingParameters.phi*100);

[X, N, d, tm, Box] = Matricize(InputFile);
SamplingParameters.Box = Box;
[SampledX NS] = TrackerSampling(X,SamplingParameters);
CGs = MobilityToConatcts(SampledX,100);
ExportToOneLinks(CGs,Output,1);