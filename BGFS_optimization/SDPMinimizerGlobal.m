function Xo = SDPMinimizerGlobal(CG, Xp, SimPars);
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
    
%% Creating an initial guess, if not given
%     if (isempty(Xp))
%         Xp = SDPMinimizerRelaxed(CG, SimPars);
%     end  
%% Objective Function Definition
    function f = Objective(X)
        f = 0;
        for i = 1:N
            Xi = X(:,i);
            for j = i+1:N
                Xj = X(:,j);
                Dij = norm(Xi-Xj,2);
                % In Range Constraints
                if (CG(i,j) == 1)
                    f = f + ((max(0,(Dij-R)))^2) / W(1);
                % Out of Range Constraints    
                else
                    f = f + ((min(0,(Dij-R)))^2) / W(2);
                end
            end
            % Speed Constraints
            P = norm(Xi-Xp(:,i),2);
            f = f + ((max(0,(P-Vm)))^2) / W(3);
            
            % Box Constraints
            for k = 1:d
                f = f + (min(0,X(k,i))^2) / W(4) + (max(0,X(k,i)-Box)^2) / W(4);
            end
        end     
    end

%% Calling the minimizer

    %X0 = Xp;
    
%     options = struct('GradObj','off','Display','iter','LargeScale',...
%         'on','HessUpdate','lbfgs','InitialHessType','identity',...
%         'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter);

    options = optimset('Algorithm','interior-point','Display',...
        'iter','LargeScale','on','HessUpdate','bfgs');
    
    if isempty(Xp)
        Xp = rand(d,N)*Box;
    end
    
    problem = createOptimProblem('fmincon','x0',Xp, 'objective', ...
        @Objective,'lb',zeros(2,N),'ub',ones(2,N)*Box, 'options',options);
    tic
    %[Xo fval] = fminlbfgs(@Objective,X0,options);
    disp('calling global optimizer')
    %[Xo fval] = fmincon(problem);
    gs = GlobalSearch('Display','iter');
    [Xo fval] = run(gs,problem);
    fval
    toc 
    
    


end


