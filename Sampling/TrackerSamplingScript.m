function  TrackerSamplingScript(InputFile,SamplingParameters);
% Test Tracker Sampling in a Function with variable input
addpath('../shared_functions')
addpath('../BGFS_optimization')

if (nargin < 2)
    SamplingParameters = struct('Box',1000,'phi',0.2, 'W', 3,'MaxWindows',1000);
end

[Path Name Ext]=fileparts(InputFile);
Output = sprintf('./Results/%sSampled%dphi.one',Name,SamplingParameters.phi*100);

[X, N, d, tm, Box] = Matricize(InputFile);
SamplingParameters.Box = Box;
[SampledX NS] = TrackerSampling(X,SamplingParameters);
CGs = MobilityToConatcts(SampledX,100);
ExportToOneLinks(CGs,Output,1);

end