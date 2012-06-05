

%file_name = 'group1_B_plyr1_0.txt';
% x = dlmread(file_name);   
% x(:,1) = note time
% x(:,2) = note x (timbre)
% x(:,3) = note y (pitch)

dir = 'groupA_txt/first/';
files = getFileNames(dir, 'txt');

for i=1:length(files)
    file_name = strcat(dir,files(i));
    x = dlmread(file_name);
    X{i} = x;
end





