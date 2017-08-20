function out = meanofMV(x1, x2)

if nargin == 1
    out = min(x1);
else
    ht = sum(x1(:,1));
    [r,c] = size(x2);
    out = zeros(r,c);
    for i = 1:r
        mv(i) = mean(find(x2(i,:) >= x1(i,1)))/c;
        out(i,:) = x1(i,1) * mv(i) / ht;
%         x1(i,1)
%         mv(i)
%         out(i,1)
    end
end
end
    