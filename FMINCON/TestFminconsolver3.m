%Test Fminconsolver

addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/');
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c/');
%N = 3;
%d = 2;
%CG = [0 1 0;1 0 0;0 0 0];
%Xp = [1 1 2 ; 1 2 2];
Parameters = struct('R',15,'Vm',1.5, 'InitLoc', false);

[Xreal M] = Matricize('CSV.csv', 100, 2, 51);
XX = Localizer(Xreal, Parameters);

%one shot test
% Xr = Xreal(:,:,2);
% Xp = Xreal(:,:,1);
% CG = DeriveCG(Xr,15);
% Xo = SDPMinimizerRelaxed(CG,Parameters);


% figure;
% hold on
% scatter(Xo(1,:),Xo(2,:),'r','o')
% scatter(Xr(1,:),Xr(2,:),'b','+')
% title('Sample Iteration for Fmincon()')
% legend('Inferred Location','Real Location')
% hold off
% 
% figure;
% hold on
% NORM = (pdist(Xr') - pdist(Xo')) .^ 2;
% NORM = sort(NORM,'descend');
% plot(NORM ,'r')
% hold off

% [Violations InRangeViolation OutofRangeViolation...
%     SpeedViolation] = ValidilityCheck(Xo, Xp, CG, 15, 1.5);


