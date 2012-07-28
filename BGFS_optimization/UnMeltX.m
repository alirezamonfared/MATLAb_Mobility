%function  [X U V] = UnMeltX(Xin, d, N, r);
function  X  = UnMeltX(Xin, d, N, r);

%     if ~(isequal(size(Xin),[N*d+N*d*r+r 1]))
%         error('Matrix size mismatch');
%         return
%     end
    %size(Xin)
    %N
    %d
    if ~(isequal(size(Xin),[N*d 1]))
        error('Matrix size mismatch');
        return
    end

    for i = 1:d
        for j = 1:N
            X(i,j) = Xin((i-1)*N + j);
        end
    end

%     for i = 1:(d*N)
%         for j = 1:r
%             U(i,j) = Xin(N*d+(i-1)*r+j);
%         end
%     end
% 
%     for i = 1 : r
%         V(i) = Xin(N*d + N*d*r + i);
%     end

end