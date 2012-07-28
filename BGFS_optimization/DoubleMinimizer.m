function  X = DoubleMinimizer(CG, Xp, R, Vm, d);

r = d;
N = size(CG,2);
d2 = d +2; %higher dimension for first iteration
if nargin < 5; d = 2; end

% make initial solution with zeros in higher dimension
%Xp = [Xp ; zeros(d2-d, N)]; 

%higher dimension minimization

%[Xo Uo Vo] = SDPMinimizer(CG, Xp, R, Vm, d2, r);
%Xo = SDPMinimizer(CG, Xp, R, Vm, d2, r);

%multidiemnsioal sacling
%Xo = MultiDimensionalScale(Xo, d);

%final problem
Xp = Xp(1:d,:);

%[Xo Uo Vo] = SDPMinimizer(CG, Xp, R, Vm, d, r);
Xo = SDPMinimizer(CG, Xp, R, Vm, d, r);


X = Xo;

end