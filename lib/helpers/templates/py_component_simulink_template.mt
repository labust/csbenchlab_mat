function {{output_args_fn}} = fcn({{input_args}}, pid__, iid__)
    coder.extrinsic('fcn_{{function_name}}_ext');
{{extrinsic_init}};
        [data_n, {{output_args}}] = fcn_{{function_name}}_ext({{input_args}}, pid__, iid__);
        log = eval_log(data_n);
end

function log = eval_log(data)
    {{logging_define}}
end

