function  Wopt = FindW(Z,npts);

dim = size(Z,2)
W = sdpvar(dim, dim);

Constraints = set(W >= 0);
Constraints = Constraints + set(W <= eye(dim));
Constraints = Constraints + set(trace(W) == npts);

Objective = trace(Z' * W);

Options = sdpsettings('solver','sdpt3');
solvesdp(Constraints, Objective, Options);
Wopt = double(W);

end