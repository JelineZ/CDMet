% Modeling
function [evlu,k,Mdl] = Fun_RFClass(C_test,C_vali) % 
%
C_test = C_test(2: end);   
C_vali = C_vali(2: end);   
test = cell2mat(C_test); 
vali = cell2mat(C_vali);
test_X = test(:,1:end-1); 
test_Y0 = test(:,end);     
vali_X = vali(:,1:end-1); 
vali_Y0 = vali(:,end);    
[~,len] = size(test_X);  

test_Y = zeros(size(test_Y0))-99;
vali_Y = zeros(size(vali_Y0))-99;
for i = 1 : size(test_Y0)
    if test_Y0(i) < 0.1
        test_Y(i) = 0;
    else
        test_Y(i) = 1;
    end
end

for ii = 1 : size(vali_Y0)
    if vali_Y0(ii) < 0.1
        vali_Y(ii) = 0;
    else
        vali_Y(ii) = 1;
    end
end

num = 20; % max leaf number
kappa = -100;
acc = -1;
for k0 = 1: num   % Find the number of leaf nodes with the highest result accuracy
    Mdl0 = TreeBagger(300,test_X,test_Y,'Method','classification','NumPredictorsToSample',len,'OOBPredictorImportance','On','MinLeafSize',k0);
    [Yv,Scoreaa] = predict(Mdl0,vali_X); 

    % Determine whether the observations are all 0/1, calculate different score0, and assign different meth values, so that the optimal leaf node can be judged subsequently according to different error metrics
    if sum(vali_Y) == 0  % Observations are all 0. Calculate the mean of column 1 of score00
        meth = 1;
        Score00 = mean(Scoreaa(:,1));
    elseif sum(vali_Y) == length(vali_Y)  % Observations are all 1. Calculate the mean of column 2 of score00
        meth = 2;
        Score00 = mean(Scoreaa(:,2));
    else                 % Observations have 0 and 1
        meth = 3;
    end

    % score auc
    for s = 1 : size(Scoreaa,1)
        ss(s) = max(Scoreaa(s,:));  % Store the larger score value for each row
    end
    Scorea = mean(ss);
    auc0 = Fun_AUC(vali_Y,Scoreaa(:,2));

    % »ìÏý¾ØÕó kappa F1
    Yv = char(Yv);
    Yv = str2num(Yv);
    C = confusionmat(vali_Y,Yv);  % order: 0 1 For numeric and logical vectors, the order is the sorted order of s.
    if length(C) == 1
        C(2,2) = 0;
    end
    m = sum(sum(C,2));
    p0 = trace(C) / m;  % ACC
    pe = sum(C,1) * sum(C,2) / (m^2);
    kappa0 = (p0 - pe) / (1 - pe);
    recall = C(2,2) / (C(2,2) + C(2,1)); % recall = TP / (TP+FN) 
    precision = C(2,2) / (C(2,2) + C(1,2)); % precision = TP / (TP + FP)
    F10 = 2 * precision * recall / (precision + recall);

    % Determine if all observations are 0/1
    switch meth
        case 1
            if p0 > acc    % The k with the largest acc is chosen because at this point kappa is all 0 and auc is all NaN
                kappa = kappa0;
                F1 = F10;
                k = k0;
                Mdl = Mdl0;
                Score = Scorea;
                Score0 = Score00;
                auc = auc0;
                acc = p0;
            end
        case 2
            if p0 > acc    % The k with the largest acc is chosen because at this point kappa is all 0 auc is all NaN
                kappa = kappa0;
                F1 = F10;
                k = k0;
                Mdl = Mdl0;
                Score = Scorea;
                Score0 = Score00;
                auc = auc0;
                acc = p0;
            end
        case 3
            if kappa0 > kappa   % If not all 0/1, pick the k with the largest kappa.
                kappa = kappa0;
                F1 = F10;
                k = k0;
                Mdl = Mdl0;
                Score = Scorea;
                Score0 = -1;   %%%%%%%%%%
                auc = auc0;
                acc = p0;
            end
    end
end
evlu = [kappa auc acc Score0 Score F1];
end

