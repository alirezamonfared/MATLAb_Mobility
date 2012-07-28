% Test ExportToOneLinksString
addpath('../shared_functions')

InputFile = '../Sampling/Results/CSV4Original.one';
[Path Name Ext]=fileparts(InputFile);

[X, N, d, tm, Box] = Matricize(InputFile);
CGs = MobilityToConatcts(X,100);
S = ExportToOneLinksString(CGs);
ExportToOneLinks(CGs,'Op.one');