function CompareConnectivitiesOverR(RVector,Parameters, varargin);
% Parameters Options: mode : defines the plotting mode
% mode == 0 --> 2D(Default)
% mode == 1 --> 3D
% Parameters Options: NormMode : defines the normalization mode
% NormMode == 0 --> Normalize by 1's of Input Contact Trace
% NormMode == 1 --> Normalize by 0's of Input Contact Trace
% NormMode == 2 --> Normalize by N(N-1) flat
% Parameters Options: PlotContent : defines what should be plotted
% PlotContent == 0 --> Plot Total Link Erros (default)
% PlotContent == 1 --> Plot Extra Link Erros
% PlotContent == 2 --> Plot Missing Link Erros
% Parameters.SpecialVarargin is set to 1, if filenames are created in a for loop in a
% cell
% Parameters.MainR is set to a value if one plans to apply the modification
% step
% Parameters.ErrorBar is set to 1 if one plans to plot ErrorBars
% corresponding to Standard Deviations over time on the plots
% Parameters.DestFolder is the name of the folder under the current working
% directory where the plot vis saved
% Parameters.LegendLocation is a string specifying the location of the
% legend
% Parameters.NDisplayIndices determines how many R values should be
% displayed as labels over the x-axis
% Parameters.CustomLegend is a cell, where each value of it is a string to
% be used as one of the legends, in the case that one desires to create
% their own legends for the figures


%% Adding paths
addpath('../shared_functions/')
addpath('../shared_functions/plot2svg_20101128/')

%% Default Values
if (~isfield(Parameters,'mode'))
    mode = 0;
else
    mode = Parameters.mode;
end

if (~isfield(Parameters,'PlotContent'))
    PlotContent = 0;
else
    PlotContent = Parameters.PlotContent;
end

if (~isfield(Parameters,'MainR'))
    MainR = [];
else
    MainR = Parameters.MainR;
end

if (~isfield(Parameters,'ErrorBar'))
    ErrorBar = 0;
else
    ErrorBar = Parameters.ErrorBar;
end

if (~isfield(Parameters,'NormMode'))
    NormMode = 0;
else
    NormMode = Parameters.NormMode;
end

if (~isfield(Parameters,'SpecialVarargin'))
    SpecialVarargin = 0;
else
    SpecialVarargin = Parameters.SpecialVarargin;
end

if (~isfield(Parameters,'DestFolder'))
    DestFolder = 'Results';
else
    DestFolder = Parameters.DestFolder;
end

if(~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end

if (~isfield(Parameters,'LegendLocation'))
    LegendLocation = 'NorthWest';
else
    LegendLocation = Parameters.LegendLocation;
end

if (~isfield(Parameters,'NDisplayIndices'))
    NDisplayIndices = 10;
else
    NDisplayIndices = Parameters.NDisplayIndices;
end

if (~isfield(Parameters,'AxisClipMode'))
    AxisClipMode = 0; %No clippnig
else
    AxisClipMode = Parameters.AxisClipMode;
end

if (~isfield(Parameters,'IgnoreLegend'))
    IgnoreLegend = 0; %No clippnig
else
    IgnoreLegend = Parameters.IgnoreLegend;
end

if (~isfield(Parameters,'OutputFilename'))
    OutputFilename = [];
else
    OutputFilename = Parameters.OutputFilename;
end

%% Initializations
if (SpecialVarargin ~= 0)
    varargin = varargin{1};
end
NFiles = length(varargin);
NPlots = NFiles - 1;

X = cell(NPlots,1);

ExtraLinkValues = cell(NPlots,1);
ExtraLinkErrors = cell(NPlots,1);
MissingLinkValues = cell(NPlots,1);
MissingLinkErrors = cell(NPlots,1);
TotalLinkValues = cell(NPlots,1);
TotalLinkErrors = cell(NPlots,1);

ExtraLinks = cell(NPlots,1);
MissingLinks = cell(NPlots,1);
LinkErrors = cell(NPlots,1);

CG =  cell(NPlots,1);
CGDiff =  cell(NPlots,1);

L = length(RVector);

%% Opening Files
[Path Name Ext]=fileparts(varargin{1});
[Xreal, N, d, tm, Box] = Matricize(varargin{1});

%% Color set
cmap = hsv(NPlots);
%mrk = {'+','o','x','d','*','s','^','v','>','<','p','h'};
%linetype = {'-','--',':','.-'};
mrk = {'','+','x','^'};
linetype = {'-','--',':','.-'};

%% Plotting
for i = 1:NPlots
    [X{i}, N, d, tm, Box] = Matricize(varargin{i+1});
    ExtraLinkValues{i} = zeros(L,1);
    ExtraLinkErrors{i} = zeros(L,1);
    MissingLinkValues{i} = zeros(L,1);
    MissingLinkErrors{i} = zeros(L,1);
    TotalLinkValues{i} = zeros(L,1);
    TotalLinkErrors{i} = zeros(L,1);
    
    j = 1;
    for R = RVector
        ExtraLinks{i} = zeros(tm,1);
        MissingLinks{i} = zeros(tm,1);
        LinkErrors{i} = zeros(tm,1);
        
        for t = 1:tm
            CG{i} = DeriveCG(X{i}(:,:,t),R);
            CGReal = DeriveCG(Xreal(:,:,t),R);
            if(~isempty(MainR))
                CG{i} = ModifyContact(CG{i},CGReal,sign(R-MainR));
            end
            CGDiff{i} = CG{i} - CGReal;
            if (NormMode == 0)
                NormValue =  size(find(CGReal == 1),1);
            elseif(NormMode == 1)
                NormValue =  size(find(CGReal == 0),1);
            elseif(NormMode == 2)
                NormValue =  N*(N-1);
            else
                error('NormMode can be 0, 1 or 2')
            end
            if (NormValue == 0)
                NormValue = 1;
            end
            ExtraLinks{i}(t) =  (size(find(CGDiff{i} == 1),1) / NormValue)*100;
            MissingLinks{i}(t) = (size(find(CGDiff{i} == -1),1) / NormValue)*100;
            LinkErrors{i}(t) = (ExtraLinks{i}(t) + MissingLinks{i}(t));
            
        end
        if (PlotContent == 0)
            TotalLinkValues{i}(j) = mean(LinkErrors{i});
            TotalLinkErrors{i}(j) = std(LinkErrors{i});
            TitleStr = 'Total Link Erros';
        elseif (PlotContent == 1)
            TotalLinkValues{i}(j) = mean(ExtraLinks{i});
            TotalLinkErrors{i}(j) = std(ExtraLinks{i});
            TitleStr = 'Extra Link Erros';
        elseif (PlotContent == 2)
            TotalLinkValues{i}(j) = mean(MissingLinks{i});
            TotalLinkErrors{i}(j) = std(MissingLinks{i});
            TitleStr = 'Missing Link Erros';
        else
            error('PlotContent can be 0, 1 or 2')
        end
        j = j + 1;
    end
    
    Steps = round(L/NDisplayIndices);
    Indices = 1:Steps:L;
    if ( mode == 0 )
        figure(3);
        hold on
        if (~ErrorBar)
            [mrkNumder, linetypeNumber] = ind2sub([length(mrk) , length(linetype)],i);
            pltStr = sprintf('%s%s',linetype{linetypeNumber},mrk{mrkNumder});
            %plt = plot(1:L,TotalLinkValues{i},'Color',cmap(i,:),...
            %    'line',linetype{linetypeNumber},'marker',mrk{mrkNumder});
            plt = plot(1:L,TotalLinkValues{i},pltStr,'Color',cmap(i,:));
        else
            plt = errorbar(1:L,TotalLinkValues{i},TotalLinkErrors{i},'x','Color',cmap(i,:));
        end
        set(gca,'XTick',Indices)
        set(gca,'XTickLabel',RVector(Indices),'FontSize', 15)
        if (isfield(Parameters,'TitleStr'))
            TitleStr = Parameters.TitleStr;
        end
        title(TitleStr, 'FontSize', 36);
        xlabel('Transmission Range','FontSize', 20)
        ylabel('Error in %','FontSize', 20)
        hold off
    end
end
if (AxisClipMode~=0)
    MaxValue = 1.1*max(max(TotalLinkValues{AxisClipMode}));
    set(gca,'YLim',[0 MaxValue])
end
if (isfield(Parameters,'Range'))
    set(gca,'XLim',[Parameters.Range(1) Parameters.Range(2)])
end
%% Legend Hanling
if(~IgnoreLegend)
    LengendData = cell(NPlots,1);
    for i = 1:NPlots
        if (isfield(Parameters,'CustomLegend'))
            LengendData{i} = Parameters.CustomLegend{i};
        else
            if (i == 1)
                LengendData{i} = 'BaseLine';
            else
                LengendData{i} = sprintf('Test %d', i);
            end
        end
    end
    h_legend = legend(LengendData,'Location',LegendLocation);
    set(h_legend,'FontSize',20);
end

%% 3D Plots
if (mode == 1)
    % modify TotalLinkValues
    for i = 1:NPlots
        TotalLinkValues{i} =  TotalLinkValues{i}';
    end
    YVec = 1:NPlots;
    XVec = repmat(1:L,NPlots,1);
    ZVec = cell2mat(TotalLinkValues);
    options.LegendText = LengendData;
    area3(XVec,YVec,ZVec,options);
    Indices = 1:round((L/10)):L;
    set(gca,'XTick',Indices)
    set(gca,'XTickLabel',RVector(Indices))
    set(gca,'YTickLabel',[])
    xlabel('Test Transmission Ranges')
    zlabel('Total Link Errors')
    title(TitleStr)
end


%% Save to svg
if(isempty(OutputFilename))
    OutputFilename = sprintf('./%s/%sTotalErrorsN%dT%dR%d.svg',DestFolder,Name,N,tm,R);
end
plot2svg(OutputFilename);
end
