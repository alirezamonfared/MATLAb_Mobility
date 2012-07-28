% Script to plot sample color mapped histogram
filename = '/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EvolvingGraphs/reports/CSV4Results.txt';
Data = dlmread(filename,' ');

N = length(unique(Data(:,2)));
TMax = length(unique(Data(:,1)));

EADMatrix = zeros(N*(N-1),TMax);
MHCMatrix = zeros(N*(N-1),TMax);

NN = size(Data,1);

PreviousTime = -1;
NodepairIndex = 1;
for i = 1:NN
    Time = Data(i,1) + 1;
    if (Time == PreviousTime)
        NodepairIndex = NodepairIndex + 1;
    else
        NodepairIndex = 1;
    end
    EADMatrix(NodepairIndex,Time) = Data(i,4);
    MHCMatrix(NodepairIndex,Time) = Data(i,5);
    PreviousTime = Time;
end

EADMax = max(max(EADMatrix));
MHCMax = max(max(MHCMatrix));

[EADHist,EADBins] = hist(EADMatrix,EADMax+1);
[MHCHist,MHCBins] = hist(MHCMatrix,MHCMax+1);

%h = figure('visible','off');
%bar3(EADMatrix,'detached');
%print(h,'-depsc','-tiff','-r300','picture1');

hold on
for i = 1:size(EADMatrix,1)
    for j = 1:size(EADMatrix,2)
       scatter(i,j,5,EADMatrix(i,j)) ;
    end
end
hold off