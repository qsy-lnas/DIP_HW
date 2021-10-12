function obj = DrawDir(fig,dir,BLK_SIZE,LineSpec,ROI)
% Draw blockwise orientaion field
%
% Inputs:
%   dir         - [-90,90]
%   ROI         - (Optional) Blockwise region mask, 1 means fingerprint.
%
% Jianjiang Feng
% 2007-3

linecolor = LineSpec(1);
if length(LineSpec)>1
    linewidth = str2num(LineSpec(2));
else
    linewidth = 1;
end

len = BLK_SIZE*0.8;

figure(fig),hold on
%BLK_SIZE = 16;
% idx = find(dir>90);
% if ~isempty(idx)
%     dir(idx) = dir(idx)-180;
% end
[h,w] = size(dir);
obj = zeros(h,w);


for row = 1:h
    for col = 1:w
        if (dir(row,col)>90 | dir(row,col)<-90) | (nargin>4 & ROI(row,col)==0)
            obj(row,col) = -1;
            continue
        end
        
        cx = (col-1)*BLK_SIZE+BLK_SIZE/2;
        cy = (row-1)*BLK_SIZE+BLK_SIZE/2;
        if 1
            linex(1) = cos(dir(row,col)*pi/180)*len/2;
            linex(2) = -cos(dir(row,col)*pi/180)*len/2;
            liney(1) = -sin(dir(row,col)*pi/180)*len/2;
            liney(2) = sin(dir(row,col)*pi/180)*len/2;
        else
            if dir(row,col)==90
                linex(1) = 0;
                liney(1) = -len/2;
                linex(2) = 0;
                liney(2) = len/2;
            elseif dir(row,col)<=45 & dir(row,col)>=-45
                linex(1) = -len/2;
                liney(1) = -linex(1)*tan(dir(row,col)*pi/180);
                linex(2) = len/2;
                liney(2) = -linex(2)*tan(dir(row,col)*pi/180);
            else
                liney(1) = -len/2;
                linex(1) = -liney(1)/tan(dir(row,col)*pi/180);
                liney(2) = len/2;
                linex(2) = -liney(2)/tan(dir(row,col)*pi/180);
            end

            linex(1) = cut(linex(1),-len/2,len/2);
            liney(1) = cut(liney(1),-len/2,len/2);
            linex(2) = cut(linex(2),-len/2,len/2);
            liney(2) = cut(liney(2),-len/2,len/2);
        end
        
        linex = linex+cx;
        liney = liney+cy;
        obj(row,col) = line(linex,liney,'color',linecolor,'linewidth',linewidth);
    end
end



function y = cut(x,minval,maxval)
y=x;
if y<minval
    y=minval;
end
if y>maxval
    y=maxval;
end
