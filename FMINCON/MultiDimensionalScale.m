function  X = MultiDimensionalScale(X, r);
D = squareform(pdist(X'));
opts = statset('Display','Iter');
X = mdscale(D, r,'Criterion','metricstress','Options',opts);
X = X';
end