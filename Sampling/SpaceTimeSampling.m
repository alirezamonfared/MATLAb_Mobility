function  [SampledX NSReal] = SpaceTimeSampling(X, SimPars);
% Samples by placing space-time windows on the evolving graph. Each placed
% window can be used to gather at most one sample to achieve fair sampling
% of the input
%% Initializations, Defaults vlaues
if (~isfield(SimPars,'Box'))
    Box = 1000;
else
    Box = SimPars.Box; % Field size
end

if (~isfield(SimPars,'phi'))
    phi = 0.1;
else
    phi = SimPars.phi; % Sampling ratio goal to achieve
end

if (~isfield(SimPars,'LRatio'))
    LRatio = 0.1;
else
    LRatio = SimPars.LRatio;
end

L = LRatio * Box; % Space Length of Window

if (~isfield(SimPars,'W'))
    W = 1;
else
    W = SimPars.W; % Time length of window
end

if (~isfield(SimPars,'MaxTries'))
    MaxTries = 1000;
else
    MaxTries = SimPars.MaxTries; % Maximum number of windows to look at
end

[d N tm] = size(X);
NS = phi * N; % Required Number of samples

SampledX = zeros(d,NS,tm);
Indices = 1:N;

%% Sampling
NSReal = 0;
for Try = 1:MaxTries
    % Build random rectangle
    XStart = rand(2,1) * Box;
    XDiff = rand(2,1) * L;
    Xend = min(XStart + XDiff, [Box;Box]);
    % Take random time window
    t = randi(tm);
    tEnd = min(t+W,tm);
    IndexIterator = Indices;
    BreakFlag = 0;
    if (NSReal >= NS)
        break
    end
    for st = t:tEnd
        for index = IndexIterator
            XTest = X(:,index,st);
            % If the picked point is in the box, sample it, increment
            % the number of samples and remove the index from indices
            % list for future samples
            if(isequal(XTest >= XStart, ones(2,1)) && isequal(XTest <= Xend, ones(2,1)))
                NSReal = NSReal + 1;
                SampledX(:,NSReal,:) = X(:,index,:);
                Indices(Indices == index) = [];
                BreakFlag = 1;
                break;
            end
        end
        if(BreakFlag==1)
            break
        end
    end
end
end