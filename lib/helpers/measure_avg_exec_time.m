function t = measure_avg_exec_time(fh, n, varargin) 
    tic;
    for i=1:n
        fh(varargin{:});
    end
    end_time = toc;
    t = end_time / n;
end