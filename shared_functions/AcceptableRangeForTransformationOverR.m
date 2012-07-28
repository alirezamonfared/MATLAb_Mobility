function AcceptableRange = AcceptableRangeForTransformationOverR(OriginalONEile,InferredONEFolder,RVector,ChosenR, Pattern, ErrorTreshold);
% This function analyzes the acceptable range forthe transformation to
% replace optimization
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/shared_functions/plot2svg_20101128/')

[Path Name Ext]=fileparts(OriginalONEile);

if nargin < 5
    Pattern = 21;
end

if nargin < 6
    ErrorTreshold = 10;
end

AcceptableRange = [NaN NaN];
NotFoundRangeLV = 1;

[Xreal, N, d, tm, Box] = Matricize(OriginalONEile);
InferredName = sprintf('./%s/%s%d%d.one',InferredONEFolder,Name,ChosenR,Pattern);
[XInferredOriginal, N, d, tm, Box] = Matricize(InferredName);


% Reserving containers
L = length(RVector);
% Optimization Algorithm vs Original
TotalLinkValues = zeros(L,1);
% Transformation vs Original
TotalLinkValuesTrans = zeros(L,1);

UltimateError = zeros(L,1);

i = 1;
for R = RVector
    name = sprintf('./%s/%s%d%d.one',InferredONEFolder,Name,R,Pattern);
    [Xinferred, N, d, tm, Box] = Matricize(name);
    % Optimization Algorithm vs Original
    LinkErrors = zeros(tm,1);
    % Transformation vs Original
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
        LinkErrors(t) =  size(find(CGDiff ~= 0),1) / NormValue;
        % Transformation vs Original 
        LinkErrorsTrans(t) =  size(find(CGDiffTrans ~= 0),1) / NormValue;
        
    end
    
    % Optimization Algorithm vs Original
    TotalLinkValues(i) = mean(LinkErrors);
    % Transformation vs Original    
    TotalLinkValuesTrans(i) = mean(LinkErrorsTrans);
    
    UltimateError(i) = abs(TotalLinkValuesTrans(i) - TotalLinkValues(i))/TotalLinkValues(i);
    
    if (R <= ChosenR && UltimateError(i) <= ErrorTreshold && NotFoundRangeLV)
        NotFoundRangeLV = 0;
        AcceptableRange(1) = R; 
    end
    
    if (R >= ChosenR && UltimateError(i) <= ErrorTreshold)
        AcceptableRange(2) = R; 
    end
    i = i + 1;   
end

Indices = 1:2:L;
figure(1);
hold on
SmoothUltimateError = smooth(1:L,UltimateError,0.1,'rloess');
plot(1:L,SmoothUltimateError,'r-')
title('Relative Error of Transformation to the Optimization')
set(gca,'XTick',Indices)
set(gca,'XTickLabel',abs(RVector(Indices)-ChosenR)/ChosenR)
xlabel('Relative Transmission Range')
ylabel('Error in %')
hold off
filename = sprintf('./Results/%sUltimateErrorN%dT%dR%d.svg',Name,N,tm,R);
plot2svg(filename);
