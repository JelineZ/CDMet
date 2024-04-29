% RF Classification of PRE
% kappa auc acc Score0 Score F1
clear; clc;
tic;
var = 'pre';
load gisinfo;
load Juday;
year = 2000;
month = 1;
Preout = './Classification';

if mod(year,4) == 0
    Juday = Juday(:,2);
else
    Juday = Juday(:,1);
end
daynum = Juday(month);

if month < 10
    ym = strcat(num2str(year),'0',num2str(month));
else
    ym = strcat(num2str(year),num2str(month));
end

out = zeros(daynum,7); 
exind = 1;
filename0 = strcat(var,ym,'Classification_Final.xlsx');
filename2 = strcat(var,ym,'Classification_RF.xlsx');
A = {'ymdays','Case','kappa','AUC','ACC','Score0','Score','F1'};
xlswrite(filename0,A,1,strcat('A',num2str(exind)));
C = {'ymdays', 'kappa_1','AUC_1','ACC_1','Score0_1','Score_1','F1_1','kappa_2','AUC_2','ACC_2','Score0_2','Score_2','F1_2','kappa_3','AUC_3','ACC_3','Score0_3','Score_3','F1_3',...
    'kappa_4','AUC_4','ACC_4','Score0_4','Score_4','F1_4','kappa_5','AUC_5','ACC_5','Score0_5','Score_5','F1_5','kappa_6','AUC_6','ACC_6','Score0_6','Score_6','F1_6'};
xlswrite(filename2,C,1,strcat('A',num2str(exind)));

for day = 1: daynum
    tic;
    if day < 10
        days = strcat('0',num2str(day));
    else
        days = num2str(day);
    end
    ymdays = strcat(ym,days);
    format1 = '%s%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele/variable
    format2 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f';  % lon, lat, ele, variable
    format3 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele/variable, aspect, slope
    format4 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele, aspect, slope, variable

    Vali_RFC = zeros(12,6) - 9999;
    leaf = zeros(12,1) - 9999;  
    Mdls = cell(1,12);
    for ca = 1: 6
        filen_test = strcat('./Preprocess_PRE/Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        filen_vali = strcat('./Preprocess_PRE/Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        ftestID = fopen(filen_test);  
        fvaliID = fopen(filen_vali);   
        switch ca
            case 1
                C_test = textscan(ftestID,format1); fclose(ftestID);
                C_vali = textscan(fvaliID,format1); fclose(fvaliID);
            case 2
                C_test = textscan(ftestID,format1); fclose(ftestID); 
                C_vali = textscan(fvaliID,format1); fclose(fvaliID);
            case 3
                C_test = textscan(ftestID,format2); fclose(ftestID);
                C_vali = textscan(fvaliID,format2); fclose(fvaliID);
            case 4
                C_test = textscan(ftestID,format3); fclose(ftestID);
                C_vali = textscan(fvaliID,format3); fclose(fvaliID);
            case 5
                C_test = textscan(ftestID,format3); fclose(ftestID);
                C_vali = textscan(fvaliID,format3); fclose(fvaliID);
            case 6
                C_test = textscan(ftestID,format4); fclose(ftestID);
                C_vali = textscan(fvaliID,format4); fclose(fvaliID);
        end

        [evlu,k,Mdl] = Fun_RFClass(C_test,C_vali);  
        Vali_RFC(ca,:) = evlu;  % [kappa auc acc Score0 Score F1] in all cases
        leaf(ca) = k; 
        Mdls{ca} = Mdl;
    end 

    % Determine if auc is NaN
    auc = max(Vali_RFC(:,2)); 
    acc = max(Vali_RFC(:,3)); 
    kappa = max(Vali_RFC(:,1)); 
    if isnan(auc)                                
        [Loca0,~] = find(Vali_RFC(:,3) == acc); 
        [~,X] = max(Vali_RFC(Loca0,4));           
        Loca = Loca0(X);                        
    else                                        
        [Loca00,~] = find(Vali_RFC(:,1) == kappa);  
        auc2 = max(Vali_RFC(Loca00,2));          
        [Loca0,~] = find(Vali_RFC(Loca00,2) == auc2);
        if length(Loca0) > 1                        
            [~,X] = max(Vali_RFC(Loca00(Loca0),5)); 
            Loca = Loca00(Loca0(X));               
        else                                   
            Loca = Loca00(Loca0);                  
        end
    end

    % Forecast the whole area
    out(day, :) = [Loca Vali_RFC(Loca,:)];
    Fun_MdlC(Loca,Mdls{Loca},ymdays,var);           % Output only auc/acc max + score/score0 max

    % Outputs the results of each day's evaluation, final outputs the case with the largest kappa and the largest score
    exind = exind + 1;
    ymd = str2double(ymdays);
    % Final
    A = [ymd out(day, :)];
    xlswrite(filename0,A,1,strcat('A',num2str(exind)));
    % RF
    C = [ymd Vali_RFC(1,:) Vali_RFC(2,:) Vali_RFC(3,:) Vali_RFC(4,:) Vali_RFC(5,:) Vali_RFC(6,:)];
    xlswrite(filename2,C,1,strcat('A',num2str(exind)));
    disp(strcat('day......',num2str(day)));
    toc;
end
movefile(filename0,Preout); movefile(filename2,Preout);


