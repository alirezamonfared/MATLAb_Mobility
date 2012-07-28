function  CG= DeriveCG(X, R);
% Derives the connectivity graph from the locations
%   X = location matrix: d x N
%   R = trnasmission range
% Returns N x N connectivity graph
    CG = squareform(pdist(X') <= R);
end