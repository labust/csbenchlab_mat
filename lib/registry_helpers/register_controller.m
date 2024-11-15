function register_controller(info, lib_name)

    block_name = convertStringsToChars(info.info.Name);

    block_path = strcat(lib_name, '_ctl', '/', block_name);
    handle = getSimulinkBlockHandle(block_path);

    if ~(handle == -1)
        delete_block(block_path);    
    end

    input_str = '';
    io_args = get_m_controller_inputs(info.info.Name);
    input_len = length(io_args);
    for j=1:input_len
        input_str = strcat(input_str, ', ', io_args{j}.Name);
    end

    handle = add_block('simulink/Ports & Subsystems/Subsystem', block_path); 
    model_append_tag(handle, 'controller');
    model_append_tag(handle, 'm_controller');

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
    data_name = [lower(block_name), '_data'];

   

    controller_name = info.info.Name;
    fun_handle = add_block('simulink/User-Defined Functions/MATLAB Function', fun_block_path); 
    fun_block = get_function_block(block_path, fun_block_name);

    fun_block.ChartUpdate = 'DISCRETE';
    fun_block.SampleTime = '-1';

    fun_block.Script = "% __classname:=" + controller_name + ";" + newline ...
        + "function [u, log] = fcn(y_ref, y, dt" ...
        + input_str + ", params, data)" + newline ...
        + "  persistent controller" + newline...
        + "  if isempty(controller)" + newline...
        + "    controller = " + controller_name + "(params, 'Data', data);" + newline...
        + "    controller = controller.configure(1, size(y), size(y_ref));" + newline...
        + "  end" + newline...
        + " [controller, u, log] = controller.step(y_ref, y, dt" ...
        + input_str + ");" + newline...
        + "end";

    input_begin_idx = 4;
    params_idx = 4 + input_len;
    
    fun_block.Inputs(params_idx).Tunable = 1; % TO AVOID RECOMPILATION
    fun_block.Inputs(params_idx).DataType = "ParamsType";
    fun_block.Inputs(params_idx).Scope = "Parameter";

    fun_block.Outputs(2).DataType = 'LogEntryType';

    % data is now at idx 'params_idx'
    fun_block.Inputs(params_idx).Tunable = 1;
    fun_block.Inputs(params_idx).DataType = "DataType";

    fun_block.Inputs(params_idx).Scope = "Parameter";

    % set input types
    for j=1:input_len
        fun_block.Inputs(input_begin_idx+j-1).DataType = ...
            strcat(io_args{j}.Name, "_T");
    end

    fun_p = get_param(fun_handle, 'PortHandles');
    fun_pos = get_param(fun_handle, 'Position');

    y_ref_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/y_ref']); 
    inport_y_ref_p = get_param(y_ref_handle, 'PortHandles');
    block_offset(y_ref_handle, fun_pos, [-100 -30]);

    y_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/y']); 
    inport_y_p = get_param(y_handle, 'PortHandles');
    block_offset(y_handle, fun_pos, [-250 0]);


    dt_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', [block_path, '/dt']); 
    inport_dt_p = get_param(dt_handle, 'PortHandles');
    block_offset(dt_handle, fun_pos, [-100 20]);

    u_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Outport', [block_path, '/u']); 
    outport_u_p = get_param(u_handle, 'PortHandles');
    block_offset(u_handle, fun_pos, [200 -10]);

    log_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Outport', [block_path, '/log']); 
    outport_log_p = get_param(log_handle, 'PortHandles');
    block_offset(log_handle, fun_pos, [200 10]);


    delay_handle = add_block('simulink/Commonly Used Blocks/Delay', [block_path, '/z_1']); 
    inport_delay_p = get_param(delay_handle, 'PortHandles');
    set_param(delay_handle, 'DelayLength', num2str(1));
    block_offset(delay_handle, fun_pos, [-150 0]);


    add_line(block_path, inport_y_ref_p.Outport, fun_p.Inport(1), "autorouting", "smart");
    add_line(block_path, inport_y_p.Outport, inport_delay_p.Inport, "autorouting", "smart");
    add_line(block_path, inport_delay_p.Outport, fun_p.Inport(2), "autorouting", "smart");
    add_line(block_path, inport_dt_p.Outport, fun_p.Inport(3), "autorouting", "smart");
    add_line(block_path, fun_p.Outport(1), outport_u_p.Inport, "autorouting", "smart");
    add_line(block_path, fun_p.Outport(2), outport_log_p.Inport, "autorouting", "smart");


    offset = 40;

    input_mask_valus = struct;
    for j=1:input_len
        input_param = io_args{j};
        io_handle = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', ...
            strcat(block_path, '/', input_param.Name)); 
        io_handle_p = get_param(io_handle, 'PortHandles');
        block_offset(io_handle, fun_pos, [-100 offset]);
        offset = offset + 20;
        add_line(block_path, io_handle_p.Outport, fun_p.Inport(3+j), "autorouting", "smart");
    end

    mo = Simulink.Mask.create(handle);
    mo.addParameter('Name', 'params', 'Prompt', 'Parameter struct:', ...
        'Value', params_name, 'Visible', 'on');
    mo.addParameter('Name', 'data', ...
        'Value', data_name, 'Visible', 'off');
    mo.addParameter('Name', 'LogEntryType', ...
        'Value', [block_name, '_LT'], 'Visible', 'off');
    mo.addParameter('Name', 'ParamsType', ...
        'Value', [block_name, '_PT'], 'Visible', 'off');
    mo.addParameter('Name', 'DataType', ...
        'Value', [block_name, '_DT'], 'Visible', 'off');

    for j=1:input_len
        n = strcat(io_args{j}.Name, '_T');
        v = strcat(info.info.Name, "_", io_args{j}.Name, "_T");
        mo.addParameter('Name', n, 'Value', v, 'Visible', 'off');
    end
    generate_log_functions(info);

    set_param(handle, 'MaskObject', mo);


end


function generate_log_functions(info)

    log_desc = get_m_controller_log_description(info.info.Name);
    autogen_path = get_app_code_autogen_path();

    f_name = strcat('gen_create_logs__', info.info.Name);
    
    f_path = fullfile(autogen_path, strcat(f_name, '.m'));
    if exist(f_path, 'file')
        delete(f_path);
    end

    src = "function log = " + f_name + "(data)" + newline;

    if ~isempty(log_desc) 
        for i=1:length(log_desc)
            d = log_desc{i};
            src = src + "    " + strcat('log.', d.Name, ' = data.', d.Name, ';') + newline;
        end
    else
        src = src + "    " + strcat('log = struct;') + newline;
    end

    src = src + 'end';
    fid = fopen(f_path, 'wt');
    fprintf(fid, src);
    fclose(fid);
    
end

