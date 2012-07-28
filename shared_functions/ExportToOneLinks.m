function  ExportToOneLinks(CGs, filename,EvolvingGraphFormat);
% Exports a given Graph adjacency matrix set to ONE link trace
% Option 'EvolvingGraphFormat', makes it suitable for the evolving graph
% code as well
if nargin < 3
    EvolvingGraphFormat = 0;
end
[N N tm] = size(CGs);
fid = fopen(filename, 'w');
[i j] = find(CGs(:,:,1)==1);
% Write all up-links from the first graph
for c = 1:length(i)
    if(CGs(i(c),j(c),1)==1)
        if(~EvolvingGraphFormat)
            line = sprintf('%.1f CONN %d %d UP\n',1,i(c),j(c));
        else
            line = sprintf('%.2f CONN %d %d UP\n',1,i(c),j(c));
        end
        fprintf(fid,line);
    end
end
% Write all changes from consecutive graphs
for t = 2:tm
    CGChange = xor(CGs(:,:,t-1),CGs(:,:,t));
    [i j] = find(CGChange(:,:)==1);
    for c = 1:length(i)
        if(CGs(i(c),j(c),t)==1)
            if(~EvolvingGraphFormat)
                line = sprintf('%.1f CONN %d %d UP\n',t,i(c),j(c));
            else
                line = sprintf('%.2f CONN %d %d UP\n',t,i(c),j(c));
            end
            fprintf(fid,line);
        elseif(CGs(i(c),j(c),t)==0)
            if(~EvolvingGraphFormat)
                line = sprintf('%.1f CONN %d %d DOWN\n',t,i(c),j(c));
            else
                line = sprintf('%.2f CONN %d %d DOWN\n',t,i(c),j(c));
            end
            fprintf(fid,line);
        else
            if(~EvolvingGraphFormat)
                line = sprintf('%.1f CONN %d %d NA\n',t,i(c),j(c));
            else
                line = sprintf('%.2f CONN %d %d NA\n',t,i(c),j(c));
            end
            fprintf(fid,line);
        end
    end
end           
fclose(fid);