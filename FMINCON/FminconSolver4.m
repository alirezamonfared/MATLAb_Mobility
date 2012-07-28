function  Xo = FminconSolver4(CG, Xp, SimPars);

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

        c = [];
        X = sym('X',[d N]);
        for i = 1:N
            Xi = X(:,i);
            
            for j = i+1:N
                Xj = X(:,j);
                Dij = (Xi-Xj)'*(Xi-Xj);
                if (CG(i,j) == 1)
                    c = [c ; Dij-R];
                else
                    c = [c ; R - Dij];
                end
            end
            P = (Xi-Xp(:,i))'*(Xi-Xp(:,i));
            c = [c ; P - Vm];
        end
    gradc = jacobian(c,X).';
    Constraints = matlabFunction(c,[],gradc,[],'vars',{X});

    lb = zeros(d,N);
    ub = ones(d,N)*Box;
%% Calling the minimizer

    %X0 = Xp(:)';
    X0 = Xp;
    %X0 = ones(N*d);
    

    
    options = optimset('Hessian','lbfgs','Display','iter','Hessian',...
        'lbfgs','MaxIter',MaxIter,'LargeScale','on','Algorithm',...
        'interior-point','GradObj','on','GradConstr','on');
    %,'Algorithm','active-set');
    tic
    [Xo,fval] = fmincon(@Objective,X0,[],[],[],[],lb,ub,Constraints,options);
    toc
    
%     options = struct('GradObj','off','Display','iter','LargeScale',...
%         'on','HessUpdate','lbfgs','InitialHessType','identity',...
%         'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter);


end