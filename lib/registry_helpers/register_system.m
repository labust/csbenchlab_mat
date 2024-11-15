function register_system(info, lib_name)

    block_name = convertStringsToChars(info.info.Name);

    block_path = strcat(lib_name, '_sys', '/', block_name);
    handle = getSimulinkBlockHandle(block_path);
    if ~(handle == -1)
        delete_block(block_path);    
    end
    handle = add_block('simulink/Ports & Subsystems/Subsystem', block_path); 


    inport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Inport'));
    outport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Outport'));
    
    inport_h_p = get_param(inport_h, 'PortHandles');
    outport_h_p = get_param(outport_h, 'PortHandles');

    delete_line(block_path, inport_h_p.Outport, outport_h_p.Inport);

    delete_block(inport_h); delete_block(outport_h);


    fun_block_name = [block_name, '_fun'];
    fun_block_path = [block_path, '/', fun_block_name];

    params_name = [lower(block_name), '_params'];

    fun_handle = add_block('simulink/User-Defined Functions/MATLAB Function', fun_block_path); 
    fun_block = get_function_block(block_path, fun_block_name);


    fun_block.ChartUpdate = 'DISCRETE';
    fun_block.SampleTime = '-1';
    system_name = info.info.Name;
    fun_block.Script = "function y = fcn(u, t, dt, ic, params)" + newline ...
        + "  persistent system" + newline...
        + "  if isempty(system)" + newline...
        + "    system = " + system_name + "(params);" + newline...
        + "    system = system.configure(ic);" + newline...
        + "  end" + newline...
        + " [system, y] = system.step(u, t, dt);" + newline...
        + "end";

    fun_block.Inputs(5).Tunable = 0;
    fun_block.Inputs(5).Scope = "Parameter";
    fun_p = get_param(fun_handle, 'PortHandles');
    fun_pos = get_param(fun_handle, 'Position');


    u_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/u']); 
    inport_u_p = get_param(u_handle, 'PortHandles');
    block_offset(u_handle, fun_pos, [-150 -15]);

    t_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/t']); 
    inport_t_p = get_param(t_handle, 'PortHandles');
    block_offset(t_handle, fun_pos, [-150 0]);

    dt_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/dt']); 
    inport_dt_p = get_param(dt_handle, 'PortHandles');
    block_offset(dt_handle, fun_pos, [-150 15]);

    ic_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/ic']); 
    inport_ic_p = get_param(ic_handle, 'PortHandles');
    block_offset(ic_handle, fun_pos, [-150 30]);

    y_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Outport', [block_path, '/y']); 
    outport_y_p = get_param(y_handle, 'PortHandles');
    block_offset(y_handle, fun_pos, [150 0]);

    
    add_line(block_path, inport_u_p.Outport, fun_p.Inport(1), "autorouting", "smart");
    add_line(block_path, inport_t_p.Outport, fun_p.Inport(2), "autorouting", "smart");
    add_line(block_path, inport_dt_p.Outport, fun_p.Inport(3), "autorouting", "smart");
    add_line(block_path, inport_ic_p.Outport, fun_p.Inport(4), "autorouting", "smart");
    add_line(block_path, fun_p.Outport, outport_y_p.Inport, "autorouting", "smart");
    
    set_param(handle,'MaskStyles', {'edit'}, ...
        'MaskVariables', 'params=@1;', ...
        'MaskPrompts', {'Parameter struct:'}, ...
        'MaskValues', {params_name}); 
    get_param(handle,'MaskStyles');

end
