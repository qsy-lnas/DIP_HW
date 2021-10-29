function output = divide1(dis, var, imag_id)
H_gaussian = fspecial('gaussian', 3, 3);
[M, N] = size(dis);
dis = padarray(dis, [1, 1], 0);
dis = imfilter(dis, H_gaussian);
dis = padarray(dis, [1, 1], 0);
output = zeros(M, N);
if (imag_id == 1)
    validmin = 29;
    validmax = 30;
elseif (image_id == 2)
    validmin = 20;
    validmax = 40;
else 
    validmin = 19;
    validmax = 31;
end
for i = 2:M+1
    for j =2:N+1
        if(sum(sum(dis(i-1:i+1,j-1:j+1)))>validmin &&sum(sum(dis(i-1:i+1,j-1:j+1))) < validmax)
            if(flag == 2 && var(i-1,j-1)<var_stdmax &&var(i-1,j-1)>var_stdmin)
                output(i-1,j-1) = 1;
            end
            if(flag == 1)
                output(i-1,j-1) = 1;
            end
        end
    end
end

if 