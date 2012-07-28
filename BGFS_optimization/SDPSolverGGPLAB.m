% CG = sparse connectivity graph
function  Xo = SDPSolverGGPLAB(CG, Xp, SimPars);
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
    

%% GGPLAB Problem
gpvar X1(N) X2(N)
f = 0;
for i = 1:N
    Xi = [X1(i);X2(i)];
    for j = i+1:N
        Xj_ = [(-1)*X1(j);(-1)*X2(j)];
        Dij = (Xi+Xj_)'*(Xi+Xj_);
        % In Range Constraints
        if (CG(i,j) == 1)
            f = f + ((max(0,(Dij-R))).^2) / W(1);
            % Out of Range Constraints
        else
            f = f + ((min(0,(Dij-R))).^2) / W(2);
        end
    end
    % Speed Constraints
    P = (Xi-Xp(:,i))'*(Xi-Xp(:,i));
    f = f + ((max(0,(P-Vm)))^2) / W(3);
end


constarints = zeros(2*N,1);
for i = 1:2*N
    constarints(i) = X1(i) <= Box;
    constarints(i+1) = -X1(i) <= 0;
end




[obj_value, solution, status] = gpsolve(f, constarints);
status
obj_value
assign(solution);
Xo = [X1 ; X2];




end