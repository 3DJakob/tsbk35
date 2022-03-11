function [p] = distribution(insignal)
%DISTRIBUTION

% Fördelning
symbol_count = zeros(max(insignal), 1);
for i = 1:size(insignal, 1)
    index = insignal(i);
    symbol_count(index) = symbol_count(index) + 1;
end
% Fördelning av singalen
p = symbol_count/size(insignal, 1);
end

