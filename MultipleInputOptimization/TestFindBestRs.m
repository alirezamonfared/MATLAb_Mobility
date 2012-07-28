 mode = 0;
 NBins = 50
 Range = [0 150];
 N = 6;
 ShowPlot = 1;
 PlotType = 'survivor';
 
 %Rs=NodepairDistanceHistogram('./Inputs/CSV4Original.one', Range, mode,[25 75], ShowPlot, PlotType)
 %Rs=NodepairDistanceHistogram('./Inputs/RPGMScenario.one', Range, mode, [25 75], ShowPlot, PlotType)
 Rs=NodepairDistanceHistogram('./Inputs/DA.one', Range, mode, [25 75], ShowPlot, PlotType)


%Rs = Node2DHistogram('./Inputs/CSV4Original.one',NBins ,Range, N);
%Rs = Node2DHistogram('./Inputs/RPGMScenario.one',NBins ,Range, N);
%Rs = Node2DHistogram('./Inputs/DA.one',NBins ,Range, N);