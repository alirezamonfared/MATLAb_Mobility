function [f f1 f2 f3]= ObjectiveValue(X, Xp, CG, R, Vm);
N = size(CG,1);
f1 = 0;
f2 = 0;
f3 = 0;
for i2 = 1:N
    Xi = X(:,i2);
    for j2 = i2+1:N
        Xj = X(:,j2);
        Dij = norm(Xi-Xj,2);
        if (CG(i2,j2) == 1)
            f1 = f1 + (max(0,(Dij-R)))^2;
            
        else
            f2 = f2 + (min(0,(Dij-R)))^2;
        end
    end
    PP = norm(Xi-Xp(:,i2),2);
    f3 = f3 + (max(0,(PP-Vm)))^2;
end
f1;
f2;
f3;
f = f1 + f2 + f3;
end
