function [H] = entropyOfDistribution(p)
%Entropy 

H = -nansum(p.*log2(p));

end

