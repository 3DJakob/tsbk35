function Y = padshift(X, offset, pad_value)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

temp = circshift(padarray(X, [1 1], pad_value, 'both'),offset);
Y = temp(2:end-1,2:end-1);

end