function Xo = SDPMinimizerRelaxedMultiInput(CGs, SimPars, Xref);
%No speed Constraint

%% Initializations
    N = size(CGs,2);
    NInputs = size(CGs,3); % number of Inputs;
   
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
    
    if (~isfield(SimPars,'Weighted'))
        Weighted = false;
    else
        Weighted = SimPars.Weighted;
    end
     
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
    
    W = ones(3,NInputs);
    if (Weighted == true)
        for it = 1:NInputs
            W(:,it) = [sqrt(2)*Box-R(it) ; R(it) ; 2*Box];
        end
    end
    
    if nargin < 4
        Xref = [];
    end

%% Objective Function
  
    function f = Objective(X)
        f = 0; 
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
                % Box constraints
                for k = 1:d
                    f = f + (min(0,X(k,i))^2) / W(3) + (max(0,X(k,i)-Box)^2) / W(3,1);
                end
            end
        end
        
    end


%% Generating Xp

    dp = d + 4;
    Dist = (ones(N)-eye(N)) * R(1);
    opts = statset('Display','Iter');
    try
        disp('Stress used in MDS')
        Xp = mdscale(Dist, dp,'Criterion','metricstress','Options',opts)';
    catch err
        disp('Strain used in MDS')
        Xp = mdscale(Dist, dp,'Criterion','strain','Options',opts)';
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
    
    Xp1 = MultiDimensionalScale(Xp1, d);
    
    tic
    [Xo fval] = fminlbfgs(@Objective,Xp1,options);
    toc 

end
