% TPS scheme, compare 6 cases and give the optimal solution
% lon, lat, ele
% lon, lat, variable
% lon, lat, ele, variable
% lon, lat, ele, aspect, slope
% lon, lat, variable, aspect, slope
% lon, lat, ele, aspect, slope,variable
% 699 stations are divided into training and validation sets, and the evaluation metric is MAE

function num = Fun_Anusplin(ca,ymdays,template,num_t,num_v,var)
switch ca
    case 1
        template{17} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{18} = num2str(num_t);
        template{26} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{27} = num2str(num_v);
    case 2
        template{17} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{18} = num2str(num_t);
        template{26} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{27} = num2str(num_v);
    case 3
        template{19} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{20} = num2str(num_t);
        template{28} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{29} = num2str(num_v);
    case 4
        template{19} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{20} = num2str(num_t);
        template{28} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{29} = num2str(num_v);
    case 5
        template{18} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{19} = num2str(num_t);
        template{27} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{28} = num2str(num_v);
    case 6
        template{20} = strcat('./Data/',var,'stn',ymdays,'_test',num2str(ca),'.dat');
        template{21} = num2str(num_t);
        template{29} = strcat('./Data/',var,'stn',ymdays,'_vali',num2str(ca),'.dat');
        template{30} = num2str(num_v);
end
Dins = strcat(num2str(ca),'_A','.cmd');
fid1 = fopen(Dins,'wt');
for ii = 1: length(template) 
    chri = char(template{ii});
    fprintf(fid1,'%s\n',chri); 
end
fclose(fid1);
%%%%%%%%%%%%%%%%%%%%%%
% ‘À––splina.exe
ExeFileName = 'splina';
cmdFileName = Dins;
cmdPath = fullfile(cmdFileName);
logname = strcat('METEstn',ymdays,'-',num2str(ca),'_A.log');
Cmd = [ExeFileName,' <',cmdPath,'> ',logname];
system(Cmd);
movefile(logname,'OUT_splina'); %%%%%% log
movefile(strcat('mete_',num2str(ca),'.res'),'OUT_splina'); 
movefile(strcat('mete_',num2str(ca),'.opt'),'OUT_splina'); 
movefile(strcat('mete_',num2str(ca),'.sur'),'OUT_splina'); 
movefile(strcat('mete_',num2str(ca),'.lis'),'OUT_splina'); 
movefile(strcat('mete_',num2str(ca),'.cov'),'OUT_splina'); 
movefile(strcat('mete_',num2str(ca),'.out'),'OUT_splina'); 
%%%%%%%%%%%%%%%%%%%%%%
% "ca" case, read the ME MAE RMS results from the log file
logname = strcat('./OUT_splina/',logname);
fid = fopen(logname);
tline = fgetl(fid);
while ischar(tline)
tline = fgetl(fid);
if strcmp(tline,'SURF  NPTS        ME        MAE        RMS        MAX      SITE')
    tline = fgetl(fid);
    S = regexp(tline, '\s+', 'split');
    num = str2double(S);
    num = num(~isnan(num));
    break;
end
end
fclose(fid);
num = num(3: 5); %  ME  MAE RMS 
end



