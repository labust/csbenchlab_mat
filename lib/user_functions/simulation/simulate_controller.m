function result = simulate_controller(deepc, otter_model, y_ref, Ts)
    n_step = length(y_ref);
    res_vec = zeros(n_step, length(deepc.data.x_op));
    L = deepc.params.L;
    input_sz = deepc.data.m;
    output_sz = deepc.data.p;
    true_vec = zeros(n_step, L);
    noise_vec = zeros(n_step, L);
    
    otter_model = otter_model.reset();

    ref = zeros(L, 1);
    u_vec = zeros(n_step, input_sz);
    y_vec = zeros(n_step, output_sz);
    y = deepc.data.yini(end, :);
    for i=1:round(n_step)

        if i + L <= length(y_ref)
            ref(:) = y_ref(i:i+L-1);
        else
            ref(1:end-1, :) = ref(2:end, :);
            ref(end, :) = y_ref(end, :);
        end
        
        [deepc, ~] = deepc.step(ref, y, Ts);

        uv = deepc.data.x_op_u;

        res_vec(i, :) = deepc.data.x_op; 
        [y_noise, y_act] = otter_model.sim(uv, 0, Ts);
        u_vec(i, :) = uv(1, :);
        [otter_model, y] = otter_model.step(uv(1, :), 0, Ts);
        y_vec(i, :) = y;        

        true_vec(i, :) = y_act;
        noise_vec(i, :) = y_noise;


        % close all;
        % t_vec =  (0:1:L-1)*Ts;
        % plot(t_vec, deepc.data.x_op_y); 
        % hold on; 
        % yini = deepc.data.yini;
        % plot(t_vec, [yini(end); y_act(1:end-1)])    
        % a = 5;
    end
    result.optim = res_vec;
    result.hotizon_pred = true_vec;
    result.hotizon_pred_noise = noise_vec;
    result.u = u_vec;
    result.y = y_vec;
    result.t = (1:1:n_step)*Ts;
end