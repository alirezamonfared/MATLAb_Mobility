
function [Xo XLoc2 TR] = MDSLocalizer(CG, Xp, SimPars);

% Initializations
    N = size(CG,2);
   
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
        
    Vm = SimPars.Vm;
    R = SimPars.R;
   
%% Building the 'prioximity' matrix
    CG = CG .* R;
    DIST = graphallshortestpaths(sparse(CG));
    DIST(find(DIST == Inf)) = Box*sqrt(2);

%% MDS Parameters buildup
    J=eye(N)-ones(N)/N;
    H=-0.5*J*DIST.^2*J;
    [V S T]=svd(H);
    XLoc=T*sqrt(S);
    XLoc=XLoc(:,1:2)';
    
    if nargout > 1
        XLoc2 = XLoc;
    end

%% Finding the best affine transformation
%% Objective Function Definition
    function f = Objective(X)
        f = 0;
        XT = zeros(1,d);
        for i = 1 : N
            XT = XLoc(:,i)' * [X(1)*cos(X(3)) X(2)*sin(X(4));-X(1)*sin(X(3)) X(2)*cos(X(4))];
            XT = XT + [X(5) X(6)];
            P = norm(XT-Xp(:,i)',2);
            f = f + (max(0,(P-Vm)))^2;
            % Box Constraints      
%             for k = 1:d
%                 f = f + (min(0,XT(k))^2) + (max(0,XT(k)-Box)^2);
%             end
        end
    end
%% Constraints Function
    function [c ceq] = Constraints(X)
        ceq = [];
        c = [];
        for i = 1 : N
            XT = XLoc(:,i)' * [X(1)*cos(X(3)) X(2)*sin(X(4));-X(1)*sin(X(3)) X(2)*cos(X(4))];
            c = [c ; -XT ; XT - [Box Box]];
        end
    end
%% Optimization
    X0 = rand() .* [1 1 2*pi 2*pi Box Box]';
   
    options = optimset('Hessian','lbfgs','Display','iter','Hessian',...
        'lbfgs','MaxIter',MaxIter,'LargeScale','on','Algorithm',...
        'active-set');
    
    lb = [0 0 0 0 -Box -Box]';
    ub = [Box Box 2*pi 2*pi Box Box]';
    
    tic
    [Tr fval]= fmincon(@Objective,X0,[],[],[],[],lb,ub,@Constraints,options);
    fval
    
    if nargout > 2
        TR = Tr;
    end
    %x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
    Xo = (XLoc' * [Tr(1)*cos(Tr(3)) Tr(2)*sin(Tr(4));-Tr(1)*sin(Tr(3)) Tr(2)*cos(Tr(4))])';
    toc
end
