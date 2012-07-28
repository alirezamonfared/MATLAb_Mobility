function  CGs = MobilityToConatcts(X, R);
% takes a d x N x tm mobility matrix as input and generates a N x N x tm
% contact trace with the specified transmission range as the output
if nargin < 2
    R = 100;
end
[d N tm] = size(X);
CGs = zeros(N,N,tm);
for t = 1:tm
    CGs(:,:,t) = DeriveCG(X(:,:,t),R);
end
end
    
    