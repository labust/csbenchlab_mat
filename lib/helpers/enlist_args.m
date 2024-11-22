function s = enlist_args(a)
    if isempty(a)
        s = '';
        return
    end
    s = [sprintf('%s, ',a{1:end-1}), a{end}];
end