function SignificantRs = NodepairDistanceHistogram( InputFile, Range, mode, PercentileValues, ShowPlot, Func )
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
if (nargin < 2 || isempty(Range))
    RangeStart = [];
    RangeEnd = [];
elseif (length(Range) == 1)
    RangeEnd = Range(1);
    RangeStart = 0;
else
    RangeStart = Range(1);
    RangeEnd = Range(2);
end
if nargin < 3
    mode = 0;
end
if nargin < 4
    PercentileValues = [25 75];
end

if nargin < 5
    ShowPlot = 0;
end

if nargin < 6
    Func = 'survivor';
end


%% Error Checking
if (length(PercentileValues) ~= 2)
    error('PercentileValues provided incorrectly')
end

%% Adding Paths
addpath('../shared_functions/')

%% Opening Input file
[Path Name Ext]=fileparts(InputFile);
[X, N, d, tm, Box] = Matricize(InputFile);
NodepairDistances = [];
Rs = 1:Box*sqrt(2);

%% Deriving the histogram
for t = 1:tm
    XNow = X(:,:,t);
    D = pdist(XNow');
    NodepairDistances = [NodepairDistances D];
end
if(~isempty(RangeStart))
    if (mode == 0)
        NodepairDistances = NodepairDistances(NodepairDistances >= RangeStart);
    end
    if (mode ~= 2)
        Rs = Rs(Rs >= RangeStart);
    end
end
if(~isempty(RangeEnd))
    if(mode == 0)
        NodepairDistances = NodepairDistances(NodepairDistances <= RangeEnd);
    end
    if (mode ~= 2)
        Rs = Rs(Rs <= RangeEnd);
    end
end

%% Plotting the histogram/CDF
if (ShowPlot == 1)
    NHist = ksdensity(NodepairDistances, Rs,'function',Func);
    plot(Rs,NHist)
    xlabel('Nodepair Distance')
    ylabel('Estimated Density')
    TilteStr = sprintf('Nodepair Distance Density for %s',Name);
    title(TilteStr)
end
%% Deriving Suggested Rs
%[pks,locs] = findpeaks(NHist,'SORTSTR','descend');
%SignificantRs = Rs(locs);

SignificantRs = prctile(NodepairDistances,PercentileValues);
end

