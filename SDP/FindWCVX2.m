function  Wopt = FindWCVX2(G,npts,solver);

npts = size(G,2)
dim = 2;
if nargin < 3; solver = 'sedumi'; end

cvx_begin sdp
    if strcmp(solver,'sedumi') == 1
        cvx_solver sedumi
    else
        cvx_solver sdpt3
    end
    variable W(npts,npts) symmetric
    minimize(trace(G'*W))
    subject to
        W >= 0
        W <= eye(npts)
        trace(W) == npts - dim
cvx_end

Wopt = W;
end