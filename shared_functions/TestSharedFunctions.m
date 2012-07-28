 [Xreal, N, d, tm, Box] = Matricize('/home/alireza/workspace/MobilityProject/Java/examples/plausible/rwp1/CSV4Original.one');
 R=100;
 t = 2;
 CGReal = DeriveCG(Xreal(:,:,t),R);
 addpath('/home/alireza/Applications/gaimc(MATLABGRAPHS)')
 cc=clustercoeffs(CGReal);