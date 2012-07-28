%Minizaer
%function  [Xo Uo Vo] = SDPMinimizer(CG, Xp, R, Vm, d, r);
function Xo = SDPMinimizerStacked(CG, Xp, SimPars, Xref);
% Initializations
    N = size(CG,2); % Number of Nodes
    TW = size(CG,3); %Time Window

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
    
    if (~isfield(SimPars,'RefineX'))
        RefineX = false;
    else
        RefineX = SimPars.RefineX;
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
    
    if nargin < 4
        Xref = [];
    end
        
%% Creating an initial guess, if not given
    if (isempty(Xp))
        Xp = SDPMinimizerRelaxed(CG, SimPars);
    end  
%% Objective Function Definition
    function f = Objective(X)
        f = 0;
        % If there are reference points, in-range and out-of-range
        % constraints should be only applied to pairs of nodes
        % where at least one of them is not reference point
        % also speed and box constraints only apply to reference points
        if (~isempty(Xref))
            M = size(Xref,2);
            for tt = 1:TW
                for i = 1:N
                    Xi = X(:,i,tt);
                    for j = i+M:N
                        Xj = X(:,j,tt);
                        Dij = norm(Xi-Xj,2);
                        % In Range Constraints
                        if (CG(i,j,tt) == 1)
                            f = f + ((max(0,(Dij-R)))^2) / W(1);
                            % Out of Range Constraints
                        else
                            f = f + ((min(0,(Dij-R)))^2) / W(2);
                        end
                    end
                    if (i > M)
                        % Speed Constraints
                        size(Xi)
                        if (tt == 1)
                            P = norm(Xi-Xp(:,i),2);
                        else
                            P = norm(Xi-X(:,i,tt-1),2);
                        end
                        f = f + ((max(0,(P-Vm)))^2) / W(3);
                        % Box Constraints
                        for k = 1:d
                            f = f + (min(0,X(k,i,tt))^2) / W(4) +...
                                (max(0,X(k,i,tt)-Box)^2) / W(4);
                        end
                    end
                end
            end
        else
            for tt = 1 : TW
                for i = 1:N
                    Xi = X(:,i,tt);
                    for j = i+1:N
                        Xj = X(:,j,tt);
                        Dij = norm(Xi-Xj,2);
                        % In Range Constraints
                        if (CG(i,j,tt) == 1)
                            f = f + ((max(0,(Dij-R)))^2) / W(1);
                            % Out of Range Constraints
                        else
                            f = f + ((min(0,(Dij-R)))^2) / W(2);
                        end
                    end
                    % Speed Constraints
                    if (tt == 1)
                        P = norm(Xi-Xp(:,i),2);
                    else
                        P = norm(Xi-X(:,i,tt-1),2);
                    end
                    f = f + ((max(0,(P-Vm)))^2) / W(3);
                    
                    % Box Constraints
                    for k = 1:d
                        f = f + (min(0,X(k,i,tt))^2) / W(4) +...
                            (max(0,X(k,i,tt)-Box)^2) / W(4);
                    end
                end
            end
        end       
    end

%% Calling the minimizer
    X0 = zeros(d,N,TW);
    for t = 1:TW
        X0(:,:,t) = Xp;
    end
    if (~isempty(Xref))
        M = size(Xref,2);
        X0(:,1:M,:) = Xref;
    end

    
    options = struct('GradObj','off','Display','iter','LargeScale',...
        'on','HessUpdate','lbfgs','InitialHessType','identity',...
        'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter,...
        'TolFun',1e-3);

    tic
    [Xo fval] = fminlbfgs(@Objective,X0,options);
    toc 
    fval;
    
    if RefineX == true
        disp('Refinement Step')
        [Xo TR]= Refinement(Xo,Xp,SimPars);
        TR
    end


end


