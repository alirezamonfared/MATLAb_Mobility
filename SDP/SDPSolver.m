% CG = sparse connectivity graph
function  [Xopt Gopt] = SDPSolver(R,CG, NNodes, FixedPts, dim, W, solver); 
%%
[nfix dummy] = size(FixedPts);
npts = NNodes + nfix;
if nargin < 5; dim = 3; end
if nargin < 6; W = eye(dim+npts); end
if nargin < 7; solver = 'sedumi'; end

X = sdpvar(dim, npts,'full');
G = sdpvar(npts,npts,'symmetric');
Z = [eye(dim) X ; X' G];
%% Set the general constraints
mm = 0; %counter for the number of constraints

%% Set the semidefiniteness constraint
%Constraints = set(G >= 0);
Constraints = set(Z >= 0);
mm = mm + 1;

%% Set the known locations constraint
if FixedPts ~= []
    mm = mm + 1;
    Constraints = Constraints + set(X(:,npts-nfix+1:npts) == FixedPts);
end

%% Set constraints corresponding to distance measures 
for i = 1:npts
    for j = i+1:npts
        ei = zeros(npts, 1);
        ei(i) = 1;
        ej = zeros(npts, 1);
        ej(j) = 1;
        if (CG(i,j) == 1)  % If distance measure exists          
            mm = mm+1;
            Constraints = Constraints + set(trace(G' * (ei-ej)*(ei-ej)') < R);       
        else
            mm = mm+1;
            Constraints = Constraints + set(trace(G' * (ei-ej)*(ei-ej)') > R);
            continue
        end
        if (i > npts - nfix) 
            mm = mm + 1;
            Constraints = Constraints + set(trace(G'*(ei*ei')) == FixedPts(:, i-NNodes)'*FixedPts(:, i-NNodes));
        end
        if ((i > npts - nfix) && (j > npts - nfix))
            mm = mm + 1;
            Constraints = Constraints + set(trace(G'* (0.5*(ei*ej'+ej*ei'))) == FixedPts(:, i-NNodes)'*FixedPts(:, j-NNodes));
        end
    end
end
%% Set the objective
Objective = trace(Z'*W);
%Objective = trace(Z);
%Objective = X;
%Objective = 0;
%% Solve
Constraints;
Objective;
mm;

if strcmp(solver,'sedumi') == 1
    Options = sdpsettings('solver','sedumi');
else
    Options = sdpsettings('solver','sdpt3');
end

%Options = [];
solvesdp(Constraints, Objective, Options);
Xopt = double(X);
Gopt = double(G);
end