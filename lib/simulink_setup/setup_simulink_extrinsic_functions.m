function setup_simulink_extrinsic_functions(curr_model, info, blocks)
    ext_value = 0;
    if isfield(info.Metadata, 'CoderExtrinsic')
        ext_value = info.Metadata.CoderExtrinsic;
    end
    mws = get_param(curr_model, 'modelworkspace');
    mws.assignin('extrinsic', ext_value);

    for i=1:length(blocks.cs_blocks)
        b = blocks.cs_blocks{i};
        setup_extrinsic_functions_for_component(curr_model, b, ext_value);        
    end
end