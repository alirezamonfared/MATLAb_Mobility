function MakeVideoFromMat(MatFile);
addpath('/home/alireza/workspace/MobilityProject/MATLAB/BGFS_optimization')

%% Initializations and readings
Res = load(MatFile);
Res = struct2cell(Res);
Res = Res{1};
Xreal = Res{1};
Xreal = Xreal(:,:,2:end);
Xinferred = Res{2};

Parameters = Res{3};

Day = Parameters.Date;
disp(Parameters.Date)


R = Parameters.R;
NRef = Parameters.NRef;
[d N tm] = size(Xinferred);

%% Inilitialize Video Object
name = sprintf('%sLocations%dT%dR%d.avi',Day,N,tm,R);
profile.FrameRate = 1;
vidObj = VideoWriter(name);
vidObj.FrameRate = 3;
open(vidObj);
fig5 = figure(1);

%% Create Video
for tnow = 1:tm
    Xr = Xreal(:,:,tnow);
    CGr = DeriveCG(Xr,R);
    Xopt = Xinferred(:,:,tnow);
    CGopt = DeriveCG(Xopt,R);
    hold on
    scatter(Xopt(1,:),Xopt(2,:),'r','.')
    scatter(Xr(1,:),Xr(2,:),'b','+')
    if (NRef ~= 0)
        Xref = Xr(:,1:NRef);
        scatter(Xref(1,:),Xref(2,:),'g','*')
    end
    legend('Inferred','Real')
    for i = 1:N
        for j = i+1:N
            if CGr(i,j) == 1
                plot([Xr(1,i) Xr(1,j)],[Xr(2,i) Xr(2,j)],'c')
            end
            if CGopt(i,j) == 1
                plot([Xopt(1,i) Xopt(1,j)],[Xopt(2,i) Xopt(2,j)],'y')
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