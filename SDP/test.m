%Handwritten test
%SDPSolver Example
CG = [0 1 0;1 0 1;0 1 0];
R = 1;
dim = 2;
FixedPts = [];
NNodes = 3;
niter = 1;
%Wopt = eye(dim+NNodes);
Wopt = zeros(dim+NNodes); 
solver = 'sdpt3'


cvx_begin 
    if strcmp(solver,'sedumi') == 1
        cvx_solver sedumi
    else
        cvx_solver sdpt3
    end
    
    variable X(2, 3)
    variable G(3,3) symmetric
    Z = [eye(2) X ; X' G];

    minimize(trace(Z'*Wopt))
    subject to
        Z == semidefinite(dim+NNodes);
        ei = [1; 0; 0];
        ej = [0; 1; 0];
        trace(G' * (ei-ej)*(ei-ej)') == 1;
        ei = [1; 0; 0];
        ej = [0; 0; 1];
        trace(G' * (ei-ej)*(ei-ej)') == 10;
        ei = [0; 1; 0];
        ej = [0; 0; 1];
        trace(G' * (ei-ej)*(ei-ej)') == 9;
cvx_end

X
G