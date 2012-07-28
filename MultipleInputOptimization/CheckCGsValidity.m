function CheckCGsValidity(CGs,Rs);
% This function gets CGs as N x N x NInputs matrics that correspond to all
% connectivity graphs for different ranges but for a single timestep and
% perfroms all checks on these connectivity graphs to make sure they are
% flawless
NInputs = length(Rs);
N = size(CGs,2);

% check squaredness
if (N ~= size(CGs,1))
    error('Input adjacency matrix should be square')
end

% check consistency of R vand CGs
if (size(CGs,3) ~= NInputs)
    error('Number of Contact traces does not match the number of Transmission ranges')
end

% Check symmetry
for it = 1 : NInputs
    if(CGs(:,:,it) ~= CGs(:,:,it)')
            error('Input adjacency matrix should be symmetric')
    end
end

%sort adjacencies
[Rs IX] = sort(Rs);
CGs = CGs(:,:,IX);

% Check consistency of the connectivity graphs
for i = 1:N
    for j = 1:N
        InRangeFlag = 0;
        OutofRangeFlag = 0;
        for it = 1 : NInputs
            if(CGs(i,j,it) == 1)
                InRangeFlag = 1;
            end
            if(CGs(i,j,it) == 0 && InRangeFlag == 1)
               error('Impossible case: Connected with smaller range, disconnected with larger range') 
            end
        end
        for it = NInputs : -1 : 1
            if(CGs(i,j,it) == 0)
                OutofRangeFlag = 1;
            end
            if(CGs(i,j,it) == 1 && OutofRangeFlag == 1)
                error('Impossible case: Disonnected with larger range, connected with smaller range')
            end
        end
    end
end

disp('Success: Connectivity graphs are consistent')
    
end