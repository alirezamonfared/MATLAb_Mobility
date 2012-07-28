function CGOut = ModifyContact( CGIn, CGBase, RDiff )
% This function compares the N x N input CGIn with the base contact trace
% CGBase based on the value of RDiff which is sign(RIn-RBase)

if (nargin < 3)
    RDiff = 0;
end

N = size(CGIn,2);

for i = 1:N
    for j = 1:N
        if (CGBase(i,j) == 1 && RDiff == 1)
            if(CGIn(i,j) ~= 1)
                CGIn(i,j) = 1;
            end
        elseif (CGBase(i,j) == 0 && RDiff == -1)
            if(CGIn(i,j) ~= 0)
                CGIn(i,j) = 0;
            end
        else
            continue
        end
    end
end

CGOut = CGIn;
end

