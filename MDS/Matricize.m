%
function  [X M]= Matricize(CSVFilename, N, d, tm);
CSV = csvread(CSVFilename);
X = zeros(d,N,tm);
M = zeros(d*N, tm);
NN = size(CSV,1);

for i = 1:NN
    N_tmp = CSV(i,1)+1;
    t_tmp = CSV(i,2)+1;
    X(:,N_tmp,t_tmp) = CSV(i,3:end);
    Ds = 1:d;
    M(Ds + (N_tmp-1)*d, t_tmp) = CSV(i,3:end)';
end

