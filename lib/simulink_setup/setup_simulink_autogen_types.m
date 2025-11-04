function setup_simulink_autogen_types(curr_model, blocks)
    
    hws = get_param(curr_model, 'modelworkspace');
    if ~exist('blocks', 'var')
        % this means that load did not yet happen. Skipping...
        if ~hws.hasVariable('gen_blocks')
            return
        end
        blocks = hws.getVariable('gen_blocks');
    end

    for i=1:length(blocks.cs_blocks)
        setup_simulink_autogen_types_for_component(curr_model, blocks.cs_blocks{i}, hws);
    end
end