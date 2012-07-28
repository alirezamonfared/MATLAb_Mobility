%
function  [X N1 d1 tm1 Box1]= Matricize(Filename);
[Path ,Name ,Ext] = fileparts(Filename);

if (strcmp(Ext,'.csv'))
    % Reading hte CSV file
    CSV = csvread(Filename);
    
    % Extracting the lengths
    N = length(unique(CSV(:,1)));
    tm = length(unique(CSV(:,2))) - 1;
    d = size(CSV,2) - 2;
    
    % Initializing X
    X = zeros(d,N,tm+1);
    
    NN = size(CSV,1);
    
    StartsFromZero = 0;
    if (CSV(1,1) == 0)
        StartsFromZero = 1;
    end
    
    for i = 1:NN
        if (StartsFromZero == 1)
            N_tmp = CSV(i,1)+1;
        else
            N_tmp = CSV(i,1);
        end
        t_tmp = CSV(i,2)+1;
        X(:,N_tmp,t_tmp) = CSV(i,3:end);
    end
    
elseif (strcmp(Ext,'.one'))
    File = dlmread(Filename,' ');
    %tm = File(1,2);
    Box = File(1,4);
    File = File(2:end,:);
    
    % Extracting the lengths
    N = length(unique(File(:,2)));
    tm = length(unique(File(:,1))) - 1;
    %if (tm2 ~= tm)
    %    error('One file has errornous time information')
    %end
    d = 2;
    
    % Initializing X
    X = zeros(d,N,tm+1);
    
    NN = size(File,1);
    StartsFromZero = 0;
    if (File(1,2) == 0)
        StartsFromZero = 1;
    end
    
    for i = 1:NN
        if (StartsFromZero == 1)
            N_tmp = File(i,2)+1;
        else
            N_tmp = File(i,2);
        end
        t_tmp = File(i,1)+1;
        X(:,N_tmp,t_tmp) = File(i,3:3+d-1);
    end
       
else
    error('File should be either in CSV or ONE format');
end

if (nargout > 1)
    N1 = N;
    d1 = d;
    tm1 = tm;
    if (exist('Box','var'))
        Box1 = Box;
    else
        Box1 = NaN;
    end
end
    
end