function p = distribution2d_pair(signal,pair_offset)
%UNTITLED Summary of this function goes here
%   Confrontation goes here

symbol_count = zeros(max(max(signal)));

for row = 1:size(signal, 1)- pair_offset(1)
    for col = 1:size(signal,2)- pair_offset(2)
        index = signal(row,col);
        index2 = signal(row + pair_offset(1),col+ pair_offset(2));
        symbol_count(index, index2) = symbol_count(index, index2) + 1;
    end
end

p = symbol_count/(numel(signal)-1);

end