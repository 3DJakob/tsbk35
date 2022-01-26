function p=probability(insignal)

occurence = zeros(max(insignal), 1);

    for i = 1:size(insignal, 1)
        occurence(insignal(i)) = occurence(insignal(i)) + 1;
    end

    p = occurence/size(insignal, 1);

end

