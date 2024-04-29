% Find the row and column numbers of the coordinates x,y in the nc file.
function [row,col] = findxy(x,y,lon,lat)

row = [];
col = [];

for i = 2: ( length(lon) - 1 ) 
    
    left  = ( lon(i) - lon(i - 1) ) / 2;
    right = ( lon(i + 1) - lon(i) ) / 2;
    
    if left < 0
        b = abs (left);
        a = abs (right);
    else
        a = left;
        b = right;
    end
    
    if ( x >= ( lon(i) - a ) ) && ( x <= ( lon(i) + b ) )
        row = i;
        break;
    end
end

for j = 2: ( length(lat) -1 ) 
    
    left  = ( lat(j) - lat(j - 1) ) / 2;
    right = ( lat(j + 1) - lat(j) ) / 2;
    
    if left < 0
        b = abs (left);
        a = abs (right);
    else
        a = left;
        b = right;
    end
    
    if ( y >= ( lat(j) - a ) ) && ( y <= ( lat(j) + b ) )
        col = j;
        break;
    end
end   

end