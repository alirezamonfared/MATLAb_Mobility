function  Wopt = FindWCVX(Z,npts,solver);

dim = size(Z,2)
if nargin < 3; solver = 'sedumi'; end

cvx_begin sdp
    if strcmp(solver,'sedumi') == 1
        cvx_solver sedumi
    else
        cvx_solver sdpt3
    end
    variable W(dim,dim)
    minimize(trace(Z'*W))
    subject to
        W >= 0
        W <= eye(dim)
        trace(W) == npts
cvx_end

Wopt = W;
end