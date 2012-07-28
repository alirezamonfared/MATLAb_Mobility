 addpath('../shared_functions')
 RVector=horzcat(5:5:150,200:50:600);
 CompareConnectivityOverR('./Inputs/CSV4Original.one','./Results/CSV4Original201234.one',RVector)
 