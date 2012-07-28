%Minizaer
function Xo = SDPMinimizerMultiInput(CGs, Xp, SimPars, Xref);
% This version of the optimizer takes multiple outputs,in this case R is
% also a vecotr consisting of transmission range values
% If the option 'Transformation' is on, then we need the index of the R and CG
% corresponding to the main input, as given in the 'MainInputIndex' option
% Initializations
    N = size(CGs,2);
    NInputs = size(CGs,3); % number of Inputs;
    

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
    
    if (~isfield(SimPars,'Epsilon'))
        Epsilon = 0;
    else
        Epsilon = SimPars.Epsilon;
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
    
    if (size(CGs,3) ~= length(SimPars.R))
        error('Number of Contact traces does not match the number of Transmission ranges')
    else
        R = SimPars.R;
        % Make sure inouts are sorted in asnending order of transmission
        % range
        if (~isfield(SimPars,'Transformation'))
            SimPars.Transformation = 0;
        elseif (SimPars.Transformation == 1)
            MainCG = CGs(:,:,SimPars.MainInputIndex);
            MainR = R(SimPars.MainInputIndex);
            OtherCGs = CGs;
            OtherRs = R;
            OtherRs(SimPars.MainInputIndex) = [];
            OtherCGs(:,:,SimPars.MainInputIndex) = [];
            [CGs R] = CorrectCGs(MainCG, MainR, OtherCGs,OtherRs);
        else 
            SimPars.Transformation = 0;
        end
        [R IX] = sort(R);
        CGs = CGs(:,:,IX);
    end
    
    W = ones(4,NInputs);
    if (Weighted == true)
        for it = 1:NInputs
            W(:,it) = [sqrt(2)*Box-R(it) ; R(it) ; sqrt(2)*Box-Vm ; 2*Box];
        end
    end
    
    if nargin < 4
        Xref = [];
    end
        
%% Creating an initial guess, if not given
    if (isempty(Xp))
        Xp = SDPMinimizerRelaxedMultiInput(CGs, SimPars);
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
            for i = 1:N
                Xi = X(:,i);
                for j = i+M:N
                    Xj = X(:,j);
                    Dij = norm(Xi-Xj,2);
                    % In Range Constraints
                    for c = 1 : NInputs
                        if (CGs(i,j,c) == 1)
                            f = f + ((max(0,(Dij-R(c)*(1-Epsilon))))^2) / W(1,c);
                            break
                        end
                    end
                    % Out of Range Constraints
                    for c = NInputs : -1 : 1
                        if (CGs(i,j,c) == 0)
                            f = f + ((min(0,(Dij-R(c)*(1+Epsilon))))^2) / W(2,c);
                            break
                        end
                    end
                end
                if (i > M)
                    % Speed Constraints
                    P = norm(Xi-Xp(:,i),2);
                    f = f + ((max(0,(P-Vm)))^2) / W(3,1);
                    % Box Constraints
                    for k = 1:d
                        f = f + (min(0,X(k,i))^2) / W(4,1) +...
                            (max(0,X(k,i)-Box)^2) / W(4,1);
                    end
                end
            end
        else
            for i = 1:N
                Xi = X(:,i);
                for j = i+1:N
                    Xj = X(:,j);
                    Dij = norm(Xi-Xj,2);
                    % In Range Constraints
                    for c = 1 : NInputs
                        if (CGs(i,j,c) == 1)
                            f = f + ((max(0,(Dij-R(c)*(1-Epsilon))))^2) / W(1,c);
                            break
                        end
                    end
                    % Out of Range Constraints
                    for c = NInputs : -1 : 1
                        if (CGs(i,j,c) == 0)
                            f = f + ((min(0,(Dij-R(c)*(1+Epsilon))))^2) / W(2,c);
                            break
                        end
                    end
                end
                % Speed Constraints
                P = norm(Xi-Xp(:,i),2);
                f = f + ((max(0,(P-Vm)))^2) / W(3,1);
                
                % Box Constraints
                for k = 1:d
                    f = f + (min(0,X(k,i))^2) / W(4,1) +...
                        (max(0,X(k,i)-Box)^2) / W(4,1);
                end
            end
        end
%         M = X(1:N*d);
%         for i = 1:(d*N)
%             for j = 1:r
%                 U(i,j) = X(N*d+(i-1)*r+j);
%             end
%         end
%         
%         for i = 1 : r
%             V(i) = X(N*d + N*d*r + i);
%         end
%         
%         alpha = 0.1;
%         f = f + alpha * norm(M - U*V','fro');       
    end

%% Calling the minimizer

    %X0 = Xp(:)';
    X0 = Xp;
    if (~isempty(Xref))
        M = size(Xref,2);
        X0(:,1:M) = Xref;
    end
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
    [Xo fval] = fminlbfgs(@Objective,X0,options);
    toc 
    fval;
    
    if RefineX == true
        disp('Refinement Step')
        [Xo TR]= Refinement(Xo,Xp,SimPars);
        TR
    end

    %[Xo Uo Vo] = UnMeltX(XX, d, N, r);
    %Xo = UnMeltX(XX, d, N, r);
    %Xo = reshape(XX,d,N);

end
