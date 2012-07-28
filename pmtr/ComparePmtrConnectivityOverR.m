function ComparePmtrConnectivityOverR(OriginalONEileLinks,InferredONEFILEMobility,RVector);

[Path Name Ext]=fileparts(OriginalONEileLinks);
[CGReals TSeq] = ImportPMTR(OriginalONEileLinks);

addpath('/home/alireza/workspace/MobilityProject/MATLAB/shared_functions/plot2svg_20101128/')

[Xinferred, N, d, tm, Box] = Matricize(InferredONEFILEMobility);

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
    ExtraLinks = zeros(tm,1);
    MissingLinks = zeros(tm,1);
    LinkErrors = zeros(tm,1);
    for t = 1:tm
        CGReal = CGReals(:,:,t);
        CGInferred = DeriveCG(Xinferred(:,:,t),R);
        %size(CGReal)
        %size(CGInferred)
        % Hack
        %CGInferred = CGInferred(2:50,2:50);
        
        CGDiff = CGInferred - CGReal;
        NormValue =  size(find(CGReal == 1),1);
        if (NormValue == 0)
            NormValue = 1;
        end
        ExtraLinks(t) =  size(find(CGDiff == 1),1) / NormValue;
        MissingLinks(t) = size(find(CGDiff == -1),1) / NormValue;
        LinkErrors(t) = ExtraLinks(t) + MissingLinks(t) / NormValue;
    end
    
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

end