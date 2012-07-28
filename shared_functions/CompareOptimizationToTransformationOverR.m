function CompareOptimizationToTransformationOverR(OriginalONEile,InferredONEFolder,RVector,ChosenR, Pattern);

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/shared_functions/plot2svg_20101128/')

[Path Name Ext]=fileparts(OriginalONEile);

if nargin < 5
    Pattern = 21;
end


[Xreal, N, d, tm, Box] = Matricize(OriginalONEile);
InferredName = sprintf('./%s/%s%d%d.one',InferredONEFolder,Name,ChosenR,Pattern);
[XInferredOriginal, N, d, tm, Box] = Matricize(InferredName);


% Reserving containers
L = length(RVector);
% Optimization Algorithm vs Original
ExtraLinkValues = zeros(L,1);
ExtraLinkErrors = zeros(L,1);
MissingLinkValues = zeros(L,1);
MissingLinkErrors = zeros(L,1);
TotalLinkValues = zeros(L,1);
TotalLinkErrors = zeros(L,1);
% Transformation vs Original
ExtraLinkValuesTrans = zeros(L,1);
ExtraLinkErrorsTrans = zeros(L,1);
MissingLinkValuesTrans = zeros(L,1);
MissingLinkErrorsTrans = zeros(L,1);
TotalLinkValuesTrans = zeros(L,1);
TotalLinkErrorsTrans = zeros(L,1);

i = 1;
for R = RVector
    name = sprintf('./%s/%s%d%d.one',InferredONEFolder,Name,R,Pattern);
    [Xinferred, N, d, tm, Box] = Matricize(name);
    % Optimization Algorithm vs Original
    ExtraLinks = zeros(tm,1);
    MissingLinks = zeros(tm,1);
    LinkErrors = zeros(tm,1);
    % Transformation vs Original
    ExtraLinksTrans = zeros(tm,1);
    MissingLinksTrans = zeros(tm,1);
    LinkErrorsTrans = zeros(tm,1);
    for t = 1:tm
        CGReal = DeriveCG(Xreal(:,:,t),R);
        % Optimization Algorithm vs Original
        CGInferred = DeriveCG(Xinferred(:,:,t),R);
        CGDiff = CGInferred - CGReal;
        % Transformation vs Original
        CGInferredTrans = DeriveCG(XInferredOriginal(:,:,t),R);
        CGDiffTrans = CGInferredTrans - CGReal;
        NormValue =  size(find(CGReal == 1),1);
        if (NormValue == 0)
            NormValue = 1;
        end
        % Optimization Algorithm vs Original
        ExtraLinks(t) =  size(find(CGDiff == 1),1) / NormValue;
        MissingLinks(t) = size(find(CGDiff == -1),1) / NormValue;
        LinkErrors(t) = ExtraLinks(t) + MissingLinks(t);
        % Transformation vs Original 
        ExtraLinksTrans(t) =  size(find(CGDiffTrans == 1),1) / NormValue;
        MissingLinksTrans(t) = size(find(CGDiffTrans == -1),1) / NormValue;
        LinkErrorsTrans(t) = ExtraLinksTrans(t) + MissingLinksTrans(t);
        
    end
    
    % Optimization Algorithm vs Original
    ExtraLinkValues(i) = mean(ExtraLinks);
    ExtraLinkErrors(i) = std(ExtraLinks);
    MissingLinkValues(i) = mean(MissingLinks);
    MissingLinkErrors(i) = std(MissingLinks);
    TotalLinkValues(i) = mean(LinkErrors);
    TotalLinkErrors(i) = std(LinkErrors);
    % Transformation vs Original    
    ExtraLinkValuesTrans(i) = mean(ExtraLinksTrans);
    ExtraLinkErrorsTrans(i) = std(ExtraLinksTrans);
    MissingLinkValuesTrans(i) = mean(MissingLinksTrans);
    MissingLinkErrorsTrans(i) = std(MissingLinksTrans);
    TotalLinkValuesTrans(i) = mean(LinkErrorsTrans);
    TotalLinkErrorsTrans(i) = std(LinkErrorsTrans);
    
    
    i = i + 1;   
end

Indices = 1:2:L;
figure(1);
hold on
errorbar(1:L,ExtraLinkValues,ExtraLinkErrors,'xr')
errorbar(1:L,ExtraLinkValuesTrans,ExtraLinkErrorsTrans,'xb')
legend('Optimization Algorithm','Transformation')
title('Extra Link Errors vs Transmission Range')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sExtraErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(2);
hold on
errorbar(1:L,MissingLinkValues,MissingLinkErrors,'xr')
errorbar(1:L,MissingLinkValuesTrans,MissingLinkErrorsTrans,'xb')
legend('Optimization Algorithm','Transformation')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Missing Link Errors vs Transmission Range')
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sMissingErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(3);
hold on
errorbar(1:L,TotalLinkValues,TotalLinkErrors,'xr')
errorbar(1:L,TotalLinkValuesTrans,TotalLinkErrorsTrans,'xb')
legend('Optimization Algorithm','Transformation')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Total Link Errors vs Transmission Range')
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sTotalErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


