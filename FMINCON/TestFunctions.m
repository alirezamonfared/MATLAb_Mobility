
Vm = 1.5;
R = 15;
[Xreal M] = Matricize('CSV.csv', 100, 2, 51);
Xp = Xreal(:,:,1);
X = Xreal(:,:,1);
[dim NNodes] = size(X);
CG = DeriveCG(X, R);
%[Xopt Gopt] = FminconSolver(R, CG, NNodes, [], dim);
Xopt = FminconSolver2(R, CG, Xp, NNodes, dim, Vm);
%Res = ValidilityCheck(R, CG, X, Xp, NNodes, dim, Vm)