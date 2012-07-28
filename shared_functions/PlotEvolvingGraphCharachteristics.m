function PlotEvolvingGraphCharachteristics(ONEile,R);


if ~exist('R') || isempty(R), R=100; end
[Xreal, N, d, tm, Box] = Matricize(ONEile);


Degrees = zeros(tm,1);
DegreesSD = zeros(tm,1);
ClusteringCoeffs = zeros(tm,1);
ClusteringCoeffsSD = zeros(tm,1);

DegreeTemp = zeros(N,1);
ClusteringTemp = zeros(N,1);

for t = 1:tm
    CGReal = DeriveCG(Xreal(:,:,t),R);
    
    DegreeTemp = sum(CGReal,2);
    ClusteringTemp = clustercoeffs(CGReal);
    
    Degrees(t) = mean(DegreeTemp); 
    DegreesSD(t) = std(DegreeTemp);
    ClusteringCoeffs(t) = mean(ClusteringTemp);
    ClusteringCoeffsSD(t) = std(ClusteringTemp);    
end

Indices = 1:100:tm;
figure(1);
%errorbar(1:tm,Degrees,DegreesSD,'xr')
plot(1:tm,Degrees,'r')
title('Evolution of Degrees over Time in the Contact Trace')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',Indices)
xlabel('Time')
ylabel('Average Degree')
filename = './Results/DegreePlot.svg';
plot2svg(filename);

Indices = 1:100:tm;
figure(2);
%errorbar(1:tm,ClusteringCoeffs,ClusteringCoeffsSD,'xr')
plot(1:tm,ClusteringCoeffs,'r')
title('Evolution of Clustering Coefficients over Time in the Contact Trace')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',Indices)
xlabel('Time')
ylabel('Clustering Coefficient')
filename = './Results/ClusteringPlot.svg';
plot2svg(filename);
