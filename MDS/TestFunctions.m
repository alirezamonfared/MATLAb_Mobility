%MDS
clear all
clc
[Xreal M] = Matricize('CSV.csv', 100, 2, 51);

Parameters = struct('R',15,'Vm',1.5, 'InitLoc',true,'Box',100);
R = Parameters.R;

Xr = Xreal(:,:,6);
Xp = Xreal(:,:,5);
CG = DeriveCG(Xr,R);


%[XLoc XLocP TR] = MDSLocalizer(CG, Xp, Parameters);

%% Compare
%     CGR = DeriveCG(Xr,R);
%     CG2 = DeriveCG(XLoc,R);
%     CGDiff = size(find(CGR-CG2 ~= 0),1) / size(CG,2)^2
% 
%     figure(1);
%     DistReal = squareform(pdist(Xr'));
%     DistInferred = squareform(pdist(XLoc'));
%     DisNorm = norm(DistReal-DistInferred,'fro')
%     DistDiff = sort(reshape(abs(DistReal-DistInferred),1,size(DistReal,2)^2),'descend');
%     plot(DistDiff);
    
%% ValideityCheck
[Violations InRangeViolation OutofRangeViolation...
    SpeedViolation] = ValidilityCheck(XLocP, Xp, CG, R, Parameters.Vm)

%% Manual MDS
% DIST = DIST .^ 2;
% RMean = repmat(mean(DIST,1),N,1);
% CMean = repmat(mean(DIST,2),1,N);
% Mean = repmat(mean(mean(DIST,1)),N,N);
% DIST = DIST - RMean - CMean + Mean;
% [VEig Eig] = eig(DIST);
% Eig = diag(Eig);
% [Eig idx] = sort(Eig,'descend');
% Eig = diag(Eig);
% VEig = VEig(:,idx);
% Eig = Eig(1:d,1:d);
% VEig = VEig(:,1:d);
% XLocM = (VEig * (Eig .^ 0.5))';

%% Compare
%     CGR = DeriveCG(Xr,R);
%     CG2 = DeriveCG(XLocM,R);
%     CGDiff = size(find(CGR-CG2 ~= 0),1) / size(CG,2)^2
%     
%     figure(2)
%     DISTR = squareform(pdist(Xr'));
%     DIST2 = squareform(pdist(XLocM'));
%     DISTNorm = norm(DISTR-DIST2,'fro')
%     DISTDiff = sort(reshape(abs(DIST-DIST2),1,size(DIST,2)^2),'descend');
%     plot(DISTDiff);

%%
% DIST = graphallshortestpaths(G);
% opts = statset('Display','Iter');
% XLocMDS = mdscale(DIST,d,'Criterion','metricstress','Options',opts)';

  

