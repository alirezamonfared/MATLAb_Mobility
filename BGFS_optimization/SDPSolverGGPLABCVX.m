% CG = sparse connectivity graph
function  Xo = SDPSolverGGPLAB(CG, Xp, SimPars);
% Initializations
    N = size(CG,2);

    if (~isfield(SimPars,'r'))
        r = 2;
    else
        r = SimPars.r;   
    end
    
    if (~isfield(SimPars,'MaxIter'))
        MaxIter = 30;
    else
        MaxIter = SimPars.MaxIter;
    end
    
    if (~isfield(SimPars,'d'))
        d = 2;
    else
        d = SimPars.d;
    end
    
    if (~isfield(SimPars,'Box'))
        Box = 100;
    else
        Box = SimPars.Box;
    end
    
    if (~isfield(SimPars,'Weighted'))
        Weighted = false;
    else
        Weighted = SimPars.Weighted;
        disp('Weighted mimimization')
    end
    
    Vm = SimPars.Vm;
    R = SimPars.R;
    
    if (Weighted == true)
        W = [sqrt(2)*Box-R ; R ; sqrt(2)*Box-Vm ; 2*Box];
    else
        W = [1 ; 1 ; 1 ; 1];
    end
    

%% CVX Problem
tic
    cvx_clear
    cvx_precision medium
    cvx_begin
        variable X(d, N);
        f = 0;
        % Objective Function
        for i = 1:N
            Xi = X(:,i);
            for j = i+1:N
                Xj = X(:,j);
                Dij = norm(Xi-Xj,2);
                if (CG(i,j) == 0)
                    f = f + pow_pos((Dij-R),2);
                end
            end
        end
        maximize(f)
        subject to
            for i = 1:N
                Xi = X(:,i);
                for j = i+1:N
                    Xj = X(:,j);
                    Dij = norm(Xi-Xj,2);
                    % In Range Constraints
                    if (CG(i,j) == 1)
                        Dij <= R;
                    end
                end
                % Speed Constraints
                P = norm(Xi-Xp(:,i),2);
                P <= Vm;
            end
            X >= zeros(d,N);
            X <= ones(d,N)*Box;
    cvx_end
toc
%% Optimizer
Xo = X;


end