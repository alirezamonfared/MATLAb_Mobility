function Xinf = FeedbackOptimizationWrapper(InputFile, Parameters)

addpath('../BGFS_optimization')
addpath('../shared_functions')
addpath('../BGFS_optimization/fminlbfgs_version2c')
%% Initializations, Defaul values
% IsMobility == 1 means that the input is a ONE mobility trace file
% IsMobility == 0 means that the input is a ONE link trace file
% IsMobility == 2 is reserved for pmtr fed as a ONE link trace file
if (~isfield(Parameters,'IsMobility'))
    IsMobility = 1;
else
    IsMobility = Parameters.IsMobility;
end

RVector = Parameters.RVector;

if (~isfield(Parameters,'MainInputIndex'))
    MainR = RVector(1);
    MainInputIndex = 1;
else
    MainR = RVector(Parameters.MainInputIndex);
    MainInputIndex = Parameters.MainInputIndex;
end

if (~isfield(Parameters,'Vm'))
    Vm = 10;
else
    Vm = Parameters.Vm;
end

if (~isfield(Parameters,'Vm'))
    Box = 1000;
else
    Box = Parameters.Box;
end

if (~isfield(Parameters,'Depth'))
    Depth = 1;
else
    Depth = Parameters.Depth;
end

Breadth = length(RVector);

Parameters.Date = datestr(now);
Parameters.InputFile = InputFile;

if (~isfield(Parameters,'DestFolder'))
    DestFolder = 'Results';
else
    DestFolder = Parameters.DestFolder;
end

if (~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end

[Path Name Ext]=fileparts(InputFile);
%% Deriving the Input Link Trace
if (IsMobility == 1)
    [Xreal, N, d, tm, Box] = Matricize(InputFile);
    CGReal = MobilityToConatcts(Xreal, MainR);
elseif (IsMobility == 0)
    CGReal = ImportONELinks(InputFile);
    d = 2;
elseif (IsMobility == 2)
    addpath('../pmtr/')
    [CGReal Tseq] = ImportPMTR(InputFile);
    d = 2;
else
    error('Illegal value for IsMobility')
end

N = size(CGReal,1);
tm = size(CGReal,3);
Parameters.dim = d;
Parameters.NNodes = N;
Parameters.tm = tm;

%% Filling in the SimPars for Localizer
SimPars = struct('R',MainR,'Vm',Vm, 'InitLoc', false,'Weighted',true,...
    'Box',Box, 'RefineX',false,'MaxIter',300,'Epsilon',0,...
    'Transformation',0,'MainInputIndex',1);
 
SimPars.dim = d;
SimPars.N = N;
SimPars.tm = tm;
SimPars.Date = datestr(now);

SimPars.InputFile = InputFile;

% Reference Points
% Use reference points, if any
NRef = 0;
if (NRef ~= 0 && ISMobility)
    XRef = Xreal(:,1:NRef,:);
else
    XRef = [];
end

SimPars.NRef = NRef;
Parameters.NRef = NRef;
%% First-level Run
% In this level we run the optimization with the original input contact
% trace, the result will be an output mobility trace to be used for the
% next level of the feedback
CGsIn = zeros(size(CGReal,1),size(CGReal,2),1,size(CGReal,3));
CGsIn(:,:,1,:) = CGReal;

Xinf = LinkLocalizerMultiInput(CGsIn, SimPars, XRef);

disp('First Level Run Finished, starting the feedback loop')
%% Second level Run, Feedback loop
SimPars.R = RVector;
SimPars.MainInputIndex = MainInputIndex;
SimPars.Transformation = 1;
for L = 1:Depth
    CGsIn = zeros(N,N,Breadth,tm);
    % First NInputs -1 inputs come from Xinf (output of previous step) with
    % given value of R
    for it = 1:Breadth
        for t=1:tm
            CGsIn(:,:,it,t) = DeriveCG(Xinf(:,:,t),RVector(it));
        end
    end
    % Last input is the origianl contact trace given as input
    CGsIn(:,:,SimPars.MainInputIndex,:) = CGReal(:,:,2:end);
    % Enable the correction of CGs for the inconsistent inputs
    SimPars.Transformation = 1;
    % Call the main localizer
    Xinf = LinkLocalizerMultiInput(CGsIn, SimPars,XRef);
end

%% Saving Module
Res{1} = [];
Res{2} = Xinf;
Res{3} = Parameters;
clk = clock;
name = sprintf('./%s/FeedBack%s%d%d%d.mat',DestFolder,Name,clk(1),clk(2),clk(3));
save(name,'Res');

%% Export to ONE format
name = sprintf('./%s/FeedBack%s%d%d%d.one',DestFolder,Name,clk(1),clk(2),clk(3));
ExportToOne(Xinf, name, Parameters.Box);

end
