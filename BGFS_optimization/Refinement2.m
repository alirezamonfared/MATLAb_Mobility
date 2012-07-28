function Xo = Refinement2(Xin, Xp, CG, SimPars);

% Initilization
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

    N = size(Xp,2);
    Vm = SimPars.Vm;
    R = SimPars.R;

%% Objective
    function f = Objective(X)
        f = 0;
        for i = 1:N
            Xi = X(:,i);
            P = norm(Xi-Xp(:,i),2);
            f = f + ((max(0,(P-Vm)))^2);
        end
    end

%% Constraints function
    function [c, ceq] = Constraints(X)
        c = [];
        for i = 1:N
            Xi = X(:,i);
            for j = i+1:N
                % range constraints
                Xj = X(:,j);
                Dij = norm(Xi-Xj,2);
                if (CG(i,j) == 1)
                    c = [c ; Dij-R]; 
                else
                    c = [c ; R - Dij];
                end
            end
            % box constraints
            for k = 1:d
                c = [c ; (min(0,X(k,i))^2) ; (max(0,X(k,i)-100)^2)];
            end
        end
        ceq = [];
    end

%% Optimization

    X0 = Xp;

    options = optimset('Hessian','lbfgs','Display','iter',...
        'MaxIter',MaxIter,'LargeScale','on','Algorithm','active-set');

    tic
    [Xo,fval] = fmincon(@Objective,X0,[],[],[],[],[],[],@Constraints,options);
    toc

end