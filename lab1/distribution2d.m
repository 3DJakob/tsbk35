function p = distribution2d(data)
%DISTRIBUTION2D Summary of this function goes here
%   Detailed explanation doesn't exist

symbolCount = zeros(max(max(data))+1,1);

for i = 1:size(data, 1)
    for k = 1:size(data, 2)
        index = uint8(data(i,k))+1;
        
        symbolCount(index) = symbolCount(index) + 1;
    end
end

p = symbolCount / numel(data);

end

