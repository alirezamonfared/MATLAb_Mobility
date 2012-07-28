%SDPSolver Example
CG = [0 1 1; 1 0 1; 1 1 0];
R = 1;
dim = 2;
FixedPts = [];
NNodes = 3;
niter = 1;
%Wopt = eye(dim+NNodes);
Wopt = zeros(dim+NNodes); 
solver = 'sdpt3'


for i = 1 : niter
    [Xopt Gopt] = SDPSolver(R,CG, NNodes, FixedPts, dim,Wopt, solver);    
    Zopt = [eye(dim) Xopt ; Xopt' Gopt];
    Wopt = FindW(Zopt,dim);
end

Rank = Inf

% while (Rank > dim)
%     [Xopt Gopt] = SDPSolver(R,CG, NNodes, FixedPts, dim,Wopt, solver);
%     Zopt = [eye(dim) Xopt ; Xopt' Gopt];
%     Wopt = FindW(Zopt,dim);
%     Rank = rank(Zopt)
% end

[Xopt Gopt] = SDPSolver(R,CG, NNodes, FixedPts, dim, Wopt, solver); 
Xopt
Gopt
%D = FindD(Xopt);
%[X2opt D] = EigenDec(Gopt,dim)