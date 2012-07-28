% Test feedbackOptimizationWrapper
clc
clear all
InputFile = './Inputs/CSV4Original.one'

RVector = [50 100 150];
Parameters = struct('RVector',RVector,'Vm',10, 'InitLoc', false,'Weighted',true,...
    'Box',1000, 'RefineX',false,'MaxIter',300,'Epsilon',0,'IsMobility',1 ,...
    'MainInputIndex',2,'depth',3,'DestFolder','ResultsDeep');
 
tic;
Xinf = FeedbackOptimizationWrapper(InputFile, Parameters);
ExecTime = toc;