classdef GeneratorHelpers
    %GENERATORHELPERS Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        lib_name = 'sim_lib';
        common_lib_name = 'csbenchlab_common';
        controllers_path = [GeneratorHelpers.lib_name, '/Controllers'];
        systems_path = [GeneratorHelpers.lib_name, '/Systems'];
        master_offset_value = 100;
    end

   
    methods (Static)


        
        
        function controllers = generate_controllers(model_name, info, system_dims)

            pa = @BlockHelpers.path_append;
            gn = @BlockHelpers.get_name_or_empty;
            off = @BlockHelpers.offset_position;
            move = @BlockHelpers.move_block;
            
            % position of controller subsystem in 'n1;
            subs_position = [330, 125, 430, 180]; 
            % position of controller component in 'n1/Subsystem'
            comp_position = [330, 130, 430, 180];
            
            controllers = [];
            for i=1:length(info)
                io_handles = struct;

                % controller subsystem
                c_subsystem = pa(model_name, gn(info(i), 'Subsystem'));
                
                [cs_h, cs_name] = BlockHelpers.add_block_at( ...
                    'simulink/Ports & Subsystems/Subsystem', c_subsystem, subs_position);

                cs_path = pa(model_name, cs_name);
                controllers(i).Name = cs_name;
                controllers(i).Handle = cs_h;
                controllers(i).Path = cs_path;
                
                % get and reconfigure subsystem io ports
                % subsystem is initially constructed with 1 input, 1 output
                % and a line between them
                inport_yref_h = getSimulinkBlockHandle(...
                    find_system(cs_path, 'SearchDepth', 1, 'BlockType', 'Inport'));
                outport_u_h = getSimulinkBlockHandle(...
                    find_system(cs_path, 'SearchDepth', 1, 'BlockType', 'Outport'));
                set_param(inport_yref_h, 'Name', 'y_ref');
                set_param(outport_u_h, 'Name', 'u');

                inport_yref_p = get_param(inport_yref_h, 'PortHandles');
                outport_u_p = get_param(outport_u_h, 'PortHandles');
                move(inport_yref_h, comp_position, [-500, 0]);
                move(outport_u_h, comp_position, [400, 0]);
                delete_line(cs_path, inport_yref_p.Outport, outport_u_p.Inport);
    
                [inport_y_h, ~] = BlockHelpers.add_block_at( ...
                    'simulink/Quick Insert/Ports & Subsystems/Inport', pa(cs_path, 'y'));
                set_param(inport_y_h, 'Name', 'y');

                [outport_log_h, ~] = BlockHelpers.add_block_at( ...
                    'simulink/Quick Insert/Ports & Subsystems/Outport', pa(cs_path, 'log'));
                
                move(inport_y_h, comp_position, [-500, 30]);
                move(outport_log_h, comp_position, [400, 40]);
                inport_y_p = get_param(inport_y_h, 'PortHandles');
                outport_log_p = get_param(outport_log_h, 'PortHandles');

                set_param(inport_yref_h, 'PortDimensions', num2str(system_dims.Outputs));
                set_param(outport_u_h, 'PortDimensions', num2str(system_dims.Inputs));
                set_param(inport_y_h, 'PortDimensions', num2str(system_dims.Outputs));

                io_handles.inport_y.h = inport_y_h;
                io_handles.inport_y.p = inport_y_p;
                io_handles.inport_yref.h = inport_yref_h;
                io_handles.inport_yref.p = inport_yref_p;
                io_handles.outport_u.h = outport_u_h;
                io_handles.outport_u.p = outport_u_p;
                io_handles.outport_log.h = outport_log_h;
                io_handles.outport_log.p = outport_log_p;

                % if controller is composable, that means that it has
                % various controller types for different system DOF-s
                c_info = info(i);
                if c_info.IsComposable
                    components = c_info.Components;
                else
                    components = c_info;
                end


                io_handles = GeneratorHelpers.generate_controller_io_muxes( ...
                    cs_path, comp_position, system_dims, length(components), io_handles);
             
                for j=1:length(components)
                     
                    comp = components(j);
                    
                    path = get_component_simulink_path(comp, 'ctl');
                    sp = split(path, '/');
                    c_block = pa(model_name, cs_name, gn(comp, sp{end}));
                    [c_h, name] = BlockHelpers.add_block_at(path, c_block, comp_position);
                    gen_c(j).Name = name;
                    gen_c(j).Handle = c_h;
                    gen_c(j).Path = pa(cs_path, name);
                    
                    % if block is not m_controller, set its params
                    if has_mask_parameter(c_h, 'params_struct_name')
                        set_mask_values(c_h, 'params_struct_name', comp.ParamsStructName);
                    end
                    if has_mask_parameter(c_h, 'params')
                        set_mask_values(c_h, 'params', comp.ParamsStructName);
                    end

                    extractor = GeneratorHelpers.generate_reference_extractor(cs_path, comp_position, ...
                        length(components));

                    io_handles.ref_extractors(j) = extractor;
                    gen_c(j).RefExtractor.Path = pa(cs_path, extractor.name);
                    

                    BlockHelpers.add_from_tag_to_inport(cs_path, c_h, 'dt', 3);


                    io_handles = GeneratorHelpers.generate_controller_adapter_muxes( ...
                        pa(model_name, cs_name), comp_position, j, io_handles);
                    
                    c_p = get_param(c_h, "PortHandles");

                    io_handles.adapters(j).scopes = ...
                        GeneratorHelpers.generate_scopes_for_controller( ...
                            pa(model_name, cs_name), comp_position, j);

                    io_handles.adapters(j).cont.h = c_h;
                    io_handles.adapters(j).cont.p = c_p;

                    in_mux = io_handles.adapters(j).in_mux.h;
                    in_mux_ref = io_handles.adapters(j).in_mux_ref.h;
                    out_demux = io_handles.adapters(j).out_demux.h;
                    if ~isempty(comp.Mux.Inputs)             
                        set_param(in_mux, 'Inputs', num2str(length(comp.Mux.Inputs)));
                        set_param(in_mux_ref, 'Inputs', num2str(length(comp.Mux.Inputs)));
                        io_handles.adapters(j).Mux.Inputs = comp.Mux.Inputs;
                    else
                        set_param(in_mux, 'Inputs', num2str(system_dims.Outputs));
                        set_param(in_mux_ref, 'Inputs', num2str(system_dims.Outputs));
                        io_handles.adapters(j).Mux.Inputs = 1:system_dims.Outputs;
                    end
                    
                    if ~isempty(comp.Mux.Outputs)    
                        set_param(out_demux, 'Outputs', num2str(length(comp.Mux.Outputs)));
                        io_handles.adapters(j).Mux.Outputs = comp.Mux.Outputs;
                    else
                        set_param(out_demux, 'Outputs', num2str(system_dims.Inputs));
                        io_handles.adapters(j).Mux.Outputs = 1:system_dims.Inputs;
                    end

                    % refresh port handles after dimension setting
                    io_handles.adapters(j).in_mux.p = ...
                        get_param(io_handles.adapters(j).in_mux.h, 'PortHandles');
                    io_handles.adapters(j).in_mux_ref.p = ...
                        get_param(io_handles.adapters(j).in_mux_ref.h, 'PortHandles');
                    io_handles.adapters(j).out_demux.p = ...
                        get_param(io_handles.adapters(j).out_demux.h, 'PortHandles');

                    comp_position = off(comp_position, [0, 200]);
                end
                controllers(i).Components = gen_c;
                controllers(i).IoHandles = io_handles;
                controllers(i).Estimator = [];
                controllers(i).Disturbance = [];

                
                if is_valid_field(info(i), 'Estimator')
                    controllers(i).Estimator = ...
                        GeneratorHelpers.generate_estimator(model_name, info(i).Estimator, subs_position);
                end
                if is_valid_field(info(i), 'Disturbance')
                    controllers(i).Disturbance = ...
                        GeneratorHelpers.generate_disturbance(model_name, info(i).Disturbance, subs_position, 1);
                end

                clear('gen_c');

                subs_position = off(subs_position, [0, GeneratorHelpers.master_offset_value]);
            end
        end

        function gen_s = generate_disturbance(model_name, info, position, is_ctl)
            pa = @BlockHelpers.path_append;
            move = @BlockHelpers.move_block;

            path = get_component_simulink_path(info, 'dist');
            gen_s = struct;
            sp = split(path, '/');
            s_block = pa(model_name, BlockHelpers.get_name_or_empty(info, sp{end}));

            if is_ctl > 0
                off = [180, 0];
            else
                off = [140, -90];
            end
            
            [s_h, name] = BlockHelpers.add_block_at(path, s_block);
            move(s_h, position, off);
            blockObj = get_param(s_h, 'Object');
            blockObj.Orientation = 'right';
            BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'dt', 2);
            gen_s.Handle = s_h;
            gen_s.Name = name;
            % BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'ic', 3);
        end


        function gen_s = generate_estimator(model_name, info, position)
            pa = @BlockHelpers.path_append;
            move = @BlockHelpers.move_block;

            path = get_component_simulink_path(info, 'est');
            gen_s = struct;
            sp = split(path, '/');
            s_block = pa(model_name, BlockHelpers.get_name_or_empty(info, sp{end}));
            
            [s_h, name] = BlockHelpers.add_block_at(path, s_block);
            move(s_h, position, [180, 55]);
            blockObj = get_param(s_h, 'Object');
            blockObj.Orientation = 'left';
            BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'dt', 2, 'left');
            BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'ic', 3, 'left');
            gen_s.Handle = s_h;
            gen_s.Name = name;
        end


        function handle = generate_scopes_for_controller(cs_path, comp_position, j)
             pa = @BlockHelpers.path_append;
             move = @BlockHelpers.move_block;
             [handle.y.h, ~] = BlockHelpers.add_block_at( ...
                    'simulink/Commonly Used Blocks/Scope', ...
                    pa(cs_path, ['y_scope_', num2str(j)]));
             [handle.u.h, ~] = BlockHelpers.add_block_at( ...
                    'simulink/Commonly Used Blocks/Scope', ...
                    pa(cs_path, ['u_scope_', num2str(j)]));

             move(handle.y.h, comp_position, [-190, -100])
             move(handle.u.h, comp_position, [170, -100])
             set_param(handle.y.h, 'NumInputPorts', '2');
             set_param(handle.u.h, 'NumInputPorts', '1');
             handle.y.p = get_param(handle.y.h, 'PortHandles');
             handle.u.p = get_param(handle.u.h, 'PortHandles');
        end

        function systems = generate_systems(model_name, info, replicate_num)
            
            % This helper creates a system for each of the controllers to
            % be used in this environment. The same system is configured as
            % in 'info' and replicated 'replicate_num' times
            %
            % if ClassName is set in system_info, search for autogenerated 
            % model in systems_path library
            % if Path is set in system_info, add block from the Path as
            % system


            pa = @BlockHelpers.path_append;
            gn = @BlockHelpers.get_name_or_empty;

            position = [730, 130, 830, 180];

            
            path = get_component_simulink_path(info, 'sys');
            for i=1:replicate_num
                gen_s = struct;
                sp = split(path, '/');
                s_block = pa(model_name, gn(info, sp{end}));
                [s_h, name] = BlockHelpers.add_block_at(path, s_block, position);
                
                if has_mask_parameter(s_h, 'params_struct_name')
                    set_mask_values(s_h, 'params_struct_name', info.ParamsStructName);
                end
                if has_mask_parameter(s_h, 'params')
                    set_mask_values(s_h, 'params', info.ParamsStructName);
                end
                if has_mask_parameter(s_h, 'params_merged')
                    set_mask_values(s_h, 'params', 'ActiveScenario.Params');
                end

                gen_s.Name = name;
                gen_s.Handle = s_h;
                gen_s.Path = pa(model_name, gen_s.Name);
                gen_s.Disturbance = [];

                position = BlockHelpers.offset_position(position, ...
                    [0, GeneratorHelpers.master_offset_value]);
                BlockHelpers.add_from_tag_to_inport(model_name, s_h, 't', 2);
                BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'dt', 3);
                BlockHelpers.add_from_tag_to_inport(model_name, s_h, 'ic', 4);
                systems.systems(i) = gen_s;

                if is_valid_field(info, 'Disturbance')
                    systems.systems(i).Disturbance = ...
                        GeneratorHelpers.generate_disturbance(model_name, info.Disturbance, position, 0);
                end
             
            end
            systems = BlockHelpers.get_system_io_port_dims(systems, info);
        end

        function th = add_time_handler(model_name)
            % Add time handler block to the simulink model
            pa = @BlockHelpers.path_append;    
            position = [430, 0, 630, 50];
            c_block = pa(model_name, 'TH');
            [th_h, name] = BlockHelpers.add_block_at( ...
                pa(GeneratorHelpers.common_lib_name, 'TimeHandler'), c_block, position);
            th.Handle = th_h;
            th.Name = name;
            th.Path = pa(model_name, th.Name);
        end

        function ich = add_ic_handler(model_name, system_info)
            % Add time handler block to the simulink model
            pa = @BlockHelpers.path_append; 
            c_block = pa(model_name, 'IC');

            position = [590, 70, 610, 90];
            [ic_h, name] = BlockHelpers.add_block_at( ...
                'simulink/Signal Routing/Goto', c_block, position);

            position = [440, 70, 460, 90];
            [icc_h, namec] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Constant', c_block, position);

            set_param(ic_h, 'GotoTag', 'ic');
            set_param(icc_h, 'Value', system_info.Ic);
            to_ports = get_param(ic_h, 'PortHandles');
            const_ports = get_param(icc_h, 'PortHandles');
            add_line(model_name, const_ports.Outport, to_ports.Inport);           
            ich.Constant.Handle = icc_h;
            ich.Constant.Name = namec;
            ich.Constant.Path = pa(model_name, namec);
            ich.To.Handle = ic_h;
            ich.To.Name = name;
            ich.To.Path = pa(model_name, name);
        end

        function refgen = add_reference_generator(model_name)
            % Add and configure reference generator to the simulink model

            pa = @BlockHelpers.path_append;    
            position = [30, 60, 130, 120];
            c_block = pa(model_name, 'RefGenerator');
            [refgen_h, name] = BlockHelpers.add_block_at(pa(GeneratorHelpers.common_lib_name, 'ReferenceGenerator'), c_block, position);
            
            refgen.Handle = refgen_h;
            refgen.Name = name;
            refgen.Path = pa(model_name, refgen.Name);

            set_param(refgen_h, 'LinkStatus', 'none');
        end

        function extractor = generate_reference_extractor(cs_path, comp_position, j)
             pa = @BlockHelpers.path_append;
             move = @BlockHelpers.move_block;
             [extractor.h, extractor.name] = BlockHelpers.add_block_at( ...
                    pa(GeneratorHelpers.common_lib_name, 'ReferenceExtractor'), ...
                    pa(cs_path, ['ref_extractor_', num2str(j)]));
             
             move(extractor.h, comp_position, [-150, -40])
             extractor.p = get_param(extractor.h, 'PortHandles');
        end

        function bus_connect(model_name, blocks)
            refgen = blocks.refgen;
            controllers = blocks.controllers;
            systems = blocks.systems;
            
            if length(controllers) ~= length(systems.systems)
                error('Controllers and Systems should have the same number of elements');
            end

            refgen_ports = get_param(refgen.Handle, 'PortHandles');
            set_param(refgen_ports.Outport, 'datalogging', 'on'); % log reference output
            set_param(refgen_ports.Outport, 'Name', 'Reference'); 

            for i = 1:length(controllers)
                c = controllers(i);
                s = systems.systems(i);

                c_ports = get_param(c.Handle, 'PortHandles');
                s_ports = get_param(s.Handle, 'PortHandles');
                
                % set data logging
                set_param(s_ports.Outport, 'datalogging', 'on'); % log system output
                set_param(s_ports.Outport, 'Name', strcat(c.Name, '_y')); 

                set_param(c_ports.Outport(1), 'datalogging', 'on'); % log controller output
                set_param(c_ports.Outport(1), 'Name', strcat(c.Name, '_u')); 

                set_param(c_ports.Outport(2), 'datalogging', 'on'); % log controller logs
                set_param(c_ports.Outport(2), 'Name', strcat(c.Name, '_log'));

                % connect signals on the top level
                
                % first, check if disturbance on controller and connect

                if is_valid_field(c, 'Disturbance')
                    d_h = c.Disturbance.Handle;
                    d_ports = get_param(d_h, 'PortHandles');
                    add_line(model_name, c_ports.Outport(1), d_ports.Inport(1), "autorouting", 'smart');
                    add_line(model_name, d_ports.Outport(1), s_ports.Inport(1), "autorouting", 'smart');
                    set_param(d_ports.Outport(1), 'datalogging', 'on'); % log noise control input
                    set_param(d_ports.Outport(1), 'Name', strcat(c.Name, '_u_n'));
                else
                    add_line(model_name, c_ports.Outport(1), s_ports.Inport(1), "autorouting", 'smart');
                end

                
                % then, if disturbance is on system
                if is_valid_field(s, 'Disturbance')
                    d_h = s.Disturbance.Handle;
                    d_ports = get_param(d_h, 'PortHandles');
                    add_line(model_name, s_ports.Outport(1), d_ports.Inport(1), "autorouting", 'smart');
                    set_param(d_ports.Outport(1), 'datalogging', 'on'); % log noise control input
                    set_param(d_ports.Outport(1), 'Name', strcat(c.Name, '_y_n'));
                    dist_out_ports = d_ports.Outport;
                else
                    dist_out_ports = s_ports.Outport;
                end

                % if controller has estimator, connect to it
                if is_valid_field(c, 'Estimator')
                    e_h = c.Estimator.Handle;
                    e_ports = get_param(e_h, 'PortHandles');
                    add_line(model_name, dist_out_ports(1), e_ports.Inport(1), "autorouting", 'smart');
                    set_param(e_ports.Outport(1), 'datalogging', 'on'); % log estimated value
                    set_param(e_ports.Outport(1), 'Name', strcat(c.Name, '_y_hat'));
                    est_out_ports = e_ports.Outport;                
                else
                    est_out_ports = dist_out_ports;
                end
                
                % finally, connect estimator out to controller 
                add_line(model_name, est_out_ports, c_ports.Inport(2), "autorouting", 'smart');

                
                % connect refgen to controller
                add_line(model_name, refgen_ports.Outport, c_ports.Inport(1), "autorouting", 'smart');

                 
                
                % connect signals in the controller
                io_h = c.IoHandles;
                add_line(c.Path, io_h.inport_y.p.Outport, io_h.in_demux.p.Inport, "autorouting", 'smart');
                add_line(c.Path, io_h.inport_yref.p.Outport, io_h.in_demux_ref.p.Inport, "autorouting", 'smart');
                add_line(c.Path, io_h.out_mux.p.Outport, io_h.outport_u.p.Inport, "autorouting", 'smart');
                add_line(c.Path, io_h.out_mux_log.p.Outport, io_h.outport_log.p.Inport, "autorouting", 'smart');

                for j=1:length(io_h.adapters)
                    h = io_h.adapters(j);
                    cont_p = h.cont.p;
                    ex = io_h.ref_extractors(j).p;

                    add_line(c.Path, h.in_mux_ref.p.Outport, ex.Inport(1), "autorouting", 'smart');
                    add_line(c.Path, ex.Outport(1), cont_p.Inport(1), "autorouting", 'smart');
                    add_line(c.Path, h.in_mux.p.Outport, cont_p.Inport(2), "autorouting", 'smart');
                    add_line(c.Path, cont_p.Outport(1), h.out_demux.p.Inport, "autorouting", 'smart');

                    add_line(c.Path, cont_p.Outport(2), io_h.out_mux_log.p.Inport(j), "autorouting", 'smart');

                    % connect scopes
                    add_line(c.Path, h.in_mux_ref.p.Outport, h.scopes.y.p.Inport(1), "autorouting", 'smart');
                    add_line(c.Path, h.in_mux.p.Outport, h.scopes.y.p.Inport(2), "autorouting", 'smart');
                    add_line(c.Path, cont_p.Outport(1), h.scopes.u.p.Inport, "autorouting", 'smart');

                    if is_valid_field(h, 'Mux')
                        for k=1:length(h.Mux.Inputs)
                            add_line(c.Path, io_h.in_demux.p.Outport(h.Mux.Inputs(k)), ...
                                h.in_mux.p.Inport(k), "autorouting", 'smart');
                            add_line(c.Path, io_h.in_demux_ref.p.Outport(h.Mux.Inputs(k)), ...
                                h.in_mux_ref.p.Inport(k), "autorouting", 'smart');
                        end
                        for k=1:length(h.Mux.Outputs)
                            add_line(c.Path, h.out_demux.p.Outport(k), ...
                                io_h.out_mux.p.Inport(h.Mux.Outputs(k)), "autorouting", 'smart');          
                        end
                    else
                        % not important any more (maybe)
                        % for k=1:systems.dims.output
                        %     add_line(c.Path, io_h.in_demux.p.Outport(k), h.in_mux.p.Inport(k), "autorouting", 'smart');
                        %     add_line(c.Path, io_h.in_demux_ref.p.Outport(k), h.in_mux_ref.p.Inport(k), "autorouting", 'smart');
                        % end
                        % for k=1:systems.dims.Inputs
                        %     add_line(c.Path, h.out_demux.p.Outport(k), io_h.out_mux.p.Inport(k), "autorouting", 'smart');
                        % end
                    end
                end
            end
        end


        function handles = generate_controller_io_muxes(cs_path, comp_position, system_dims, num_components, handles)
            pa = @BlockHelpers.path_append;
            move = @BlockHelpers.move_block;
            % muxes
            [in_demux_ref, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Demux',  pa(cs_path, 'DemuxYrefIn'));
            [in_demux, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Demux',  pa(cs_path, 'DemuxYIn'));
            set_param(in_demux_ref, 'Outputs', num2str(system_dims.Outputs));
            set_param(in_demux, 'Outputs', num2str(system_dims.Outputs));
            
            move(in_demux, comp_position, [-400, 60]);
            move(in_demux_ref, comp_position, [-400, -60]);
            in_demux_p = get_param(in_demux, 'PortHandles');
            in_demux_ref_p = get_param(in_demux_ref, 'PortHandles');

            [out_mux, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Mux',  pa(cs_path, 'MuxOut'));
            move(out_mux, comp_position, [300, 0]);

            [out_mux_log, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Bus Creator',  pa(cs_path, 'MuxOut'));
            move(out_mux_log, comp_position, [300, 100]);

            set_param(out_mux, 'Inputs', num2str(system_dims.Inputs));
            set_param(out_mux_log, 'Inputs', num2str(num_components));

            out_mux_p = get_param(out_mux, 'PortHandles'); 
            out_mux_log_p = get_param(out_mux_log, 'PortHandles'); 


            handles.in_demux.p = in_demux_p;
            handles.in_demux.h = in_demux;
            handles.in_demux_ref.p = in_demux_ref_p;
            handles.in_demux_ref.h = in_demux_ref;
            handles.out_mux.p = out_mux_p;
            handles.out_mux.h = out_mux;            
            handles.out_mux_log.p = out_mux_log_p;
            handles.out_mux_log.h = out_mux_log;
        end

        function handles = generate_controller_adapter_muxes(cs_path, comp_position, j, handles)
            pa = @BlockHelpers.path_append;
            move = @BlockHelpers.move_block;

            [in_mux, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Mux', pa(cs_path, ['MuxIn', num2str(j)]));
            in_mux_p = get_param(in_mux, "PortHandles");
            move(in_mux, comp_position, [-300, 40]);
            [in_mux_ref, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Mux', pa(cs_path, ['MuxInRef', num2str(j)]));
            in_mux_ref_p = get_param(in_mux_ref, "PortHandles");
            move(in_mux_ref, comp_position, [-300, -40]);
            [out_demux, ~] = BlockHelpers.add_block_at( ...
                'simulink/Commonly Used Blocks/Demux', pa(cs_path, ['DemuxOut', num2str(j)]));
            out_demux_p = get_param(out_demux, "PortHandles");
            move(out_demux, comp_position, [200, -20]);

            handles.adapters(j).in_mux.h = in_mux;
            handles.adapters(j).in_mux.p = in_mux_p;
            handles.adapters(j).in_mux_ref.h = in_mux_ref;
            handles.adapters(j).in_mux_ref.p = in_mux_ref_p;
            handles.adapters(j).out_demux.h = out_demux;
            handles.adapters(j).out_demux.p = out_demux_p;
        end



    end
end

