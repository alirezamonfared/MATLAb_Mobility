function ErrorVector = ReportErrorOverR( OriginalInputFile, ComparisonFile, Parameters )
% Parameters Options: NormMode : defines the normalization mode
% NormMode == 0 --> Normalize by 1's of Input Contact Trace
% NormMode == 1 --> Normalize by 0's of Input Contact Trace
% NormMode == 2 --> Normalize by N(N-1) flat

%% Default Values
if (~isfield(Parameters,'NormMode'))
    NormMode = 0;
else
    NormMode = Parameters.NormMode;
end

if (~isfield(Parameters,'InputRs'))
    InputRs = 100;
else
    InputRs = Parameters.InputRs;
end

if (~isfield(Parameters,'Range'))
    Range = [0 150];
else
    Range = Parameters.Range;
end

if (~isfield(Parameters,'step'))
    step = 5;
else
    step = Parameters.step;
end

if (~isfield(Parameters,'RemoveRange'))
    RemoveRange = 1;
else
    RemoveRange = Parameters.RemoveRange;
end

if (~isfield(Parameters,'MainR'))
    MainR = [];
else
    MainR = Parameters.MainR;
end

RVector = Range(1):step:Range(2);


%% Initializations
L = length(RVector);
RemoveIndices = [];

%% Opening Files
[Path Name Ext]=fileparts(OriginalInputFile);
[Xreal, N, d, tm, Box] = Matricize(OriginalInputFile);

[Path Name Ext]=fileparts(ComparisonFile);
[Xinferred, N, d, tm, Box] = Matricize(ComparisonFile);

%% Error Values Initializations
ExtraLinkValues = zeros(L,1);
ExtraLinkErrors = zeros(L,1);
MissingLinkValues = zeros(L,1);
MissingLinkErrors = zeros(L,1);
PresentContactValues = zeros(L,1);
PresentNonContactValues = zeros(L,1);
TotalLinkValues = zeros(L,1);
TotalLinkErrors = zeros(L,1);
%% Finding Error
j = 1;
for R = RVector
    if (~isempty(find(InputRs==R,1)))
        RemoveIndices = [RemoveIndices j];
    end
    ExtraLinks = zeros(tm,1);
    MissingLinks = zeros(tm,1);
    LinkErrors = zeros(tm,1);
    PresentContacts = zeros(tm,1);
    PresentNonContacts = zeros(tm,1);
    
    for t = 1:tm
        CGInferred = DeriveCG(Xinferred(:,:,t),R);
        CGReal = DeriveCG(Xreal(:,:,t),R);
        if(~isempty(MainR))
            CGInferred = ModifyContact(CGInferred,CGReal,sign(R-MainR));
        end
        CGDiff = CGInferred - CGReal;
        if (NormMode == 0)
            NormValue =  size(find(CGReal == 1),1);
        elseif(NormMode == 1)
            NormValue =  size(find(CGReal == 0),1);
        elseif(NormMode == 2)
            NormValue =  N*(N-1)/2;
        else
            error('NormMode can be 0, 1 or 2')
        end
        if (NormValue == 0)
            NormValue = 1;
        end
        ExtraLinks(t) =  (size(find(CGDiff == 1),1) / NormValue)*100;
        MissingLinks(t) = (size(find(CGDiff == -1),1) / NormValue)*100;
        PresentContacts(t) = ((size(intersect(find(CGReal == 1),find(CGInferred == 1)),1)) / NormValue)*100;
        PresentNonContacts(t) = ((size(intersect(find(CGReal == 0),find(CGInferred == 0)),1)) / NormValue)*100;
        LinkErrors(t) = ExtraLinks(t) + MissingLinks(t);
        
    end
    ExtraLinkValues(j) = mean(ExtraLinks);
    %ExtraLinkErrors(j) = std(ExtraLinks);
    MissingLinkValues(j) = mean(MissingLinks);
    %MissingLinkErrors(j) = std(MissingLinks);
    PresentContactValues(j) = mean(PresentContacts);
    PresentNonContactValues(j) = mean(PresentNonContacts);
    TotalLinkValues(j) = mean(LinkErrors);
    %TotalLinkErrors(j) = std(LinkErrors);
    j = j + 1;
end

%% Modify Indices to be removed
if (RemoveRange > 0)
    RemoveIndices_tmp = [];
    for Index = RemoveIndices
        ExtraIndices = Index-RemoveRange:Index+RemoveRange;
        ExtraIndices = ExtraIndices(ExtraIndices>=1);
        ExtraIndices = ExtraIndices(ExtraIndices<=L);
        RemoveIndices_tmp = [RemoveIndices_tmp ExtraIndices];
    end
    RemoveIndices = RemoveIndices_tmp;
    RemoveIndices_tmp = [];
end
RemoveIndices

ExtraLinkValues(RemoveIndices) = [];
%ExtraLinkErrors(RemoveIndices) = [];
MissingLinkValues(RemoveIndices) = [];
%MissingLinkErrors(RemoveIndices) = [];
PresentContactValues(RemoveIndices) = [];
PresentNonContactValues(RemoveIndices) = [];
TotalLinkValues(RemoveIndices) = [];
TotalLinkErrors(RemoveIndices) = [];


ExtraLinksMean = mean(ExtraLinkValues);
%ExtraLinksStd = mean(ExtraLinkErrors);
MissingLinkMean = mean(MissingLinkValues);
%MissingLinkStd = mean(MissingLinkErrors);
PresentContactMean = mean(PresentContactValues);
PresentNonContactMean = mean(PresentNonContactValues);
TotalLinkMean = mean(TotalLinkValues);
TotalLinkStd = mean(TotalLinkErrors);

ErrorVector = [TotalLinkMean  ExtraLinksMean  MissingLinkMean  PresentContactMean PresentNonContactMean];
end
