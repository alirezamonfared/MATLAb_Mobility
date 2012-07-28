% UsingJavaExample2
% This example uses a given 2D array that descibes the evolving graph to
% load it

clear all
addpath('../shared_functions/')
javaaddpath('/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EvolvingGraphs/bin');


InputFile = '../Sampling/Results/CSV4Original.one';
[Path Name Ext]=fileparts(InputFile);

[X, N, d, tm, Box] = Matricize(InputFile);
N 
tm
CGs = MobilityToConatcts(X,100);
S = ExportToOneLinksString(CGs);

reporter = javaObject('br.usp.ime.graphreport.TestReportsAlireza');

% nRows = size(S,1);
% nCols = 4;
% SJ = javaArray('java.lang.Integer', nRows, nCols);
% 
% for i = 1:nRows
%     for j = 1:nCols
%         SJ(i,j) = java.lang.Integer(S(i,j));
%     end
% end

Res = javaMethod('TestJourneyUnreachableReportString',reporter, S, N+1, tm);
