function  EvolvingGraphLog = ExportToOneLinksString(CGs);
% Exports a given Graph adjacency matrix set to ONE link trace
% Option 'EvolvingGraphFormat', makes it suitable for the evolving graph
% code as well

[N N tm] = size(CGs);
EvolvingGraphLog = zeros(N*tm,4);
[i j] = find(CGs(:,:,1)==1);
% Write all up-links from the first graph
k = 1;
for c = 1:length(i)
    if(CGs(i(c),j(c),1)==1)
        EvolvingGraphLog(k,:) = [1 i(c) j(c) 1];
        k = k + 1;
    end
end
% Write all changes from consecutive graphs
for t = 2:tm
    CGChange = xor(CGs(:,:,t-1),CGs(:,:,t));
    [i j] = find(CGChange(:,:)==1);
    for c = 1:length(i)
        if(CGs(i(c),j(c),t)==1)
            EvolvingGraphLog(k,:) = [t i(c) j(c) 1];
            k = k + 1;
        elseif(CGs(i(c),j(c),t)==0)
            EvolvingGraphLog(k,:) = [t i(c) j(c) 0];
            k = k + 1;
        else
            continue;
        end
    end
end           
EvolvingGraphLog(k:end,:) = [];