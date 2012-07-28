% Test Journey Sampling Function
addpath('../shared_functions')
addpath('../BGFS_optimization')

SamplingParameters = struct('phi',0.2, 'W', 10,'MaxTries',1000,...
    'R',100,'Mode',3);

InputFile = './Results/CSV4Original.one';
[Path Name Ext]=fileparts(InputFile);
Output = sprintf('./Results/%sJSampled%dphi.one',Name,SamplingParameters.phi*100);

[X, N, d, tm, Box] = Matricize(InputFile);
SamplingParameters.Box = Box;
[SampledX NS] = JourneySampling(X,SamplingParameters);
CGs = MobilityToConatcts(SampledX,100);
ExportToOneLinks(CGs,Output,1);