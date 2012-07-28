function SuggestedDistances = Node2DHistogram( InputFile, nBins, Range, NDesiredRs)
%NODEPAIRDISTANCEHISTOGRAM Plots histogram of nodepair distances for the
%given mobility
%   mode == 0 --> Confine distances between RangeStart and RangeEnd, plot
%   between these ranges
% mode == 1 --> Do not confine distances between RangeStart and RangeEnd, plot
%   between these ranges
% mode == 2 --> Do not confine distances between RangeStart and RangeEnd, plot
%   for all ranges
% If the funcion is called with two arguments, we assume that the second
% argument is the range length, i.e. the range spanes over [0 argin(2)]

%% Initializations
if (nargin < 2)
    nBins = 100;
end

if (nargin < 3 || isempty(Range))
    RangeStart = [];
    RangeEnd = [];
elseif (length(Range) == 1)
    RangeEnd = Range(1);
    RangeStart = 0;
else
    RangeStart = Range(1);
    RangeEnd = Range(2);
end

if (nargin < 4)
    NDesiredRs = [];
end

%% Adding Paths
addpath('../shared_functions/')
addpath('../shared_functions/plot2svg_20101128/')

%% Opening the files
[Path Name Ext]=fileparts(InputFile);
[X, N, d, tm, Box] = Matricize(InputFile);

%% Extracting the 2D histogram
XVec = reshape(squeeze(X(1,:,:))',1, size(X,2)*size(X,3))';
YVec = reshape(squeeze(X(2,:,:))',1, size(X,2)*size(X,3))';
xedges = linspace(0,Box,nBins+1); 
yedges = linspace(0,Box,nBins+1); 
histmat = hist2(XVec, YVec, xedges, yedges);

%% Plotting Results
figure; 
pcolor(xedges,yedges,histmat'); 
colorbar ; 
axis square tight ;
TilteStr = sprintf('Location Heatmap for %s',Name);
title(TilteStr)


%% Finding location of High density areas
%histmat = histmat(1:nBins-1,1:nBins-1);
[num idx] = sort(histmat(:),'descend');
[XInd YInd] = ind2sub(size(histmat),idx);
XInd = (XInd - 0.5.*ones(size(XInd))).*(Box/nBins);
YInd = (YInd - 0.5.*ones(size(YInd))).*(Box/nBins);
SuggestedDistances = pdist([XInd YInd]);
[junk,index]  = unique(SuggestedDistances,'first');
SuggestedDistances = SuggestedDistances(sort(index));
SuggestedDistances = (SuggestedDistances)' - 0.5.*(Box/nBins).*sqrt(2);

if(~isempty(RangeStart))
    SuggestedDistances = SuggestedDistances(SuggestedDistances >= RangeStart);
end
if(~isempty(RangeEnd))
    SuggestedDistances = SuggestedDistances(SuggestedDistances <= RangeEnd);
end

if(~isempty(NDesiredRs))
    SuggestedDistances = SuggestedDistances(1:NDesiredRs);
end
end

