%Test Initiial Guess

Res = load('Results.mat');
Res = struct2cell(Res);
Res = Res{1};
Xreal = Res{1};
Xinferred = Res{2};

Box = 100;
tm = 50;
Vm = 1.5;
R = 15;
d = 2;

CG = DeriveCG(Xreal(:,:,1),R);

Xo = InitialGuess(CG, R, Vm, d, Box,2);
Xp = Xo;
CG = DeriveCG(Xreal(:,:,2),R);
Xo2 = SDPMinimizer(CG, Xp, R, Vm, d);

[tv irv orv sv] = ValidilityCheck(Xo, Xp, CG, R, Vm)