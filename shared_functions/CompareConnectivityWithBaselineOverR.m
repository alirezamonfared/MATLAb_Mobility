function CompareConnectivityWithBaselineOverR(OriginalONEile,BaseLineONEFile,InferredONEFILE,RVector,MainR);
% compares the sets [original baseline] and [orginal inferred] in the same
% figure

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/shared_functions/plot2svg_20101128/')

if(nargin < 5)
    MainR = [];
end

[Path Name Ext]=fileparts(OriginalONEile);

[Xreal, N, d, tm, Box] = Matricize(OriginalONEile);
[Xbaseline, N, d, tm, Box] = Matricize(BaseLineONEFile);
[Xinferred, N, d, tm, Box] = Matricize(InferredONEFILE);

% Reserving containers
L = length(RVector);
InfExtraLinkValues = zeros(L,1);
InfExtraLinkErrors = zeros(L,1);
InfMissingLinkValues = zeros(L,1);
InfMissingLinkErrors = zeros(L,1);
InfTotalLinkValues = zeros(L,1);
InfTotalLinkErrors = zeros(L,1);

BaseExtraLinkValues = zeros(L,1);
BaseExtraLinkErrors = zeros(L,1);
BaseMissingLinkValues = zeros(L,1);
BaseMissingLinkErrors = zeros(L,1);
BaseTotalLinkValues = zeros(L,1);
BaseTotalLinkErrors = zeros(L,1);

i = 1;
for R = RVector
    InfExtraLinks = zeros(tm,1);
    InfMissingLinks = zeros(tm,1);
    InfLinkErrors = zeros(tm,1);
    
    BaseExtraLinks = zeros(tm,1);
    BaseMissingLinks = zeros(tm,1);
    BaseLinkErrors = zeros(tm,1);
    for t = 1:tm
        CGReal = DeriveCG(Xreal(:,:,t),R);
        CGInferred = DeriveCG(Xinferred(:,:,t),R);
        CGBase = DeriveCG(Xbaseline(:,:,t),R);
        if(~isempty(MainR))
            CGInferred = ModifyContact(CGInferred,CGReal,sign(R-MainR));
            CGBase = ModifyContact(CGBase,CGReal,sign(R-MainR));
        end
        InfCGDiff = CGInferred - CGReal;
        BaseCGDiff = CGBase - CGReal;
        NormValue =  size(find(CGReal == 1),1);
        if (NormValue == 0)
            NormValue = 1;
        end
        InfExtraLinks(t) =  size(find(InfCGDiff == 1),1) / NormValue;
        InfMissingLinks(t) = size(find(InfCGDiff == -1),1) / NormValue;
        InfLinkErrors(t) = InfExtraLinks(t) + InfMissingLinks(t);
        
        BaseExtraLinks(t) =  size(find(BaseCGDiff == 1),1) / NormValue;
        BaseMissingLinks(t) = size(find(BaseCGDiff == -1),1) / NormValue;
        BaseLinkErrors(t) = BaseExtraLinks(t) + BaseMissingLinks(t);
    end
    
    %ExtraLinks = ExtraLinks / (N*(N-1)/2);
    %MissingLinks = MissingLinks / (N*(N-1)/2);
    %LinkErrors = LinkErrors / (N*(N-1)/2);
    
    InfExtraLinkValues(i) = mean(InfExtraLinks);
    InfExtraLinkErrors(i) = std(InfExtraLinks);
    InfMissingLinkValues(i) = mean(InfMissingLinks);
    InfMissingLinkErrors(i) = std(InfMissingLinks);
    InfTotalLinkValues(i) = mean(InfLinkErrors);
    InfTotalLinkErrors(i) = std(InfLinkErrors);
    
    BaseExtraLinkValues(i) = mean(BaseExtraLinks);
    BaseExtraLinkErrors(i) = std(BaseExtraLinks);
    BaseMissingLinkValues(i) = mean(BaseMissingLinks);
    BaseMissingLinkErrors(i) = std(BaseMissingLinks);
    BaseTotalLinkValues(i) = mean(BaseLinkErrors);
    BaseTotalLinkErrors(i) = std(BaseLinkErrors);
    
    i = i + 1;   
end

Indices = 1:2:L;
figure(1);
hold on
errorbar(1:L,InfExtraLinkValues,InfExtraLinkErrors,'xr')
errorbar(1:L,BaseExtraLinkValues,BaseExtraLinkErrors,'xb')
legend('Test','Baseline')
title('Extra Link Errors Performance vs Baseline')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sExtraErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(2);
hold on
errorbar(1:L,InfMissingLinkValues,InfMissingLinkErrors,'xr')
errorbar(1:L,BaseMissingLinkValues,BaseMissingLinkErrors,'xb')
legend('Test','Baseline')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Missing Link Errors Performance vs Baseline')
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sMissingErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


figure(3);
hold on
errorbar(1:L,InfTotalLinkValues,InfTotalLinkErrors,'xr')
errorbar(1:L,BaseTotalLinkValues,BaseTotalLinkErrors,'xb')
legend('Test','Baseline')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',RVector(Indices))
title('Total Link Errors Performance vs Baseline')
xlabel('Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sTotalErrorsN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);


