clear;clc;
%%
year = 2000;   %% Interpolation year
month = 1;     %% Interpolation day
var = 'tmp';   %% Interpolation variable  % Different variables need to be modified
load Geo_data  %% Weather station information, organized into 6 columns: station ID, longitude, latitude, altitude, slope, aspect
load ACCJ      %% The number of days in the year on the first day of each month minus one
load Juday     %% Days of each month
Preout = './Preprocess_TMP/Data';   % Storing preprocessing results
if mod(year,4) == 0
    Juday = Juday(:,2);
    ACCJ = ACCJ(:,2);
else
    Juday = Juday(:,1);
    ACCJ = ACCJ(:,1);
end
daynum = Juday(month);

%% Reading observation data
if month < 10
    ym = strcat(num2str(year),'0',num2str(month));
else
    ym = strcat(num2str(year),num2str(month));
end

exind = 1;
filename0 = strcat(var,num2str(ym),'_Stn_numbers.xlsx');
A = {'ymdays', 'number'};
xlswrite(filename0,A,1,strcat('A',num2str(exind)));

filename1 = strcat('./CN_OBS_Daily_TEM/','SURF_CLI_CHN_MUL_DAY-TEM-12001-',ym,'.TXT'); % Different variables need to be modified
fileID = fopen(filename1);
C_data = textscan(fileID,'%d %d %d %d %d %d %d %d %d %d %d %d %d');  % Different variables need to be modified
fclose(fileID);
stn_id = double(C_data{1,1});
day = C_data{1,7};                % Different variables need to be modified
tmp = double(C_data{1,9}) / 10;   % Different variables need to be modified

%% ERA5
filename2 = strcat('./Single_levels/','2m_temperature_2000.nc');  % Different variables need to be modified
ncid = netcdf.open(filename2,'NOWRITE');
lon = netcdf.getVar(ncid,0);
lat = netcdf.getVar(ncid,1);
netcdf.close(ncid);
scale_factor = ncreadatt(filename2,'t2m','scale_factor');  % Different variables need to be modified
add_offset = ncreadatt(filename2,'t2m','add_offset');      % Different variables need to be modified
%% Topographic data, extraction of latitude and longitude
filename3 = 'slope_2_5m.nc';
ncid = netcdf.open(filename3,'NOWRITE');
lon_G = netcdf.getVar(ncid,0);
lat_G = netcdf.getVar(ncid,1);
slope = netcdf.getVar(ncid,2);
netcdf.close(ncid);
attvalue = ncreadatt(filename3,'slo','missing_value');
[lati,loni] = meshgrid(lat_G,lon_G);
%%
for i = 1: daynum
    tic;
    stnidi = stn_id(day == i);
    len = length(stnidi);
    tmpi = tmp(day == i);
    st = (i - 1) * 24 + 1 + ACCJ(month) * 24; 
    vi = ncread(filename2,'t2m',[1 1 st],[length(lon) length(lat) 24]);   % Different variables need to be modified
    vi = squeeze(vi);
    vi = double(vi) - 273.15; % Different variables need to be modified
    vi = max(vi,[],3);        % Different variables need to be modified
    invalue = interp2(lat,lon,vi,lati,loni,'liner');
    invalue(slope == attvalue) = -32768; 
    a0 = isnan(vi);
    b0 = find(a0 == 1);
    if  isempty(b0)
        disp('Good!');
    else
        disp('Bad!');
        t;
    end
    a00 = min(min(vi));
    b00 = max(max(vi));
    c00 = b00 - a00;
    disp(a00);
    disp(b00);
    if c00 == 0
        disp('So Bad!');
        t;
    end
           
    %% Output resampled ERA5
    llon = length(lon_G);
    llat = length(lat_G);
    if i < 10
        days = strcat('0',num2str(i));
    else
        days = num2str(i);
    end
    ymdays = strcat(ym,days);
    name = strcat(var,ymdays,'.nc');
    nccreate(name,'lon','Dimensions',{'lon' llon},'Datatype','double','Format','classic');
    nccreate(name,'lat','Dimensions',{'lat' llat},'Datatype','double','Format','classic');
    nccreate(name,var,'Dimensions',{'lon' llon 'lat' llat},'Datatype','single','Format','classic');
    ncwrite(name,'lon',lon_G);
    ncwrite(name,'lat',lat_G);
    ncwrite(name,var,invalue); 
    ncwriteatt(name,'lon','long_name','longitude');
    ncwriteatt(name,'lon','unit','degree');
    ncwriteatt(name,'lat','long_name','latitude');
    ncwriteatt(name,'lat','unit','degree');
    ncwriteatt(name,var,'long_name','Daily tempereture');
    ncwriteatt(name,var,'unit','mm');
    ncwriteatt(name,var,'missing_value',-32768);
    movefile(name,Preout);
    %% Organising and exporting training and validation sets
    rnum0 = rand(len,1);
    rnum1 = rnum0;
    rnum0(rnum1 <= 0.9) = 1; %%%%
    rnum0(rnum1 > 0.9) = 0;  %%%%
    format01 = '%s%8.2f%8.2f'; % ele/variable
    format02 = '%s%8.2f%8.2f%8.2f'; % ele, variable
    format1 = '%s%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele
    format2 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f';  % lon, lat, ele, variable
    format3 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele, aspect, slope
    format4 = '%s%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f'; % lon, lat, ele, aspect, slope, variable
    otxt1 = strcat(var,'stn',ymdays,'_test1.dat');    fid1 = fopen(otxt1, 'w+');
    vtxt1 = strcat(var,'stn',ymdays,'_vali1.dat');     fidv1 = fopen(vtxt1, 'w+');
    otxt2 = strcat(var,'stn',ymdays,'_test2.dat');    fid2 = fopen(otxt2, 'w+');
    vtxt2 = strcat(var,'stn',ymdays,'_vali2.dat');     fidv2 = fopen(vtxt2, 'w+');
    otxt3 = strcat(var,'stn',ymdays,'_test3.dat');    fid3 = fopen(otxt3, 'w+');
    vtxt3 = strcat(var,'stn',ymdays,'_vali3.dat');     fidv3 = fopen(vtxt3, 'w+');
    otxt4 = strcat(var,'stn',ymdays,'_test4.dat');    fid4 = fopen(otxt4, 'w+');
    vtxt4 = strcat(var,'stn',ymdays,'_vali4.dat');     fidv4 = fopen(vtxt4, 'w+');
    otxt5 = strcat(var,'stn',ymdays,'_test5.dat');    fid5 = fopen(otxt5, 'w+');
    vtxt5 = strcat(var,'stn',ymdays,'_vali5.dat');     fidv5 = fopen(vtxt5, 'w+');
    otxt6 = strcat(var,'stn',ymdays,'_test6.dat');    fid6 = fopen(otxt6, 'w+');
    vtxt6 = strcat(var,'stn',ymdays,'_vali6.dat');     fidv6 = fopen(vtxt6, 'w+');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otxt7 = strcat(var,'stn',ymdays,'_test7.dat');    fid7 = fopen(otxt7, 'w+');
    vtxt7 = strcat(var,'stn',ymdays,'_vali7.dat');     fidv7 = fopen(vtxt7, 'w+');
    otxt8 = strcat(var,'stn',ymdays,'_test8.dat');    fid8 = fopen(otxt8, 'w+');
    vtxt8 = strcat(var,'stn',ymdays,'_vali8.dat');     fidv8 = fopen(vtxt8, 'w+');
    otxt9 = strcat(var,'stn',ymdays,'_test9.dat');    fid9 = fopen(otxt9, 'w+');
    vtxt9 = strcat(var,'stn',ymdays,'_vali9.dat');     fidv9 = fopen(vtxt9, 'w+');
    otxt10 = strcat(var,'stn',ymdays,'_test10.dat');    fid10 = fopen(otxt10, 'w+');
    vtxt10 = strcat(var,'stn',ymdays,'_vali10.dat');     fidv10 = fopen(vtxt10, 'w+');
    otxt11 = strcat(var,'stn',ymdays,'_test11.dat');    fid11 = fopen(otxt11, 'w+');
    vtxt11 = strcat(var,'stn',ymdays,'_vali11.dat');     fidv11 = fopen(vtxt11, 'w+');
    otxt12 = strcat(var,'stn',ymdays,'_test12.dat');    fid12 = fopen(otxt12, 'w+');
    vtxt12 = strcat(var,'stn',ymdays,'_vali12.dat');     fidv12 = fopen(vtxt12, 'w+');
    X = zeros(1,6);
    jj = 0;
    for j = 1: len
        variable = tmpi(j);
        % For all temperature variables and PRE: variable >= 1000 || variable <= - 1000
        % For WIN: variable >= 500 || variable < 0
        % For RHU: variable > 100 || variable < 0
        % For PRS: variable == 3276.6 || variable <= 0 || variable > 4000
        % For SSD: variable > 24 || variable < 0
        if variable >= 1000 || variable <= - 1000    % Different variables need to be modified 
            continue;   %%
        end
        jj = jj + 1;
        Y = variable;  
        stnidij = stnidi(j);
        X(1:5) = Geo_data(Geo_data(:,1) == stnidij,2:6);
        [row,col] = findxy(Geo_data(j,2),Geo_data(j,3),lon_G,lat_G);
        invaluej = invalue(row,col);

        X(6) = invaluej; 
        if jj < 10
            stnj = strcat('st_00',num2str(jj));
        elseif jj>=10 && jj<=99
            stnj = strcat('st_0',num2str(jj));
        else
            stnj = strcat('st_',num2str(jj));
        end
        if rnum0(j)
            fprintf(fid1,format1, stnj,X(1:3),Y); fprintf(fid1, '\r\n');
            fprintf(fid2,format1, stnj,X([1 2 6]),Y); fprintf(fid2, '\r\n');
            fprintf(fid3,format2, stnj,X([1 2 3 6]),Y); fprintf(fid3, '\r\n');
            fprintf(fid4,format3, stnj,X(1:5),Y); fprintf(fid4, '\r\n');
            fprintf(fid5,format3, stnj,X([1 2 6 4 5]),Y); fprintf(fid5, '\r\n');
            fprintf(fid6,format4, stnj,X,Y); fprintf(fid6, '\r\n');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(fid7,format01, stnj,X(3),Y); fprintf(fid7, '\r\n');
            fprintf(fid8,format01, stnj,X(6),Y); fprintf(fid8, '\r\n');
            fprintf(fid9,format02, stnj,X([3 6]),Y); fprintf(fid9, '\r\n');
            fprintf(fid10,format1, stnj,X(3:5),Y); fprintf(fid10, '\r\n');
            fprintf(fid11,format1, stnj,X([6 4 5]),Y); fprintf(fid11, '\r\n');
            fprintf(fid12,format2, stnj,X(3:6),Y); fprintf(fid12, '\r\n');
        else
            fprintf(fidv1,format1, stnj,X(1:3),Y); fprintf(fidv1, '\r\n');
            fprintf(fidv2,format1, stnj,X([1 2 6]),Y); fprintf(fidv2, '\r\n');
            fprintf(fidv3,format2, stnj,X([1 2 3 6]),Y); fprintf(fidv3, '\r\n');
            fprintf(fidv4,format3, stnj,X(1:5),Y); fprintf(fidv4, '\r\n');
            fprintf(fidv5,format3, stnj,X([1 2 6 4 5]),Y); fprintf(fidv5, '\r\n');
            fprintf(fidv6,format4, stnj,X,Y); fprintf(fidv6, '\r\n');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(fidv7,format01, stnj,X(3),Y); fprintf(fidv7, '\r\n');
            fprintf(fidv8,format01, stnj,X(6),Y); fprintf(fidv8, '\r\n');
            fprintf(fidv9,format02, stnj,X([3 6]),Y); fprintf(fidv9, '\r\n');
            fprintf(fidv10,format1, stnj,X(3:5),Y); fprintf(fidv10, '\r\n');
            fprintf(fidv11,format1, stnj,X([6 4 5]),Y); fprintf(fidv11, '\r\n');
            fprintf(fidv12,format2, stnj,X(3:6),Y); fprintf(fidv12, '\r\n');
        end
    end
    exind = exind + 1;
    ymd = str2double(ymdays);
    A = [ymd jj];
    xlswrite(filename0,A,1,strcat('A',num2str(exind)));
    
    fclose(fid1);   fclose(fidv1);  movefile(otxt1,Preout);  movefile(vtxt1,Preout);
    fclose(fid2);   fclose(fidv2);  movefile(otxt2,Preout);  movefile(vtxt2,Preout);
    fclose(fid3);   fclose(fidv3);  movefile(otxt3,Preout);  movefile(vtxt3,Preout);
    fclose(fid4);   fclose(fidv4);  movefile(otxt4,Preout);  movefile(vtxt4,Preout);
    fclose(fid5);   fclose(fidv5);  movefile(otxt5,Preout);  movefile(vtxt5,Preout);
    fclose(fid6);   fclose(fidv6);  movefile(otxt6,Preout);  movefile(vtxt6,Preout);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fclose(fid7);   fclose(fidv7);  movefile(otxt7,Preout);  movefile(vtxt7,Preout);
    fclose(fid8);   fclose(fidv8);  movefile(otxt8,Preout);  movefile(vtxt8,Preout);
    fclose(fid9);   fclose(fidv9);  movefile(otxt9,Preout);  movefile(vtxt9,Preout);
    fclose(fid10);   fclose(fidv10);  movefile(otxt10,Preout);  movefile(vtxt10,Preout);
    fclose(fid11);   fclose(fidv11);  movefile(otxt11,Preout);  movefile(vtxt11,Preout);
    fclose(fid12);   fclose(fidv12);  movefile(otxt12,Preout);  movefile(vtxt12,Preout);
    toc;
end
clear;
    