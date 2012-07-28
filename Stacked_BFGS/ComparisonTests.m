%Comparison Tests

%clear all
clc
%% Initializations and readings
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/fminlbfgs_version2c')
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization/')
Res = load('./Results/ResultBig20111117.mat');
Res = struct2cell(Res);
Res = Res{1};
Xreal = Res{1};
Xp = Xreal(:,:,1);
Xreal = Xreal(:,:,2:end);
Xinferred = Res{2};

Parameters = Res{3};

disp(Parameters.Date)

Vm = Parameters.Vm;
R = Parameters.R;
NRef = Parameters.NRef;
[d N tm] = size(Xinferred);

ORV = zeros(1,tm);
IRV = zeros(1,tm);
SV = zeros(1,tm);
TV = zeros(1,tm);


F1 = zeros(1,tm);
F2 = zeros(1,tm);
F3 = zeros(1,tm);
FVAL = zeros(1,tm);

%% Computing violations and objective
for t = 1 : tm
    Xr = Xreal(:,:,t);
    Xinf = Xinferred(:,:,t);
    CG = DeriveCG(Xr, R);
    [tv irv orv sv] = ValidilityCheck(Xinf, Xp, CG, R, Vm);
    [fval f1 f2 f3] = ObjectiveValue(Xinf, Xp, CG, R, Vm);
    F1(t) = f1;
    F2(t) = f2;
    F3(t) = f3;
    FVAL(t) = fval;
    ORV(t) = orv;
    IRV(t) = irv;
    SV(t) = sv;
    TV(t) = tv;
    Xp = Xinf;
end

%% Plotting the violated constraint ratios
fig1 = figure(1);
t = 1:tm;

h1 = subplot(2,2,1);
plot(t, ORV*100, 'b')
%axis(h1, [1 tm 0 max(ORV*100)])
title('Out of Range Violations')
xlabel('Time')
ylabel('Violations %')

h2 = subplot(2,2,2);
plot(t, IRV*100, 'r')
%axis(h2, [1 tm 0 max(IRV*100)])
title('In Range Violations')
xlabel('Time')
ylabel('Violations %')

h3 = subplot(2,2,3);
plot(t, SV*100, 'g')
%axis(h3, [1 tm 0 max(SV*100)])
title('Speed Violations')
xlabel('Time')
ylabel('Violations %')

h4 = subplot(2,2,4);
plot(t, TV*100, 'k')
%axis(h4, [1 tm 0 max(TV*100)])
title('Total Violations')
xlabel('Time')
ylabel('Violations %')

name = sprintf('./Figures/%sViolationsN%dT%dR%d.jpg',date(),N,tm,R);
saveas(fig1,name)

%% Plotting the objective values
fig2 = figure(2);
t = 1:tm;

h1 = subplot(2,2,1);
plot(t, F1, 'b')
%axis(h1, [1 tm 0 max(ORV*100)])
title('Objective Value from Contacts')
xlabel('Time')
ylabel('Objective Value')

h2 = subplot(2,2,2);
plot(t, F2, 'r')
%axis(h2, [1 tm 0 max(IRV*100)])
title('Objective Value from Non-contacts')
xlabel('Time')
ylabel('Objective Value')

h3 = subplot(2,2,3);
plot(t, F3, 'g')
%axis(h3, [1 tm 0 max(SV*100)])
title('Objective Value from Speed Constraint')
xlabel('Time')
ylabel('Objective Value')

h4 = subplot(2,2,4);
plot(t, FVAL, 'k')
%axis(h4, [1 tm 0 max(TV*100)])
title('Total Objective Value')
xlabel('Time')
ylabel('Objective Value')

st = floor(tm/10);
axis([h1],[0 tm 0 max(F1(st:tm))+1])
axis([h2],[0 tm 0 max(F2(st:tm))+1])
axis([h3],[0 tm 0 max(F3(st:tm))+1])
axis([h4],[0 tm 0 max(FVAL(st:tm))+1])

name = sprintf('./Figures/%sObjectiveN%dT%dR%d.jpg',date(),N,tm,R);
saveas(fig2,name)

%% Plotting MSE
MSE = zeros(tm,1);
for t = 1:tm
    for i = 1:N
        MSE(t) = MSE(t) + norm(Xreal(:,i,t)-Xinferred(:,i,t),2);
    end
end
MSE = MSE ./ (R*N);
fig3 = figure(3);
plot(1:tm,MSE,'m')
xlabel('time')
ylabel('MSE/R')
title('MSE of Real Locations Vs Inferred Locations')
        
name = sprintf('./Figures/%sMSEN%dT%dR%d.jpg',date(),N,tm,R);
saveas(fig3,name)

%% Comparing the connectivity graph structures
ExtraLinks = zeros(tm,1);
MissingLinks = zeros(tm,1);
LinkErrors = zeros(tm,1);
for t = 1:tm
    CGReal = DeriveCG(Xreal(:,:,t),R);
    CGInferred = DeriveCG(Xinferred(:,:,t),R);
    CGDiff = CGInferred - CGReal;
    ExtraLinks(t) =  size(find(CGDiff == 1),1);
    MissingLinks(t) = size(find(CGDiff == -1),1);
    LinkErrors(t) = ExtraLinks(t) + MissingLinks(t);
end

ExtraLinks = ExtraLinks / (N*(N-1)/2);
MissingLinks = MissingLinks / (N*(N-1)/2);
LinkErrors = LinkErrors / (N*(N-1)/2);
fig4 = figure(4);
hold on;
plot(1:tm,MissingLinks,'r--');
plot(1:tm,ExtraLinks,'b.-');
plot(1:tm,LinkErrors,'k-')
legend('Extra Links','Missing Links','Total Link Errors')
title('Link Prediction Errors in Connectivity Graph')
xlabel('Time')
ylabel('Error in %')
hold off;
name = sprintf('./Figures/%sLinkErrorsN%dT%dR%d.jpg',date(),N,tm,R);
saveas(fig4,name)


% Plotting the graphical form for one sample
% Coordinates = zeros(N,2);
% Facex = 10;
% Facey = 10;
% [x y] = meshgrid(1:Facex,1:Facey);
% [s1 s2] = size(x);
% x = reshape(x,1,s1*s2);
% y = reshape(y,1,s1*s2);
% Coordinates(:,1) = x;
% Coordinates(:,2) = y;
% figure(6);
% subplot(2,1,1);
% gplot(CGReal,Coordinates)
% subplot(2,1,2);
% gplot(CGInferred,Coordinates)

%% Plotting the points
% figure;
% scatter3(0,0,0)
% hold on
% tm = size(Xreal,3);
% N = size(Xreal,2);
% for t = 1 : tm
%     scatter3(Xinferred(1,:,t),Xinferred(2,:,t),ones(1,N)*t,'r','o')
%     scatter3(Xreal(1,:,t),Xreal(2,:,t),ones(1,N)*t,'b','+')
% end
% zlabel('Time')
% title('Real and inferred locations')  
% hold off

%% Comparing locations in a Movie
video = true;
if(video)
    name = sprintf('./Figures/%sLocations%dT%dR%d.avi',date(),N,tm,R);
    profile.FrameRate = 1;
    vidObj = VideoWriter(name);
    vidObj.FrameRate = 3;
    open(vidObj);
    fig5 = figure(5);
    for tnow = 1:tm
        Xr = Xreal(:,:,tnow);
        CGr = DeriveCG(Xr,R);
        Xopt = Xinferred(:,:,tnow);
        CGopt = DeriveCG(Xopt,R);
        hold on
        scatter(Xopt(1,:),Xopt(2,:),'r','o')
        scatter(Xr(1,:),Xr(2,:),'b','+')
        if (NRef ~= 0)
            Xref = Xr(:,1:NRef);
            scatter(Xref(1,:),Xref(2,:),'g','*')
        end
        legend('Inferred','Real')
        for i = 1:N
            for j = i+1:N
                if CGr(i,j) == 1
                    plot([Xr(1,i) Xr(1,j)],[Xr(2,i) Xr(2,j)],'b')
                end
                if CGopt(i,j) == 1
                    plot([Xopt(1,i) Xopt(1,j)],[Xopt(2,i) Xopt(2,j)],'r')
                end
            end
        end
        TITLE = sprintf('Sample Iteration for LBFGS at t =  %d',tnow);
        title(TITLE)
        hold off
        movegui(fig5);
        axis tight
        set(gca,'nextplot','replacechildren','visible','off')
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
        clf
    end
    close(vidObj);
end











