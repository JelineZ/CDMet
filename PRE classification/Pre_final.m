% Dot-multiplying the results of precipitation classification and precipitation regression to get the final results of precipitation

clear;clc;
load Date.mat
var = 'pre';
for year = 2006 : 2006
    tic;
    if mod(year,4) == 0
        daynum = 366;
        bound = 274;
        dat = Date(:,2);
    else
        daynum = 365;
        bound = 273;
        dat = Date(:,1);
    end
    mkdir(strcat('./Precipitation_Final/Precipitation_Final  ',num2str(year)));  
    folder =  strcat('./Precipitation_Final/Precipitation_Final',num2str(year));
    for i = 332 : daynum
        if i <= bound
            ymd = strcat(num2str(year),'0',num2str(dat(i)));
        else
            ymd = strcat(num2str(year),num2str(dat(i)));
        end
        %  Read the regression results
        nclist =  dir(strcat('E:/tif2nc/Precipitation/Precipitation',num2str(year),'/*',ymd,'*'));
        ncfile1 = nclist(1).name;
        ncid =  netcdf.open(strcat(nclist(1).folder,'\',ncfile1),'NOWRITE');
        ncdata_r = netcdf.getVar(ncid,2);
        netcdf.close(ncid);
        %  Read the classification results
        ncfile2 =  strcat('./Precipitation/Precipitation',num2str(year),'/Classification/',var,'-',ymd,'-class.nc');
        ncid2 = netcdf.open(ncfile2,'NOWRITE');
        ncdata_c = netcdf.getVar(ncid2,2);
        netcdf.close(ncid2);

        filename = './Geodata/slope_2_5m.nc';
        ncid = netcdf.open(filename,'NOWRITE');
        lon_G = netcdf.getVar(ncid,0);   % 2160*1
        lat_G = netcdf.getVar(ncid,1);   % 1118*1
        slope = netcdf.getVar(ncid,2);   % 2160*1118
        netcdf.close(ncid);
        attvalue = ncreadatt(filename,'slo','missing_value'); 
        llon = length(lon_G);
        llat = length(lat_G);

        % Dot product, ncdata_pre is the final result.
        ncdata = ncdata_r .* ncdata_c;

        % Build nc file and output
        ncdata(slope == attvalue) = -32768;  
        name = strcat(var,'-',ymd,'-final.nc');
        nccreate(name,'lon','Dimensions',{'lon'  llon},'Datatype','double','Format','classic');
        nccreate(name,'lat','Dimensions',{'lat'  llat},'Datatype','double','Format','classic');
        nccreate(name,var,'Dimensions',{'lon' llon 'lat'  llat},'Datatype','single','Format','classic');
        ncwrite(name,'lon',lon_G);
        ncwrite(name,'lat',lat_G);
        ncwrite(name,var,ncdata);
        ncwriteatt(name,'lon','long_name','longitude');
        ncwriteatt(name,'lon','unit','degree');
        ncwriteatt(name,'lat','long_name','latitude');
        ncwriteatt(name,'lat','unit','degree');
        ncwriteatt(name,var,'long_name','Daily Total Precipitation');   %%%%%%修改变量属性名称
        ncwriteatt(name,var,'unit','mm');
        ncwriteatt(name,var,'missing_value',-32768);
        movefile(name,folder);
    end
    disp(strcat('year..',num2str(year)));
    toc;
end