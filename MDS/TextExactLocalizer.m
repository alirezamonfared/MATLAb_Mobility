% Test Exact Localizer
X = [1 3 6 3 6; 4 7 3 9 3];
D = squareform(pdist(X'));

Parameters = struct('d',2,'AnchorIndex',[1;2]);
[Xo XLoc2 TR] = MDSLocalizerExact(D, [1 3;4 7], Parameters);


figure
hold on;
scatter(X(1,:),X(2,:),'b+')
%scatter(XLoc2(1,:),XLoc2(2,:),'ro')
scatter(Xo(1,:),Xo(2,:),'g^')
hold off