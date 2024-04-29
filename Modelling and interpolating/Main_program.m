% Both TPS and RF methods are run together. The scheme with the highest accuracy is first selected based on MAE and then interpolated for the whole region
clear; clc;
tic;
var = 'tmp';      % Different variables need to be modified
load gisinfo;     % [xllcorner yllcorner cellsize NODATA_value]
load Juday;
year = 2020;
month = 9;

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
%%%%%%%%%%%%%%%%%%%
out = zeros(daynum,5);   
exind = 1;
filename0 = strcat(var,ym,'Evaluation_Final.xlsx');
filename1 = strcat(var,ym,'Evaluation_An.xlsx');
filename2 = strcat(var,ym,'Evaluation_RF.xlsx');
A = {'ymdays', 'AN/RF','Model','ME','MAE','RMSE'};
xlswrite(filename0,A,1,strcat('A',num2str(exind)));
B = {'ymdays', 'ME1','MAE1','RMSE1','ME2','MAE2','RMSE2','ME3','MAE3','RMSE3',...
    'ME4','MAE4','RMSE4','ME5','MAE5','RMSE5','ME6','MAE6','RMSE6'};
xlswrite(filename1,B,1,strcat('A',num2str(exind)));
C = {'ymdays', 'ME1','MAE1','RMSE1','ME2','MAE2','RMSE2','ME3','MAE3','RMSE3',...
    'ME4','MAE4','RMSE4','ME5','MAE5','RMSE5','ME6','MAE6','RMSE6'};
xlswrite(filename2,C,1,strcat('A',num2str(exind)));
%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Comparison of the two methods
    Vali_AN = zeros(6,3) - 99;  
    Vali_RF = zeros(12,3) - 99; 
    leaf = zeros(12,1) - 99;  
    mae0 = 1000;
    mae00 = 1000;
    for ca = 1: 6
        %% Determine the number of stations available for the training and validation sets and read in the cmd template (required for TPS)
        filen_test = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        filen_vali = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        ftestID = fopen(filen_test);   
        fvaliID = fopen(filen_vali);   
        switch ca
            case 1
                C_test = textscan(ftestID,format1); fclose(ftestID);  
                C_vali = textscan(fvaliID,format1); fclose(fvaliID);
                load template_1;
                template = template_1;
            case 2
                C_test = textscan(ftestID,format1); fclose(ftestID);  
                C_vali = textscan(fvaliID,format1); fclose(fvaliID);
                load template_2;
                template = template_2;
            case 3
                C_test = textscan(ftestID,format2); fclose(ftestID);
                C_vali = textscan(fvaliID,format2); fclose(fvaliID);
                load template_3;
                template = template_3;
            case 4
                C_test = textscan(ftestID,format3); fclose(ftestID);
                C_vali = textscan(fvaliID,format3); fclose(fvaliID);
                load template_4;
                template = template_4;
            case 5
                C_test = textscan(ftestID,format3); fclose(ftestID);
                C_vali = textscan(fvaliID,format3); fclose(fvaliID);
                load template_5;
                template = template_5;
            case 6
                C_test = textscan(ftestID,format4); fclose(ftestID);
                C_vali = textscan(fvaliID,format4); fclose(fvaliID);
                load template_6;
                template = template_6;
        end
        %% TPS
        [num_t,~] = size(C_test{1});
        [num_v,~] = size(C_vali{1});
        Vali_AN(ca,:) = Fun_Anusplin(ca,ymdays,template,num_t,num_v,var);
                                                                                                                                                                             
        %% RF
        [evlu,k,Mdl] = Fun_RF(C_test,C_vali); 
        Vali_RF(ca,:) = evlu;   
        leaf(ca) = k;   
        
        if evlu(2) < mae0 
            mae0 = evlu(2);
            Mdl0 = Mdl;  
        end
    end 
    %% Comparing MAE. Compare the two programmes internally and then together
    [MAE_AN,I_AN] = min(Vali_AN(:,2)); 
    [MAE_RF,I_RF] = min(Vali_RF(:,2)); 

    %% Projections for the entire region
    if MAE_AN < MAE_RF
        % Adoption of the TPS programme, counted as 1
        out(day, :) = [1 I_AN Vali_AN(I_AN,:)];  
        switch I_AN
            case 1
                load template_1B;
                template = template_1B;
            case 2
                load template_2B;
                template = template_2B;
            case 3
                load template_3B;
                template = template_3B;
            case 4
                load template_4B;
                template = template_4B;
            case 5
                load template_5B;
                template = template_5B;
            case 6
                load template_6B;
                template = template_6B;
        end
        Fun_lapgrd(I_AN,template,ymdays,var,gisinfo);  
    else
        % Adoption of the RF programme, counted as 2
        out(day, :) = [2 I_RF Vali_RF(I_RF,:)];
        Fun_MdlTmp(I_RF,Mdl0,ymdays,var);  
    end
    %%%%%%%%%%%%%%%%%%%%%%
    %% Output of daily evaluation results
    exind = exind + 1;
    ymd = str2double(ymdays);
    % Final
    A = [ymd out(day, :)];
    xlswrite(filename0,A,1,strcat('A',num2str(exind)));
    % AN
    B = [ymd Vali_AN(1,:) Vali_AN(2,:) Vali_AN(3,:) Vali_AN(4,:) Vali_AN(5,:) Vali_AN(6,:)];
    xlswrite(filename1,B,1,strcat('A',num2str(exind)));
    % RF
    C = [ymd Vali_RF(1,:) Vali_RF(2,:) Vali_RF(3,:) Vali_RF(4,:) Vali_RF(5,:) Vali_RF(6,:)];
    xlswrite(filename2,C,1,strcat('A',num2str(exind)));
    % 
    disp(strcat('day.............',num2str(day)));
    toc;
end
clear;

