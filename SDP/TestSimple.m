addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/')

% Xr =  [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4;1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 ];
% N = 16;
% R = 1;
% dim = 2;
% niter = 2;
% CG = DeriveCG(X,1.1);

R = 15;
dim = 2;
N = 100;
niter = 2;

[Xreal M] = Matricize('CSV.csv', 100, 2, 51);
Xr = Xreal(:,:,1);
CG = DeriveCG(Xr,R);

tic;
[Xopt Gopt] = SDPSolverCVX3(R,CG, dim, 'sedumi',2);
%[Xopt Gopt] = SDPSolverYALMIP3(R,CG, dim, 'sedumi',2);
toc;

CG2 = DeriveCG(Xopt,R);
CGDiff = size(find(CG-CG2 ~= 0),1) / size(CG,2)^2

figure;
hold on
scatter(Xopt(1,:),Xopt(2,:),'r','o')
scatter(Xr(1,:),Xr(2,:),'b','+')
title('Sample Iteration for Fmincon()')
legend('Inferred Location','Real Location')
hold off

[Violations InRangeViolation OutofRangeViolation] = ...
    ValidilityCheckNoSpeed(Xopt, CG, R);