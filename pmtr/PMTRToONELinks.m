function  CG = PMTRToONELinks(InputFilename, OutputFilename);
% input format : <id_source> <id_destination> <t_start_contact>
% <t_end_contact>
if nargin < 2
    OutputFilename = './Inputs/PMTRLinks.one';
end

% Open the pre-processed file: <Time> <SrcID> <DstID> <0/1>
File = dlmread(InputFilename,' ');
N = length(unique(File(:,1))); % Number of nodes
tmin = min(File(:,3));
tm = max(File(:,4) - tmin); % Number of Timesteps
%tm2 = length(unique([File(:,3) File(:,4)]));
NN = size(File,1); % Number of lines of update
%CG = zeros(N,N,tm);
CG = cell(tm,1);
for t = 1:tm
    CG{t} = sparse(N,N);
end
% for l = 1:NN
%     CG(File(l,1),File(l,2),File(l,3)-tmin) = 1;
%     CG(File(l,2),File(l,1),File(l,3)-tmin) = 0;
%     CG(File(l,1),File(l,2),File(l,4)-tmin) = 1;
%     CG(File(l,2),File(l,1),File(l,4)-tmin) = 0;
% end


end