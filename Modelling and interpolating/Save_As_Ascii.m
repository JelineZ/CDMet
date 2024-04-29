% Save 2D matrices in ascii, can be opened in arcmap
% Written by Shouzhang Peng, May/31/2021
% gisinfo = [xllcorner yllcorner cellsize NODATA_value];

function Save_As_Ascii(PathName,FileName,data,gisinfo)
[llon, llat] = size(data);
fid = fopen(strcat(PathName, FileName),'w');

% Write header file
fprintf(fid,'%s','ncols         ');  fprintf(fid,'%d\r\n', llon);
fprintf(fid,'%s','nrows         '); fprintf(fid,'%d\r\n', llat);
fprintf(fid,'%s','xllcorner     ');  fprintf(fid,'%15.12f\r\n', gisinfo(1));
fprintf(fid,'%s','yllcorner     ');  fprintf(fid,'%15.12f\r\n', gisinfo(2));
fprintf(fid,'%s','cellsize      ');  fprintf(fid,'%17.15f\r\n', gisinfo(3));
fprintf(fid,'%s','NODATA_value  ');  fprintf(fid,'%d\r\n', gisinfo(4));

% Write to matrix, line by line on map, matrix by columns
for i = 1: llat
    fprintf(fid,'%f ',data(:, i));
    fprintf(fid,'%s\r\n', ' ');
end
fclose(fid);
end