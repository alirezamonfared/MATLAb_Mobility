%Minizaer
%function  [Xo Uo Vo] = SDPMinimizer(CG, Xp, R, Vm, d, r);
function Xo = SpeedMinimizer(CG, Xp, SimPars, Xref);
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
    
    % If given, dt denotes the time difference from the previous event
    % in an asynchronized trace
    if (~isfield(SimPars,'dt'))
        dt = 1;
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
        Xp = SpeedMinimizerRelaxed(CG, SimPars);
    end  
%% Objective Function Definition
    function f = Objective(V)
        f = 0;
        % If there are reference points, in-range and out-of-range
        % constraints should be only applied to pairs of nodes
        % where at least one of them is not reference point
        % also speed and box constraints only apply to reference points
        if (~isempty(Xref))
            M = size(Xref,2);
            for i = 1:N
                Xi = Xp(:,i) + V(:,i) .* dt;
                for j = i+M:N
                    Xj = Xp(:,j) + V(:,j) .* dt;
                    Dij = norm(Xi-Xj,2);
                    % In Range Constraints
                    if (CG(i,j) == 1)
                        f = f + ((max(0,(Dij-R)))^2) / W(1);
                    % Out of Range Constraints
                    else
                        f = f + ((min(0,(Dij-R)))^2) / W(2);
                    end
                end
                if (i > M)
                    % Speed Constraints
                    Vi = norm(V(:,i),2);
                    f = f + ((max(0,(Vi-Vm)))^2) / W(3);
                    % Box Constraints
                    for k = 1:d
                        f = f + (min(0,Xi(k))^2) / W(4) +...
                            (max(0,Xi(k)-Box)^2) / W(4);
                    end
                end
            end
        else
            for i = 1:N
                Xi = Xp(:,i) + V(:,i) .* dt;
                for j = i+1:N
                    Xj = Xp(:,j) + V(:,j) .* dt;
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
                Vi = norm(V(:,i),2);
                f = f + ((max(0,(Vi-Vm)))^2) / W(3);
                
                % Box Constraints
                for k = 1:d
                    f = f + (min(0,Xi(k))^2) / W(4) +...
                            (max(0,Xi(k)-Box)^2) / W(4);
                end
            end
        end      
    end

%% Calling the minimizer

    %X0 = Xp(:)';
    V0 = zeros(2,N);
    %X0 = ones(N*d);
    
    %options = optimset('LargeScale','on','Display','iter');
    %[Xo,fval] = fminunc(@Objective,X0,options);
    %fval
    
    %options = optimset('Hessian',{'bfgs'});
    %[Xo,fval] = fmincon(@Objective,X0,0,0,0,0,0,0,0, options);
    
     options = struct('GradObj','off','Display','iter','LargeScale',...
         'on','HessUpdate','lbfgs','InitialHessType','identity',...
         'GoalsExactAchieve',0,'GradConstr',true,'MaxIter',MaxIter);


    tic
     [Vo fval] = fminlbfgs(@Objective,V0,options);
    toc 
    fval;
    
    Xo = Xp + Vo .* dt;

end


