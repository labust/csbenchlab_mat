classdef Utils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function y = saturate(x, x_min, x_max)
            y = x;
            for i=1:length(x)
                if x(i) > x_max
                    y(i) = x_max;
                elseif x(i) < x_min
                    y(i) = x_min;
                end
            end
        end

        function y = saturate2(x, x_min, x_max)
            y = x;
            for j=1:size(x, 2)
                y(x(:, j) < x_min(j)) = x_min(j);
                y(x(:, j) > x_max(j)) = x_max(j);
            end
        end

    end
end

