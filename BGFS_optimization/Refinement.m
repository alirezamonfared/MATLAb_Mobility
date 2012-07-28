function [Xo TR]= Refinement(Xin, Xp, SimPars);

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

%% Objective
    function f = Objective(X)
        f = 0;
        XT = zeros(1,d);
        for i = 1 : N
            XT = Xin(:,i)' * [cos(X(1)) sin(X(1));-sin(X(1)) cos(X(1))];
            XT = XT + [X(2) X(3)];
            P = norm(XT-Xp(:,i)',2);
            f = f + (max(0,(P-Vm)))^2;
        end
    end

%% Optimization

    X0 = [0 0 0]';
   
    options = optimset('Hessian','lbfgs','Display','iter','Hessian',...
        'lbfgs','MaxIter',MaxIter,'LargeScale','on','Algorithm',...
        'active-set');
    
    lb = [0 -Box -Box]';
    ub = [2*pi Box Box]';
    
    tic
    [Tr fval]= fmincon(@Objective,X0,[],[],[],[],lb,ub,[],options);
    fval
    
    
    if nargout > 1
        TR = Tr;
    end
    
    %x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
    Xo = (Xin' * [cos(Tr(1)) sin(Tr(1));-sin(Tr(1)) cos(Tr(1))])';
    Xo = Xo + repmat([Tr(2);Tr(3)],1,N);
end