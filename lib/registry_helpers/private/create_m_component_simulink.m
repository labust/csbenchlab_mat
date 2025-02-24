function block_path = create_m_component_simulink(info, lib_name, comp_type, tags, inputs, outputs, ctor_args, cfg_args, step_args, mask_parameters, extrinsic_init, icon, size)
    block_name = convertStringsToChars(info.Name);
    
    sim_lib_name = strcat(lib_name, '_', comp_type);

    h_first = getSimulinkBlockHandle(sim_lib_name);

    if h_first == -1
        load_and_unlock_system(sim_lib_name);
    end

    block_path = strcat(sim_lib_name, '/', block_name);
    handle = getSimulinkBlockHandle(block_path);
    if handle ~= -1
        delete_block(block_path);    
    end
    handle = add_block('simulink/Ports & Subsystems/Subsystem', block_path); 
    for i=1:length(tags)
        model_append_tag(handle, tags{i});
    end

    % delete io ports from subsystem, they will be created later
    inport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Inport'));
    outport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Outport'));
    
    inport_h_p = get_param(inport_h, 'PortHandles');
    outport_h_p = get_param(outport_h, 'PortHandles');

    delete_line(block_path, inport_h_p.Outport, outport_h_p.Inport);
    delete_block(inport_h); delete_block(outport_h);


    % create function block
    fun_block_name = [block_name, '_fun'];
    fun_block_path = [block_path, '/', fun_block_name];


    fun_handle = add_block('simulink/User-Defined Functions/MATLAB Function', fun_block_path); 
    fun_block = get_function_block(block_path, fun_block_name);

    fun_block.ChartUpdate = 'DISCRETE';
    fun_block.SampleTime = '-1';
    obj_name = info.Name;
    
    input_cell = arrayfun(@(x) {x.Name}, inputs);
    output_cell = arrayfun(@(x) {x.Name}, outputs);
    unique_name = replace(string(java.util.UUID.randomUUID.toString), '-', '');
    fun_block.Script = "% __classname:=" + obj_name + ";" + newline ...        
        + "function " + bracket_outputs(output_cell) + " = fcn(" + enlist_args(input_cell) + ", extrinsic)" + newline ...            
        + "  coder.extrinsic('fcn_" + unique_name + "_ext');" + newline...
        + "  if extrinsic" + newline...
        + "      " + extrinsic_init + ";" + newline...
        + "      " + bracket_outputs(output_cell) + " = fcn_" + unique_name + "_ext(" + enlist_args(input_cell) + ");" + newline...
        + "  else" + newline...
        + "      " + bracket_outputs(output_cell) + " = fcn_" + unique_name + "(" + enlist_args(input_cell) + ");" + newline...
        + "  end" + newline...
        + "end" + newline...
        + newline...
        + "function " + bracket_outputs(output_cell) + " = fcn_" + unique_name + "(" + enlist_args(input_cell) + ")" + newline ...            
        + "  persistent obj" + newline...
        + "  if isempty(obj)" + newline...
        + "    obj = " + obj_name + "(" + enlist_args(ctor_args) + ");" + newline...
        + "    obj = obj.configure(" + enlist_args(cfg_args) + ");" + newline...
        + "  end" + newline...
        + "  " + bracket_outputs([{'obj'}, output_cell(:)']) +" = obj.step(" + enlist_args(step_args) + ");" + newline...
        + "end";
    % extrinsic parameter
    fun_block.Inputs(end).DataType = 'int32';
    fun_block.Inputs(end).Tunable = 0;
    fun_block.Inputs(end).Scope = 'Parameter';
    
    for i=length(inputs):-1:1
        fun_block.Inputs(i).Tunable = inputs(i).Tunable;
        if ~isempty(inputs(i).DataType)
            fun_block.Inputs(i).DataType = inputs(i).DataType;
        end
        if ~isempty(inputs(i).Scope)
            fun_block.Inputs(i).Scope = inputs(i).Scope;
        end
    end

    for i=length(outputs):-1:1
        if ~isempty(outputs(i).DataType)
            fun_block.Outputs(i).DataType = outputs(i).DataType;
        end
    end

    fun_p = get_param(fun_handle, 'PortHandles');
    fun_pos = get_param(fun_handle, 'Position');

    pos = [-150 -15];
    in_handles = [];
    in_ports = {};
    for i=1:length(fun_p.Inport)
        in_handles(end+1) = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', strcat(block_path, '/', input_cell{i})); 
        in_ports{end+1} = get_param(in_handles(end), 'PortHandles');
        block_offset(in_handles(end), fun_pos, pos);
        add_line(block_path, in_ports{i}.Outport, fun_p.Inport(i), "autorouting", "smart");

        pos = [pos(1), pos(2) + 15];

    end
    
    pos = [150, 0];
    out_handles = [];
    out_ports = {};
    for i=1:length(fun_p.Outport)
        out_handles(end+1) = add_block('simulink/Quick Insert/Ports & Subsystems/Outport', strcat(block_path, '/', output_cell{i})); 
        out_ports{end+1} = get_param(out_handles(end), 'PortHandles');
        block_offset(out_handles(end), fun_pos, pos);
        add_line(block_path, fun_p.Outport(i), out_ports{i}.Inport, "autorouting", "smart");
        pos = [pos(1), pos(2) + 15];
    end
    mo = Simulink.Mask.create(handle);

    for i=1:length(mask_parameters)
        mo.addParameter('Name', mask_parameters(i).Name, ...
            'Value', replace(mask_parameters(i).Value, '{block_name}', block_name), ...
            'Visible', mask_parameters(i).Visible, ...
            'Prompt', mask_parameters(i).Prompt, ...
            'Evaluate', mask_parameters(i).Evaluate);
    end
    set_param(handle, 'MaskObject', mo);

    if exist("icon", 'var')
        set_param(handle, 'MaskBlockDVGIcon', strcat('MaskBlockIcon.', icon));
        set_param(handle, 'MaskIconRotate', 'off');
    end

    if ~exist("size", 'var')
        size = [80, 50];
    end

    GRID_LEN = 4;
    count = length(find_system(sim_lib_name, 'SearchDepth', 1)) - 1;
    idx_j = floor((count-1) / GRID_LEN) + 1;
    idx_i = mod((count-1), GRID_LEN) + 1;
    dl = 200;
    
    position = [idx_i * dl, idx_j * dl, idx_i * dl + size(1), idx_j * dl + size(2)]';
    set_param(handle, 'Position', position);

    save_system(sim_lib_name);
    
    if h_first == -1
        close_system(sim_lib_name);
    end

end


function o = bracket_outputs(o)
   if length(o) > 1
       o = strcat('[', enlist_args(o), ']');
   end   
end