 function  [SampledX NSReal] = TrackerSampling(X, SimPars);
% Samples are taken with space-time windows
% X is a d x N matrix
% SampledX is the mobility trace corresponding to the sampled set
% NSReal is the number of samples achieved
% Simpars

%Box = SimPars.Box;

if (~isfield(SimPars,'phi'))
    phi = 0.1;
else
    phi = SimPars.phi; % Sampling ratio goal to achieve
end

%LRatio = SimPars.LRatio;
%L = LRatio * Box; % Space Length of Window

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
% Choosing the first two nodes
% We pick a node at random and and the node nearest to it to track
IndexA = randi(N);
SampledX(:,1,:) = X(:,IndexA,:);
Distances = squareform(pdist(X(:,:,1)'));
DistanceIndexARow = Distances(:,IndexA);
DistanceIndexARow = DistanceIndexARow(DistanceIndexARow~=0);
[MinValue IndexB] = min(DistanceIndexARow);
SampledX(:,2,:) = X(:,IndexB,:);
NSReal = 3;
% Remove sampled elements from the indices
Indices(Indices == IndexA) = [];
Indices(Indices == IndexB) = [];

for Try = 1:MaxTries
    if (NSReal < NS)
        % charachterize window length in time
        t = randi(tm);
        if (t + W < tm)
            tEnd = t + W;
        else
            tEnd = tm;
        end
        % charachterize window length in time
        for st = t:tEnd
            XA = X(:,IndexA,st);
            XB = X(:,IndexB,st);
            % Finding the extreme faces of the rectangle
            XCenter = (XA + XB) / 2;
            LW = abs(XA-XB);
            XA = XCenter - LW/2;
            XB = XCenter + LW/2;
            % Copy indeces to avoid unsafe operations on the iterator and
            % keep it static
            IndexIterator = Indices;
            for index = IndexIterator
                XTest = X(:,index,st);
                % If the picked point is in the box, sample it, increment
                % the number of samples and remove the index from indices
                % list for future samples
                if(isequal(XTest >= XA, ones(2,1)) && isequal(XTest <= XB, ones(2,1)))
                    NSReal = NSReal + 1;
                    if (NSReal >= NS)
                        break
                    end
                    SampledX(:,NSReal,:) = X(:,index,:);
                    Indices(Indices == index) = [];
                end
            end
            if (NSReal >= NS)
                break
            end
        end
    else
        break
    end
end
fprintf('Sampling completed in %d tries\n',Try);
 end

