% RF scheme. Compare the 6 cases and give the optimal solution
% lon, lat, ele
% lon, lat, variable
% lon, lat, ele, variable
% lon, lat, ele, aspect, slope
% lon, lat, variable, aspect, slope
% lon, lat, ele, aspect, slope,variable

function [evlu,k,Mdl] = Fun_RF(C_test,C_vali) 
%
C_test = C_test(2: end);
C_vali = C_vali(2: end);
test = cell2mat(C_test);
vali = cell2mat(C_vali);
test_X = test(:,1:end-1);
test_Y = test(:,end);
vali_X = vali(:,1:end-1);
vali_Y = vali(:,end);
[~,len] = size(test_X);
num = 20; % max leaf number
mae = 1000;
for k0 = 1: num
    Mdl0 = TreeBagger(300,test_X,test_Y,'Method','regression' ,'NumPredictorsToSample',len,'OOBPredictorImportance','On','MinLeafSize',k0);
    Yv = predict(Mdl0,vali_X);
    delta = Yv - vali_Y;
    me0 = mean(delta);
    mae0 = mean(abs(delta));
    rmse0 = sqrt(mean(delta.*delta));
    if mae0 < mae
        me = me0;
        mae = mae0;
        rmse = rmse0;
        k = k0;
        Mdl = Mdl0;
    end
end
evlu = [me mae rmse];
end