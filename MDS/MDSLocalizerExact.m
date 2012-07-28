
function [Xo XLoc2 TR] = MDSLocalizerExact(D, Xa, SimPars);

% Initializations
    N = size(D,1);
   
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

    if (~isfield(SimPars,'AnchorIndex'))
        idx = [1;2];
    else
        idx = SimPars.AnchorIndex;
    end

%% Building the 'prioximity' matrix
    D2 = D.^2;

%% MDS Parameters buildup
    J=eye(N)-ones(N)/N;
    H=-0.5*J*D2*J;
    [U S V]=svd(H);
    XLoc = (U(:,1:d)*S(1:d,1:d)^0.5)';
    
    if nargout > 1
        XLoc2 = XLoc;
    end

%% Objective Function Definition
    function f = Equations(X)
        XX = XLoc(:,idx);
        f = [cos(X(1)) -sin(X(1));sin(X(1)) cos(X(1))]*XX +...
            repmat([X(2) ; X(3)],1, size(idx,1)) - Xa;
    end

%% Solve
    x0 = [0;0;0];           % Make a starting guess at the solution
    options=optimset('Display','iter');   % Option to display output
    [Tr, fval] = fsolve(@Equations,x0,options);  % Call solver
%% Apply Transformation
    %x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
    Xo = ([cos(Tr(1)) sin(Tr(1));-sin(Tr(1)) cos(Tr(1))] * XLoc) +...
        repmat([Tr(2) ; Tr(3)],1, N);
    toc
    
    if nargout > 2
       	TR = Tr;
    end
    
end
