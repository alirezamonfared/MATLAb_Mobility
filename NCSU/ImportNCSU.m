function  X  = ImportNCSU( InputFolder, NamePattern, NNodes)

Initialized = 0;
for i = 1:NNodes
    FileName = sprintf('./%s/%s_%.3d.txt',InputFolder, NamePattern, i);
    M = dlmread(FileName,'\t');
    TMax = length(unique(M(:,1)));
    if(~Initialized)
        tm = length(unique(M(:,1)));
        X = zeros(2,NNodes,tm);
        Initialized = 1;
    end
    tm = min(tm,TMax);
    for t = 1:TMax
        X(1,i,t) = M(t,2);
        X(2,i,t) = M(t,3);
    end
end
X = X(:,:,1:tm);

end

