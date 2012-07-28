function CompareOptimizationInferredConnectivityOverR(OriginalONEile,InferredONEFolder,RVector,Pattern);

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/shared_functions/plot2svg_20101128/')

if nargin < 4
    Pattern = 21;
end


[Path Name Ext]=fileparts(OriginalONEile);

[Xreal, N, d, tm, Box] = Matricize(OriginalONEile);


% Reserving containers
L = length(RVector);
ExtraLinkValues = zeros(L,1);
ExtraLinkErrors = zeros(L,1);
MissingLinkValues = zeros(L,1);
MissingLinkErrors = zeros(L,1);
TotalLinkValues = zeros(L,1);
TotalLinkErrors = zeros(L,1);

i = 1;
for R = RVector
    name = sprintf('./%s/%s%d%d.one',InferredONEFolder,Name,R,Pattern);
    [Xinferred, N, d, tm, Box] = Matricize(name);
    ExtraLinks = zeros(tm,1);
    MissingLinks = zeros(tm,1);
    LinkErrors = zeros(tm,1);
    for t = 1:tm
        CGReal = DeriveCG(Xreal(:,:,t),R);
        CGInferred = DeriveCG(Xinferred(:,:,t),R);
        CGDiff = CGInferred - CGReal;
        NormValue =  size(find(CGReal == 1),1);
        if (NormValue == 0)
            NormValue = 1;
        end
        ExtraLinks(t) =  size(find(CGDiff == 1),1) / NormValue;
        MissingLinks(t) = size(find(CGDiff == -1),1) / NormValue;
        LinkErrors(t) = ExtraLinks(t) + MissingLinks(t);
    end
    
    %ExtraLinks = ExtraLinks / (N*(N-1)/2);
    %MissingLinks = MissingLinks / (N*(N-1)/2);
    %LinkErrors = LinkErrors / (N*(N-1)/2);
    
    ExtraLinkValues(i) = mean(ExtraLinks);
    ExtraLinkErrors(i) = std(ExtraLinks);
    MissingLinkValues(i) = mean(MissingLinks);
    MissingLinkErrors(i) = std(MissingLinks);
    TotalLinkValues(i) = mean(LinkErrors);
    TotalLinkErrors(i) = std(LinkErrors);
    
    i = i + 1;   
end

Indices = 1:2:L;
figure(1);
errorbar(1:L,ExtraLinkValues,ExtraLinkErrors,'xr')
title('Extra Link Errors vs Transmission Range')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
xlabel('Transmission Range')
ylabel('Error in %')
filename = sprintf('./Results/%sExtraErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(2);
errorbar(1:L,MissingLinkValues,MissingLinkErrors,'xr')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Missing Link Errors vs Transmission Range')
xlabel('Transmission Range')
ylabel('Error in %')
filename = sprintf('./Results/%sMissingErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(3);
errorbar(1:L,TotalLinkValues,TotalLinkErrors,'xr')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Total Link Errors vs Transmission Range')
xlabel('Transmission Range')
ylabel('Error in %')
filename = sprintf('./Results/%sTotalErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


