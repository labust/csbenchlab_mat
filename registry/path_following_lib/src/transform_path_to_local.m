function local_path = transform_path_to_local(pose, global_path)
    local_path = zeros(size(global_path, 1), size(global_path, 2));
    for i=1:height(global_path)
        local_path(i, :) = transform_point(pose, global_path(i, :));
    end
end


function p2 = transform_point(pose, p)
    y = pose(3);
    dx = p(1) - pose(1);
    dy = p(2) - pose(2);
    p2 = [dx * cos(y) + dy * sin(y), ...
          -dx * sin(y) + dy * cos(y), p(3)-y ];
end