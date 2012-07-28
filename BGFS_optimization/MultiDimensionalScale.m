function  X = MultiDimensionalScale(X, r);
D = squareform(pdist(X'));
opts = statset('Display','Iter');
try
    disp('Stress used in MDS')
    X = mdscale(D, r,'Criterion','metricstress','Options',opts);
catch err
    disp('Strain used in MDS')
    X = mdscale(D, r,'Criterion','strain','Options',opts);
end
X = X';
end