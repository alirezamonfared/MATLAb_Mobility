function  [Violations InRangeViolation OutofRangeViolation...
    ] = ValidilityCheckNoSpeed(X, CG, R);

% Initializations, Variable/metric definitions
NonViolated = 0;
GoodOutofRange = 0;
GoodInRange = 0;


[dim N] = size(X);

TotalInRange = size(find(CG == 1),1) / 2;
TotalOutofRange = size(find(CG == 0),1) / 2 - 50; %subtract 0 diagonals
Total = (N*(N-1)) / 2 ;

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
end

%% Final metric claclulations
Violations = 1 - NonViolated / Total;
InRangeViolation = 1 - GoodInRange / TotalInRange;
OutofRangeViolation = 1 - GoodOutofRange / TotalOutofRange;


end