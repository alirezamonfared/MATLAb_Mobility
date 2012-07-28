function Xo = SDPMinimizerSDPMinimizerStackedRelaxed(CG, SimPars, Xref);
%No speed Constraint

%% Initializations
    N = size(CG,2); % Number of Nodes
    TW = size(CG,3); %Time Window
    
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
    end
     
    R = SimPars.R;
    
    if (Weighted == true)
        W = [sqrt(2)*Box-R ; R ; 2*Box];
    else
        W = [1 ; 1 ; 1];
    end
    
    if nargin < 4
        Xref = [];
    end
    

%% Objective Function
  
    function f = Objective(X)
        f = 0;
        if (~isempty(Xref))
            M = size(Xref,2);
            for t = 1 : TW
                for i = 1:N
                    Xi = X(:,i,t);
                    for j = i+M:N
                        Xj = X(:,j,t);
                        Dij = norm(Xi-Xj,2);
                        % In Range Constraints
                        if (CG(i,j,t) == 1)
                            f = f + ((max(0,(Dij-R)))^2) / W(1);
                            % Out of Range Constraints
                        else
                            f = f + ((min(0,(Dij-R)))^2) / W(2);
                        end
                    end
                    if (i > M)
                        % Box Constraints
                        for k = 1:d
                            f = f + (min(0,X(k,i,t))^2) / W(3) +...
                                (max(0,X(k,i,t)-Box)^2) / W(3);
                        end
                    end
                end
            end
        else
            for t = 1 : TW
                for i = 1:N
                    Xi = X(:,i,t);
                    for j = i+1:N
                        Xj = X(:,j,t);
                        Dij = norm(Xi-Xj,2);
                        if (CG(i,j,t) == 1)
                            f = f + ((max(0,(Dij-R)))^2) / W(1);
                            
                        else
                            f = f + ((min(0,(Dij-R)))^2) / W(2);
                        end
                    end
                    for k = 1:d
                        f = f + (min(0,X(k,i,t))^2) / W(3) +...
                            (max(0,X(k,i,t)-Box)^2) / W(3);
                    end
                end
            end
        end
    end


%% Generating Xp

    dp = d + 4;
    Dist = (ones(N)-eye(N)) * R;
    opts = statset('Display','Iter');
    Xpt = mdscale(Dist, dp,'Criterion','metricstress','Options',opts)';
    for t = 1 : TW
        Xp(:,:,t) = Xpt;
    end
    %size(Xp)
    %Xp = Xp(1:d,:);
    %Xp = rand(d, N) * Box;
    if (~isempty(Xref))
        M = size(Xref,2);
        Xp(:,1:M) = Xref;
    end
    
%% Calling the minimizer

    options = struct('GradObj','off','Display','iter','LargeScale',...
        'on','HessUpdate','lbfgs','InitialHessType','identity',...
        'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter);

    tic
    [Xp1 fval] = fminlbfgs(@Objective,Xp,options);
    toc 
    
    for t = 1 : TW
        Xp1(:,:,t) = MultiDimensionalScale(Xp1(:,:,t), d);
    end
    
    tic
    [Xo fval] = fminlbfgs(@Objective,Xp1,options);
    toc 

end
