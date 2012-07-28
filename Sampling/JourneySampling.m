function  [SampledX NSReal] = JourneySampling(X, SimPars);
% Samples by tracking randomly chosen on the evolving graph. Each journey
% is intercepted at a random time, and followed up until a given time.
% SimPars.Mode defines three flavors of this algorithm:
% SimPars.Mode == 1 : Only track space journeys
% SimPars.Mode == 2 : Only track time journeys
% SimPars.Mode == 3 : Track space-time journeys
%% Initializations, Defaults vlaues

if (~isfield(SimPars,'phi'))
    phi = 0.1;
else
    phi = SimPars.phi; % Sampling ratio goal to achieve
end

if (~isfield(SimPars,'W'))
    W = 10;
else
    W = SimPars.W; % Maximum Time length of a journey to follow
end

if (~isfield(SimPars,'MaxTries'))
    MaxTries = 1000;
else
    MaxTries = SimPars.MaxTries; % Maximum number of windows to look at
end

if (~isfield(SimPars,'R'))
    R = 100;
else
    R = SimPars.R; % Transmission Range
end

if (~isfield(SimPars,'Mode') || (SimPars.Mode ~= 2 && SimPars.Mode ~= 3))
    Mode = 1;
else
    Mode = SimPars.Mode; % Transmission Range
end

switch Mode
    case 1
        disp('Space Sampling Mode')
    case 2
        disp('Time Sampling Mode')
    case 3
        disp('Space-Time Sampling Mode')
    otherwise
        error('SimPars.mode is set to an illegal value');
end

[d N tm] = size(X);
NS = phi * N; % Required Number of samples

SampledX = zeros(d,NS,tm);
Indices = 1:N;

NSReal = 1;
BreakFlag = 0; 

CGs = MobilityToConatcts(X,R);

%% Sampling
for Try = 1:MaxTries    
    % Take random time window, and a random Node
    t = randi(tm);
    IX = randi(length(Indices));
    Index = Indices(IX);
    SampledX(:,NSReal,:) = X(:,Index,:);
    Indices(Indices == Index) = [];
    NSReal = NSReal + 1;
    if (NSReal >= NS)
        
        break
    end
    Neighbors = find(CGs(Index,:,t) ~= 0);
    Neighbors = intersect(Neighbors,Indices); % Remove visited indices
    Iters = 0;
    while (Iters <= W && ~isempty(Neighbors))
        IX = randi(length(Neighbors));
        Index = Neighbors(IX);
        SampledX(:,NSReal,:) = X(:,Index,:);
        Indices(Indices == Index) = [];
        NSReal = NSReal + 1;
        switch Mode
            case 1
                Neighbors = find(CGs(Index,:,t) ~= 0); % Sapce journeys only
            case 2
                Neighbors = find(CGs(Index,:,min(t+1,tm)) ~= 0); % Time journeys only
            case 3
                sp = randi(2); % Sapce-Time journeys
                if (sp == 1)
                    Neighbors = find(CGs(Index,:,t) ~= 0);
                else
                    Neighbors = find(CGs(Index,:,min(t+1,tm)) ~= 0);
                end
            otherwise
                error('SimPars.mode is set to an illegal value');
        end
        Neighbors = intersect(Neighbors,Indices); % Remove visited indices
        if (NSReal >= NS)
            BreakFlag = 1;
            break
        end
        Iters = Iters + 1;
    end
    if (BreakFlag == 1)
        break
    end
end
end