function  D= FindD(X, dim);

if size(X,1) == dim
    XX = X'*X;
    N = size(XX,2);
    Diag = diag(XX);
    D = ones(N,1)*Diag' + Diag*ones(N,1)' - 2*XX;
else
    N = size(X,2);
    Diag = diag(X);
    D = ones(N,1)*Diag' + Diag*ones(N,1)' - 2*X;
end

end
