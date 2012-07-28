%Comparison Tests

Res = load('Fmincon1.mat');
Res = struct2cell(Res);
Res = Res{1};
Xreal = Res{1};
Xp = Xreal(:,:,1);
Xreal = Xreal(:,:,2:end);
Xinferred = Res{2};

tm = 50;
Vm = 1.5;
R = 15;

ORV = zeros(1,tm);
IRV = zeros(1,tm);
SV = zeros(1,tm);
TV = zeros(1,tm);


F1 = zeros(1,tm);
F2 = zeros(1,tm);
F3 = zeros(1,tm);
FVAL = zeros(1,tm);


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
figure(1)
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

%% Plotting the objective values
figure(2)
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
