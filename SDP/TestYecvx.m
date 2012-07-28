%SDPSolver Example
%CG = [0 1 1; 1 0 1; 1 1 0];
CG = [0 1 0; 1 0 0; 0 0 0];
R = 1;
dim = 2;
FixedPts = [];
%FixedPts = [0;0];
NNodes = 3;
npts = NNodes + size(FixedPts,2)
solver = 'sedumi'


[Xopt Gopt Alpha] = YeModelSolverCVX(R,CG, NNodes, FixedPts, dim, solver); 
Xopt
Gopt
%D = FindD(Xopt);
%[X2opt D] = EigenDec(Gopt,dim)