function  [X D]= EigenDec(G,dim); 

[V D]=eig(G);
[DD IX]= sort(diag(D),'descend');
D = D(:,IX);
V = V(:,IX);
D = D(1:dim,1:dim);
V = V(:,1:dim);
SD = sqrt(D);
X = SD * V';
XX = X'*X;
N = size(XX,2)
Diag = diag(XX);
D = ones(N,1)*Diag' + Diag*ones(N,1)' - 2*XX;
end