% Anusplin
function Fun_lapgrd(I_AN,template,ymdays,var,gisinfo)
% Read ERA5 data on ymdays that has been resampled; dumped as .asc
ncfile = strcat('./Data/',var,ymdays,'.nc');
ncid = netcdf.open(ncfile,'NOWRITE');
mete = netcdf.getVar(ncid,2);
netcdf.close(ncid);
attvalue = ncreadatt(ncfile,'tmp','missing_value'); 
mete(mete ==attvalue) = -9999;
PathName = './Data/';
FileName = strcat(var,ymdays,'.asc'); 
Save_As_Ascii(PathName,FileName,mete,gisinfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch I_AN
    case 1
        template{17} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{21} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
    case 2
        template{14} = strcat(PathName, FileName);        
        template{17} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{21} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
    case 3
        template{16} = strcat(PathName, FileName);        
        template{19} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{23} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
    case 4   
        template{21} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{25} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
    case 5
        template{14} = strcat(PathName, FileName);        
        template{21} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{25} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
    case 6
        template{20} = strcat(PathName, FileName);        
        template{23} = strcat('./OUT_daily_METE/',var,'-',ymdays,'.tif');
        template{27} = strcat('./OUT_daily_METE/',var,'-rcov-',ymdays,'.tif');
end
Dins = strcat(num2str(I_AN),'_B','.cmd');
fid1 = fopen(Dins,'wt');
for ii = 1: length(template) 
    chri = char(template{ii});
    fprintf(fid1,'%s\n',chri); 
end
fclose(fid1);
%%%%%%%%%%%%%%%%%%%%%%
% Run lapgrd.exe
ExeFileName = 'lapgrd';
cmdFileName = Dins;
cmdPath = fullfile(cmdFileName);
logname = strcat('METEstn',ymdays,'-',num2str(I_AN),'_B.log');
Cmd = [ExeFileName,' <',cmdPath,'> ',logname];
%disp(Cmd);
system(Cmd);
movefile(logname,'OUT_daily_METE'); %%%%%% log
end


