% CG = sparse connectivity graph
function  [Xopt Gopt] = SDPSolverCVX2(R,CG, NNodes, FixedPts, dim, W, solver);

nfix = size(FixedPts, 2);
npts = NNodes + nfix;

if nargin < 5; dim = 3; end
if nargin < 6; W = eye(dim+npts); end
if nargin < 7; solver = 'sedumi'; end

mm = 0;

cvx_begin sdp
    if strcmp(solver,'sedumi') == 1
        cvx_solver sedumi
    else
        cvx_solver sdpt3
    end
    variable X(dim, npts)
    variable G(npts,npts) symmetric
    %Z = [eye(dim) X ; X' G];

    minimize(trace(G'*W))
    subject to
        [eye(dim) X ; X' G] >= 0
        if isempty(FixedPts) == 0
            mm = mm + 1;
            X(:,npts-nfix+1:npts) == FixedPts;
        end
        for i = 1:npts
            for j = i+1:npts
                ei = zeros(npts, 1);
                ei(i) = 1;
                ej = zeros(npts, 1);
                ej(j) = 1;
                if (i <= NNodes && j <= NNodes)
                    if (CG(i,j) == 1)  % If distance measure exists
                        mm = mm+1;
                        trace(G' * (ei-ej)*(ei-ej)') < R;
                    else
                        mm = mm+1;
                        trace(G' * (ei-ej)*(ei-ej)') > R;
                    end
                end
                if (i > NNodes)
                    mm = mm + 1;
                    trace(G'*(ei*ei')) == FixedPts(:, i-NNodes)'*FixedPts(:, i-NNodes);
                end
                if ((i > NNodes) && (j > NNodes))
                    mm = mm + 1;
                    trace(G'* (0.5*(ei*ej'+ej*ei'))) == FixedPts(:, i-NNodes)'*FixedPts(:, j-NNodes);
                end
            end
        end
cvx_end

Xopt = full(X);
Gopt = full(G);

end