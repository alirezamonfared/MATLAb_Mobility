% CG = sparse connectivity graph
function  [Xopt Gopt] = SDPSolverCVX3(R,CG, dim, solver, niter);

N = size(CG,1);

if nargin < 3; dim = 3; end
if nargin < 4; solver = 'sedumi'; end

mm = 0;
Box = 100;
Wopt = eye(dim+N);
%Wopt = rand(dim+N);

cvx_clear
cvx_precision medium

for iter = 1:niter
    W = Wopt;
    cvx_begin
        if strcmp(solver,'sedumi') == 1
            cvx_solver sedumi
        else
            cvx_solver sdpt3
        end

        variable X(dim, N);
        variable G(N,N) symmetric;

        minimize(trace([eye(dim) X ; X' G]'*W))
        subject to
        %G == semidefinite(N);
        [eye(dim) X ; X' G] == semidefinite(N+dim);
        for i = 1:N
            for j = i+1:N
                ei = zeros(N, 1);
                ei(i) = 1;
                ej = zeros(N, 1);
                ej(j) = 1;
                eij = ei - ej;
                mm = mm + 1;
                if (CG(i,j) == 1)  % If distance measure exists
                    trace(G' * (eij * eij')) <= R;
                else
                    trace(G' * (eij * eij')) >= R;
                end
            end
        end
    
    cvx_end

    Xopt = X;
    Gopt = G;


    Zopt = [eye(dim) Xopt ; Xopt' Gopt];


%     Zopt = full(Zopt);
%     [V D] = eig(Zopt);
%     Q = V(:,dim+1:N+dim);
%     W = Q*Q';
%     RankW = rank(W)
%     RankZ = rank(Zopt)
    
    %Obj = trace([eye(dim) X ; X' G]'*W)
    

    cvx_begin 
        variable W(dim+N,dim+N) symmetric
        minimize(trace(Zopt'*W))
        subject to
            W == semidefinite(dim+N)
            (eye(dim+N) - W) == semidefinite(dim+N)
            trace(W) == N
    cvx_end

    Wopt = W;
end
 
Xopt = Xopt*Box + Box/2;

end