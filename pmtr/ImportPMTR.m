function  [CG TSeq]= ImportPMTR(Filename, SnapInterval);
% This function takes the ONE file for the link traces
% and a snapshot interval and creates snapshots of the
% connectivity grahp with the given sampling frequency
% in the adjacency matrix form
if nargin < 2
        SnapInterval = 3600;
end

[Path ,Name ,Ext] = fileparts(Filename);
command = sprintf('./PreProcess.sh %s',Filename);
system(command);
% Get the pre-processed filename
Filename = sprintf('%s/%s.txt',Path,Name);

% Open the pre-processed file: <Time> <SrcID> <DstID> <0/1>
File = dlmread(Filename,' ');
N = length(unique(File(:,2))); % Number of nodes
Tm = floor(File(end,1)/SnapInterval); % Number of Timesteps
NN = size(File,1); % Number of lines of update

CG = zeros(N, N, Tm); % 3D graph of connectivities over time
TSeq = zeros(Tm, 1); % "Real" timestamps sequence

% Initializations
i = 1;
CurrentTime = File(i,1);
SynthTimer = CurrentTime;

% Getting snapshots from the opened ONE link file
for t = 1:Tm    
    % fill in the Time sequence
    TSeq(t) = SynthTimer;
    SynthTimer = SynthTimer + SnapInterval;
    % Start with the previous graph structure, add incremental changes to
    % it
    if (t ~= 1)
        CG(:,:,t) = CG(:,:,t-1);
    end
    while (CurrentTime <= SynthTimer)
        % fill in the Connectivity graph
        if(File(i,4) == 1)
            CG(File(i,2),File(i,3),t) = 1;
            CG(File(i,3),File(i,2),t) = 1;
        else
            CG(File(i,2),File(i,3),t) = 0;
            CG(File(i,3),File(i,2),t) = 0;  
        end
        i = i + 1;
        CurrentTime = File(i,1);
    end
end

end
