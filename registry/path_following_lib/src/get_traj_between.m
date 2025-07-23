function t = get_traj_between(p1, p2, n)
    
    t = zeros(n, size(p1, 2));
    
    p = (p2-p1)/n;
    
    for i=1:n
        t(i, :) = p1 + p * i;
    end

end