function  Xo = FminconRelaxed(CG, SimPars);

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
    
% %% Creating an initial guess, if not given
%     if (isempty(Xp))
%         Xp = SDPMinimizerRelaxed(CG, SimPars);
%     end  
%% Objective Function Definition
    function [f g]= Objective(X)
        f = 0;
        g = 0;
    end

%% Constraints function
    function [c, ceq] = Constraints(X)
        c = [];
        for i = 1:N
            Xi = X(:,i);
            for j = i+1:N
                Xj = X(:,j);
                Dij = norm(Xi-Xj,2);
                if (CG(i,j) == 1)
                    c = [c ; Dij-R]; 
                else
                    c = [c ; R - Dij];
                end
            end       
        end
        ceq = [];
%         for i = 1:d
%             for j = 1:N
%                 c =[c ; -X(i,j)];
%                 c =[c ; X(i,j)-Box];
%             end
%         end
    end

    lb = zeros(d,N);
    ub = ones(d,N)*Box;
%% Calling the minimizer

    %Dist = (ones(N)-eye(N)) * Box;
    %X0 = mdscale(Dist, d+4)';
    X0 = rand(d,N)*Box;

    
    options = optimset('Hessian','lbfgs','Display','iter',...
        'MaxIter',MaxIter,'LargeScale','on','Algorithm','active-set');
    %,'Algorithm','active-set');
    tic
    [Xo,fval] = fmincon(@Objective,X0,[],[],[],[],lb,ub,@Constraints,options);
    toc
    
    Xo = MultiDimensionalScale(Xo, d);
%     options = struct('GradObj','off','Display','iter','LargeScale',...
%         'on','HessUpdate','lbfgs','InitialHessType','identity',...
%         'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter);


end