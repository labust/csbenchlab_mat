function {{output_args_fn}} = fcn({{input_args}}, pid__, iid__)
    coder.extrinsic('fcn_{{function_name}}_ext');
{{extrinsic_init}};
        {{output_args_fn}} = fcn_{{function_name}}_ext({{input_args}}, pid__, iid__);
end

function log = eval_log(data)
    {{logging_define}}
end

