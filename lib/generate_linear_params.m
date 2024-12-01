function params = generate_linear_params(sys)

    if isa(sys, 'idss')
        as_ss = sys;
    elseif isa(sys, 'tf')
        as_ss = idss(sys);
    end

    params.A = as_ss.A;
    params.B = as_ss.B;
    params.C = as_ss.C;
    params.D = as_ss.D;
    params = make_m_component_params('LinearSystem', params);

end

