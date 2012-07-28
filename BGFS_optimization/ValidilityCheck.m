function  [Violations InRangeViolation OutofRangeViolation...
    SpeedViolation] = ValidilityCheck(X, Xp, CG, R, Vm);

% Initializations, Variable/metric definitions
Violations = 0;
OutofRangeViolation = 0;
InRangeViolation = 0;
SpeedViolation = 0;


[dim N] = size(X);

TotalInRange = size(find(CG == 1),1) / 2;
TotalOutofRange = size(find(CG == 0),1) / 2 - N; %subtract 0 diagonals
TotalSpeed = N;
Total = (N*(N-1)) / 2 + N;

%% metric Updates
for i = 1:N        
    Xi = X(:,i);
    for j = i+1:N
        Xj = X(:,j);
        Dij = norm(Xi-Xj,2);
        if (CG(i,j) == 1 && Dij > R)
                Violations =  Violations + 1;
                InRangeViolation = InRangeViolation + 1;
        elseif (CG(i,j) == 0 && Dij < R)
            Violations =  Violations + 1;
            OutofRangeViolation = OutofRangeViolation + 1;
        end
    end
    P = norm(Xi-Xp(:,i),2);
    if (P > Vm)
        Violations =  Violations + 1;
        SpeedViolation = SpeedViolation + 1;
    end
end


%% Final metric claclulations
Violations = Violations / Total;
InRangeViolation = InRangeViolation / TotalInRange;
OutofRangeViolation = OutofRangeViolation / TotalOutofRange;
if(isinf(InRangeViolation) || isnan(InRangeViolation))
    InRangeViolation = 0;
end
if(isinf(OutofRangeViolation) || isnan(OutofRangeViolation))
    OutofRangeViolation = 0;
end
SpeedViolation = SpeedViolation / TotalSpeed;


end