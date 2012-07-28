function [Xreal, Xinferred, Parameters] = LoadResults(filename)
    Res = load(filename);
    Res = struct2cell(Res);
    Res = Res{1};
    Xreal = Res{1};
    Xreal = Xreal(:,:,2:end);
    Xinferred = Res{2};
    Parameters = Res{3};
end