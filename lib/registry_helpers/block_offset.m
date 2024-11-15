function block_offset(handle, point, offset)
    pos = get_param(handle, 'Position');
    w = pos(3) - pos(1);
    h = pos(4) - pos(2);
    c = [(point(3) + point(1))/2 + offset(1), (point(4) + point(2))/2 + offset(2)];
    r = [c(1)-w/2, c(2)-h/2, c(1) + w/2, c(2) + h/2];
    set_param(handle, 'Position', r);
end
