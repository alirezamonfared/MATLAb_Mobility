% Test feedbackOptimizationWrapper
clc
clear all
addpath('../MultipleInputOptimization/')
InputFile = './Inputs/pmtr_links.one'

RVector = [10];
Parameters = struct('RVector',RVector,'Vm',1, 'InitLoc', false,'Weighted',true,...
    'Box',200, 'RefineX',false,'MaxIter',300,'Epsilon',0,'IsMobility',2 ,...
    'MainInputIndex',1,'DestFolder','PMTRMultiInput');
 tic;
 Xinf = FeedbackOptimizationWrapper(InputFile, Parameters);
 ExecTime = toc;
 
