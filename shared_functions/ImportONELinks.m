function  CGs = ImportONELinks( Filename )
% Opens the ONE Link file: <Time> <CONN> <SrcID> <DstID> <UP/DOWN>
% Returns CGs of dimensions N x N x tm where N is the number of the nodes
% and tm is the maximum time. Value of each entry of CGs is 1 is the link
% is 'UP' and 0 is the link is 'DOWN'
fid = fopen(Filename);

    function Splitted = SplitString(Str)
        Parts = regexp(Str,'\s','split');
        Time = str2double(Parts{1});
        NodeID1 = str2double(Parts{3});
        NodeID2 = str2double(Parts{4});
        Status = Parts{5};
        if (strcmp(Status,'UP') == 1 || strcmp(Status,'up') == 1)
            Status = 1;
        elseif (strcmp(Status,'DOWN') == 1 || strcmp(Status,'down') == 1)
            Status = 0;
        else
            Status = -1;
        end
        Splitted = [Time NodeID1 NodeID2 Status];
    end

CGs = zeros(1,1,1);

while 1
    tline = fgets(fid);
    if(~ischar(tline))
        break
    end
    S = SplitString(tline);
    CGs(S(2),S(3),S(1)) = S(4);
end

fclose(fid);
end

