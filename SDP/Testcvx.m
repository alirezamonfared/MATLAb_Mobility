%SDPSolver Example
%CG = [0 1 1; 1 0 1; 1 1 0];
CG = [0 1 0; 1 0 0; 0 0 0];
R = 1;
dim = 2;
%FixedPts = [];
FixedPts = [0;0];
NNodes = 3;
npts = NNodes + size(FixedPts,2)
niter = 1;
%Wopt = eye(dim+NNodes);
Wopt = zeros(dim+npts); 
solver = 'sedumi'


% for i = 1 : niter
%     [Xopt Gopt] = SDPSolverCVX(R,CG, NNodes, FixedPts, dim, Wopt, solver);    
%     Zopt = [eye(dim) Xopt ; Xopt' Gopt];
%     Wopt = FindWCVX(Zopt,dim, solver);
% end

Rank = Inf

while (Rank > dim)
    [Xopt Gopt] = SDPSolverCVX(R,CG, NNodes, FixedPts, dim,Wopt, solver);
    Zopt = [eye(dim) Xopt ; Xopt' Gopt];
    Wopt = FindWCVX(Zopt,dim, solver);
    Rank = rank(Zopt)
end

[Xopt Gopt] = SDPSolverCVX(R,CG, NNodes, FixedPts, dim, Wopt, solver); 
Xopt
Gopt
%D = FindD(Xopt);
%[X2opt D] = EigenDec(Gopt,dim)