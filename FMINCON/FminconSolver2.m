function  Xopt = FminconSolver2(R, CG, Xp, N, dim, Vm); 

X = sdpvar(dim, N,'full');
a = sdpvar(1,1);

Constraints = set(a == 0 );

for i = 1:N        
    Xi = X(:,i);
    for j = i+1:N
        Xj = X(:,j);
        %Dij = norm(Xi-Xj,2);
        Dij = (Xi-Xj)' * (Xi-Xj);
        if (CG(i,j) == 1)
            Constraints = Constraints + set(Dij <= R^2);
        else
            Constraints = Constraints + set(Dij >= R^2);
        end
    end
end

for i = 1:N
    Xi = X(:,i);
    P = (Xi-Xp(:,i))' * (Xi-Xp(:,i));
    Constraints = Constraints + set(P <= Vm^2);
end


%% Set the objective
%Objective = trace(Z'*W);
%Objective = trace(Z);
%Objective = sum(X(:));
Objective = 0;
%% Solve
Constraints;
Objective;
Options = sdpsettings('solver','fmincon','fmincon.Hessian',{'lbfgs'},...
    'fmincon.LargeScale','on');

solvesdp(Constraints, Objective, Options);
Xopt = double(X);
a = double(a)

end

