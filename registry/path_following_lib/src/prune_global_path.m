function idx = prune_global_path(pose, global_path, idx, dist, min_path_len)
    ds = arrayfun(@(x1, y1, x2, y2) hypot(x1 -  x2, y1 - y2), ...
        global_path(idx:end-1, 1), global_path(idx:end-1, 2), global_path(idx+1:end, 1), global_path(idx+1:end, 2));
    ds0 = hypot(pose(1) - global_path(idx, 1), pose(2) - global_path(idx, 2));
    s = cumsum([ds0; ds], 1);

    last0 = find(s < dist, 1, "last");
    if isempty(last0)
        return
    end
    if last0 + idx >= length(global_path) - min_path_len
        idx = length(global_path) - min_path_len;
    elseif last0 > 0
        idx = idx + last0(1);
    end
end