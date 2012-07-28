% CG = sparse connectivity graph
function  [Xopt Gopt] = SDPSolverYALMIP3(R,CG, dim, solver, niter, alpha);

N = size(CG,1);

if nargin < 3; dim = 2; end
if nargin < 4; solver = 'sedumi'; end
if nargin < 5; niter = 2; end
if nargin < 6; alpha = 0; end

mm = 0;
Wopt = eye(dim+N);

X = sdpvar(dim, N,'full');
G = sdpvar(N,N,'symmetric');
Z = [eye(dim) X ; X' G];

for iter = 1:niter
    W = Wopt;
    Constraints = set(Z >= 0);
    mm = mm + 1;
    for i = 1:N
        for j = i+1:N
            ei = zeros(N, 1);
            ei(i) = 1;
            ej = zeros(N, 1);
            ej(j) = 1;
            eij = ei - ej;
            mm = mm + 1;
            if (CG(i,j) == 1)  % If distance measure exists
                Constraints = Constraints + set(trace(G' * (eij * eij')) <= R);
            else
                Constraints = Constraints + set(trace(G' * (eij * eij')) >= R);
            end
        end
    end
    
    if (alpha == 0)
        Objective = trace(Z'*W);
    else
        a = ones(N,1)/sqrt(N);
        Objective = trace(Z'*W) - alpha * trace((eye(N)-a*a')' * Z);
    end
    
    if strcmp(solver,'sedumi') == 1
        Options = sdpsettings('solver','sedumi');
    else
        Options = sdpsettings('solver','sdpt3');
    end
    
    solvesdp(Constraints, Objective, Options);
    
    Xopt = double(X);
    Gopt = double(G);
    
    Zopt = [eye(dim) Xopt ; Xopt' Gopt];

    W = sdpvar(dim+N,dim+N);
    
        %minimize(trace(Zopt'*W))
        %subject to
    WConstraints = set(W >= 0);
    
    wConstraints = WConstraints + set(W <= eye(dim+N));
    WConstraints = WConstraints + set(trace(W) == N);

    WObjective = trace(Z' * W);

    solvesdp(WConstraints, WObjective, Options);
    Wopt = double(W);

end
 
end