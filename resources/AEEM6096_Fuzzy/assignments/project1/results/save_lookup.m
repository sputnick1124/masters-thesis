
data0 = zeros(101,101,101);
data1 = zeros(101,101,101);
data2 = zeros(101,101,101);
data = {data0,data1,data2};
for out = 0:2
    page = 1;
    for i = 0:0.01:1
        fn = sprintf('lookup_table%d-%0.2f.csv',out,i);
        data{out+1}(:,:,page) = csvread(fn);
        page = page + 1;
    end
end
data0 = data{1};
data1 = data{2};
data2 = data{3};
save('../lookup_table.mat','data0','data1','data2');