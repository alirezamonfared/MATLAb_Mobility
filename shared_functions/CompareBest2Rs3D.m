%function CompareBest2Rs3D(RealInputFile, RMaster, RVector, BaseLineFile, DestFolder);
function CompareBest2Rs3D(RealInputFile, RMaster, RVector, BaseLineFile, DestFolder);
%% Help
% RealInputFile == name of the ONE file containing the input mobility
% ScenarioName == base name for the output mobilities
% RMaster == set of Rvalues , the best 2 Rs are chosen from
% RVector == range of interest to plot over
% MainR == value of R corresponding to the RealInputFile
%% Adding paths
addpath('../shared_functions/')
addpath('../shared_functions/plot2svg_20101128/')
%% Initializations
if (nargin < 5)
    DestFolder = 'Results';
end

if (nargin < 4)
    BaseLineFile = [];
end

NPlots = nchoosek(length(RMaster),2); 

if (~isempty(BaseLineFile))
    NPlots = NPlots + 1;
end

X = cell(1,NPlots);
L = length(RVector);

TotalLinkValues = zeros(NPlots,L);

ExtraLinks = cell(1,NPlots);
MissingLinks = cell(1,NPlots);
LinkErrors = cell(1,NPlots);

LengendData = cell(1,NPlots);

CG =  cell(1,NPlots);
CGDiff =  cell(1,NPlots);

%% Opening File Contaning Input Mobility
[Path Name Ext]=fileparts(RealInputFile);
[Xreal, N, d, tm, Box] = Matricize(RealInputFile);

%% Creating the matrix of Error Values
i = 1;
for i1 = 1:length(RMaster)
    for i2 = i1+1:length(RMaster)
        Rs = [RMaster(i1) RMaster(i2)]
        filename = sprintf('./%s/%s_R_%d_%d.one',DestFolder,Name,round(Rs(1)),round(Rs(2)));
        [X{i}, N, d, tm, Box] = Matricize(filename);        
        j = 1;
        for R = RVector
            ExtraLinks{i} = zeros(tm,1);
            MissingLinks{i} = zeros(tm,1);
            LinkErrors{i} = zeros(tm,1);
            
            for t = 1:tm
                CG{i} = DeriveCG(X{i}(:,:,t),R);
                CGReal = DeriveCG(Xreal(:,:,t),R);
                CGDiff{i} = CG{i} - CGReal;
                NormValue =  size(find(CGReal == 1),1);
                if (NormValue == 0)
                    NormValue = 1;
                end
                ExtraLinks{i}(t) =  size(find(CGDiff{i} == 1),1) / NormValue;
                MissingLinks{i}(t) = size(find(CGDiff{i} == -1),1) / NormValue;
                LinkErrors{i}(t) = ExtraLinks{i}(t) + MissingLinks{i}(t);
                
            end
            TotalLinkValues(i,j) = mean(LinkErrors{i});         
            j = j + 1;
        end
        LengendData{i} = sprintf('R1=%d, R2=%d', round(Rs(1)),round(Rs(2))); 
        i = i + 1;
    end
end

if (~isempty(BaseLineFile))
    [X{NPlots}, N, d, tm, Box] = Matricize(BaseLineFile);
    j = 1;
    for R = RVector
        ExtraLinks{NPlots} = zeros(tm,1);
        MissingLinks{NPlots} = zeros(tm,1);
        LinkErrors{NPlots} = zeros(tm,1);
        
        for t = 1:tm
            CG{NPlots} = DeriveCG(X{NPlots}(:,:,t),R);
            CGReal = DeriveCG(Xreal(:,:,t),R);
            CGDiff{NPlots} = CG{NPlots} - CGReal;
            NormValue =  size(find(CGReal == 1),1);
            if (NormValue == 0)
                NormValue = 1;
            end
            ExtraLinks{NPlots}(t) =  size(find(CGDiff{NPlots} == 1),1) / NormValue;
            MissingLinks{NPlots}(t) = size(find(CGDiff{NPlots} == -1),1) / NormValue;
            LinkErrors{NPlots}(t) = ExtraLinks{NPlots}(t) + MissingLinks{NPlots}(t);           
        end
        TotalLinkValues(NPlots,j) = mean(LinkErrors{NPlots});
        j = j + 1;
    end
    LengendData{NPlots} = 'Baseline';
    disp('Baseline')
end


%% Creating 3D Plots
YVec = 1:NPlots;
XVec = repmat(1:L,NPlots,1);
ZVec = TotalLinkValues;
options.LegendText = LengendData;
area3(XVec,YVec,ZVec,options);
Indices = 1:round((L/10)):L;
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
set(gca,'YTickLabel',[])
xlabel('Test Transmission Ranges')
zlabel('Total Link Errors')
TitleStr = sprintf('Comparison of Best 2 Transmission Range Values for %s',Name);
title(TitleStr)

%% Save to svg
 filename = sprintf('./Results/%s3DErrorsN%dT%d.svg',Name,N,tm);
 plot2svg(filename);
 
 %% Superimposed Plots
 cmap = hsv(NPlots);
 Indices = 1:round((L/10)):L;
 figure;
 hold on
 for k = 1:NPlots
     plot(1:L,TotalLinkValues(k,:),'-+','Color',cmap(k,:));
     set(gca,'XTick',Indices)
     set(gca,'XTickLabel',RVector(Indices))
     xlabel('Transmission Range')
     ylabel('Error in %')
 end
hold off
TitleStr = sprintf('Comparison of Best 2 Transmission Range Values for %s',Name);
title(TitleStr)
legend(LengendData)
%% Save to svg
 filename = sprintf('./Results/%s3DErrors2N%dT%d.svg',Name,N,tm);
 plot2svg(filename);
end
