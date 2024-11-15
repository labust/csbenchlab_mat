function ref = generate_reference(t_sim, Ts, num_dims, steps, dim)

    n_k = round(t_sim / Ts);

    n_steps = length(steps);
    duration = round(n_k / n_steps);

    ref_x = zeros(n_steps * duration, num_dims);

    n_k = length(ref_x);

    for i=1:n_steps
        b = (i-1)*duration + 1;
        ref_x(b:b+duration-1, dim) = steps(i) * ones(duration, 1);
    end

    time = linspace(0, n_k-1, n_k)'*Ts;

    ref = timeseries(ref_x, time);
end