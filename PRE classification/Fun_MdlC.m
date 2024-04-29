% All-region interpolation
function Fun_MdlC(Loca,Mdl0,ymdays,var)

ncfile = strcat('./Preprocess_PRE/Data/',var,ymdays,'.nc');

filename = './Preprocess_PRE/Geodata/slope_2_5m.nc';
ncid = netcdf.open(filename,'NOWRITE');
lon_G = netcdf.getVar(ncid,0);   % 2160*1
lat_G = netcdf.getVar(ncid,1);   % 1118*1
slope = netcdf.getVar(ncid,2);   % 2160*1118
netcdf.close(ncid);

attvalue = ncreadatt(filename,'slo','missing_value');
llon = length(lon_G);
llat = length(lat_G);
data = zeros(llon,llat,'single');

for m = 1: llat  
    lon0 = lon_G;
    lat0 = ones(llon,1) * lat_G(m); 
    dem0 = ncread('./Preprocess_PRE/Geodata/dem_2_5m.nc','dem',[1 m],[llon 1]); dem0 = single(squeeze(dem0));  
    asp0 = ncread('./Preprocess_PRE/Geodata/aspect_2_5m.nc','asp',[1 m],[llon 1]); asp0 = squeeze(asp0);   
    slo0 = ncread('./Preprocess_PRE/Geodata/slope_2_5m.nc','slo',[1 m],[llon 1]); slo0 = squeeze(slo0);   
    era0 = ncread(ncfile,'pre',[1 m],[llon 1]); era0 = squeeze(era0); 
    switch Loca
        case 1 
            XX = [lon0 lat0 dem0];
        case 2
            XX = [lon0 lat0 era0];
        case 3
            XX = [lon0 lat0 dem0 era0];
        case 4
            XX = [lon0 lat0 dem0 asp0 slo0];
        case 5
            XX = [lon0 lat0 era0 asp0 slo0];
        case 6
            XX =[lon0 lat0 dem0 asp0 slo0 era0];
    end
    YY = predict(Mdl0,XX);
    YY = char(YY);
    YY = str2num(YY);
    data(:,m) = YY;  
end 

data(slope == attvalue) = -32768;
name = strcat(var,'-',ymdays,'-class.nc');  
nccreate(name,'lon','Dimensions',{'lon' llon},'Datatype','double','Format','classic');  
nccreate(name,'lat','Dimensions',{'lat' llat},'Datatype','double','Format','classic');
nccreate(name,var,'Dimensions',{'lon' llon 'lat' llat},'Datatype','single','Format','classic');
ncwrite(name,'lon',lon_G);
ncwrite(name,'lat',lat_G);
ncwrite(name,var,data); clear data;
ncwriteatt(name,'lon','long_name','longitude');
ncwriteatt(name,'lon','unit','degree');
ncwriteatt(name,'lat','long_name','latitude');
ncwriteatt(name,'lat','unit','degree');
ncwriteatt(name,var,'long_name','Daily precipitation');
ncwriteatt(name,var,'unit','mm');
ncwriteatt(name,var,'missing_value',-32768);
movefile(name,'Classification');
end
