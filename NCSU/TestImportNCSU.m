NNodes = 19;
TraceName = 'Statefair'
NamePattern = sprintf('%s_30sec',TraceName);
InputFolder = sprintf('./Inputs/%s',TraceName);

X  = ImportNCSU( InputFolder, NamePattern, NNodes);