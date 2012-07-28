function  [Violations InRangeViolation OutofRangeViolation...
    SpeedViolation] = ValidilityCheck(X, Xp, CG, R, Vm);

% Initializations, Variable/metric definitions
NonViolated = 0;
GoodOutofRange = 0;
GoodInRange = 0;
GoodSpeed = 0;


[dim N] = size(X);

TotalInRange = size(find(CG == 1),1) / 2;
TotalOutofRange = size(find(CG == 0),1) / 2 - 50; %subtract 0 diagonals
TotalSpeed = N;
Total = (N*(N-1)) / 2 + N;

%% metric Updates
for i = 1:N        
    Xi = X(:,i);
    for j = i+1:N
        Xj = X(:,j);
        Dij = norm(Xi-Xj,2);
        if (CG(i,j) == 1 && Dij <= R)
                NonViolated =  NonViolated + 1;
                GoodInRange = GoodInRange + 1;
        elseif (CG(i,j) == 0 && Dij >= R)
            NonViolated =  NonViolated + 1;
            GoodOutofRange = GoodOutofRange + 1;
        end
    end
    P = norm(Xi-Xp(:,i),2);
    if (P <= Vm)
        NonViolated =  NonViolated + 1;
        GoodSpeed = GoodSpeed + 1;
    end
end

%% Final metric claclulations
Violations = 1 - NonViolated / Total;
InRangeViolation = 1 - GoodInRange / TotalInRange;
OutofRangeViolation = 1 - GoodOutofRange / TotalOutofRange;
SpeedViolation = 1 - GoodSpeed / TotalSpeed;


end