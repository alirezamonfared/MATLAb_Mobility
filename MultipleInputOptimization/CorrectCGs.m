function [CGs Rs] = CorrectCGs(MainCG, MainR, OtherCGs,OtherRs);
% This function gets COtherCGsGs as N x N x NInputs-1 matrics that 
%correspond to all connectivity graphs for different ranges but for a 
% single timestep and their corresponding R transmission Ranges, and also
% receives a MainCG of dimension N xN and its corresponding R for that
% timestep, the function then makes sure all given OtherCGs respect the
% MainCG
CheckCGsValidity(OtherCGs,OtherRs);

NInputs = length(OtherRs) + 1;
N = size(OtherCGs,2);

CGs = zeros(N,N,NInputs);
CGs(:,:,1:NInputs-1) = OtherCGs;
CGs(:,:,NInputs)  = MainCG;
[Rs IX] = sort([OtherRs MainR]);
CGs = CGs(:,:,IX);
MainIndex = find(Rs == MainR);


% Check and correct consistency of the connectivity graphs
for i = 1:N
    for j = 1:N
        if (MainCG(i,j,1) == 1)
            for Input = MainIndex+1: NInputs
                if(CGs(i,j,Input) ~= 1)
                    CGs(i,j,Input) = 1;
                end
            end
        else
            for Input = 1: MainIndex-1
                if(CGs(i,j,Input) ~= 0)
                    CGs(i,j,Input) = 0;
                end
            end
        end
    end
end

CheckCGsValidity(CGs,Rs);

end