classdef Utils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function y = saturate(x, x_min, x_max)
            y = x;
            for j=1:size(x, 2)
                y(x(:, j) < x_min(j)) = x_min(j);
                y(x(:, j) > x_max(j)) = x_max(j);
            end
        end
    end
end

