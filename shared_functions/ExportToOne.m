function ExportToOne(X, filename, Box);
% Exports mobility matrix to ONE file
% Generic Call is ExportToOne(X, filename, Box)
%   X = The matrix to be exported
%   filename = name of the export ONE file
%   Box = size of the simulation field
    if (nargin < 3)
        Box = 1000;
    end
    [d N tm] = size(X);
    fid = fopen(filename, 'w');
    fprintf(fid, '%.1f %.1f %.1f %.1f %.1f %.1f\n',0,tm,0,Box,0,Box);
    for t = 1:tm
        for i = 1:N
            fprintf(fid, '%.1f %d %.14f %.14f\n',t-1,i,X(1,i,t),X(2,i,t));
        end
    end
    fclose(fid);
end
