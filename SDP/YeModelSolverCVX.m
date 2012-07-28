%Ye Model, CVX
function  [Xopt Gopt AlphaOpt] = YeModelSolver(R,CG, NNodes, FixedPts, dim, solver);

nfix = size(FixedPts, 2);
npts = NNodes;


if nargin < 4; dim = 3; end
if nargin < 5; W = eye(dim+npts); end
if nargin < 6; solver = 'sedumi'; end

One = ones(npts+nfix,1);
Lambda = 1;

mm = 0;

cvx_begin sdp
    if strcmp(solver,'sedumi') == 1
        cvx_solver sedumi
    else
        cvx_solver sdpt3
    end
    
    variable X(dim, npts)
    variable G(npts,npts) symmetric
    variable Alpha(npts+nfix,npts+nfix) symmetric
    Z = [eye(dim) X ; X' G];
    if isempty(FixedPts) == 0
        a = sum(FixedPts,2)./sqrt(npts+nfix);
    else
        a = zeros(dim,1);
    end
    ee = ones(npts,1)./sqrt(npts+nfix);
    E = [ee;a];

    minimize(trace(Alpha*One*One') - Lambda*trace(Z'*(eye(npts+dim)-E*E')));
    %- Lambda*trace(Z'*(eye(npts+dim)-E*E'))
    subject to
        Z >= 0
        Zero = zeros(npts,1);
        E = [1;0;Zero];
        trace(Z'*(E*E')) == 1;
        E = [0;1;Zero];
        trace(Z'*(E*E')) == 1;
        E = [1;1;Zero];
        trace(Z'*(E*E')) == 2;
        E = ones(npts,1);
        E'*G*E == 0;
        
        for i = 1 : npts+nfix
            for j = 1 : npts+nfix
                Alpha(i,j) >= 0;
            end
        end
        
        
        if isempty(FixedPts) == 0
            for k = 1 : nfix
                for j = npts+1 : npts+nfix
                    ak = FixedPts(:,k);
                    ej = zeros(npts, 1);
                    ej(j) = 1;
                    E = [ak;ej];
                    if (CG(k+npts,j) == 1)  % If distance measure exists
                        mm = mm+1;
                        trace(Z'*(E*E')) <= R + Alpha(k+npts,j);
                    else
                        mm = mm+1;
                        trace(Z'*(E*E')) >= R - Alpha(k+npts,j);
                    end
                    %Alpha(k+npts,j) >= 0;
                end
            end
        end
        Zero = zeros(dim,1);
        for i = 1:npts
            for j = i+1:npts
                ei = zeros(npts, 1);
                ei(i) = 1;
                ej = zeros(npts, 1);
                ej(j) = 1;
                E = [Zero; (ei-ej)]
                if (CG(i,j) == 1)  % If distance measure exists
                    mm = mm+1;
                    trace(Z'*(E*E')) <= R + Alpha(i,j);
                else
                    mm = mm+1;
                    trace(Z'*(E*E')) >= R - Alpha(i,j);
                end
                %Alpha(i,j) >= 0;
            end
        end
cvx_end

Xopt = X;
Gopt = G;
if nargout > 2; AlphaOpt = Alpha; end

end

