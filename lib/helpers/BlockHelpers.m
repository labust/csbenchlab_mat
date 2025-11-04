classdef BlockHelpers

    methods (Static)


        function move_block(handle, point, offset, varargin)

            if nargin > 4
                sx = varargin{1};
                sy = varargin{2};
            elseif nargin == 4
                sx = varargin{1};
                sy = sx;
            else
                sx = 1;
                sy = sx;
            end

            pos = get_param(handle, 'Position');
            w = pos(3) - pos(1);
            h = pos(4) - pos(2);
            c = [(point(3) + point(1))/2 + offset(1), (point(4) + point(2))/2 + offset(2)];
            r = [c(1)-sx*w/2, c(2)-sy*h/2, c(1) + sx*w/2, c(2) + sy*h/2];
            set_param(handle, 'Position', r);
        end

        function t = is_block_input_output(handle)
            typ = get_param(handle, 'BlockType');
            t = strcmp(typ, 'Inport') || strcmp(typ, 'Outport');
        end

        function delete_block_lines(handle)
            parent_path = getfullname(get_param(handle, 'Parent'));
            lines_h = find_system(parent_path, 'FindAll', 'on', ...
                'SearchDepth', 1, 'LookUnderMasks', 'all', 'type', 'line');
            delete_line(lines_h);
        end

        function systems = get_system_io_port_dims(systems, sys_info)
            % get port dimensions of systems if they are present in the
            % simulink in/out ports        
            try
                in_h = getSimulinkBlockHandle( ...
                    fullfile(systems.systems(1).Components(1).Path, 'u'));
                out_h = getSimulinkBlockHandle( ...
                    fullfile(systems.systems(1).Components(1).Path, 'y'));
            catch e
                disp(e.message);
                error("Cannot find system Inport. Make sure that the system's slx is on path...");
            end
           
        
            i_p = get_param(in_h, "PortDimensions");
            o_p = get_param(out_h, "PortDimensions");

            i_p = str2double(i_p);
            o_p = str2double(o_p);

            if i_p < 0 || o_p < 0
                if is_block_component(systems.systems(1).Path, 'sys', 'm')
                    info = libinfo(systems.systems(1).Path);
                    class_name = get_component_class_name(info.ReferenceBlock);
                    dims = eval(strcat(class_name, '.get_dims_from_params(sys_info.Params)'));
                end

                if is_block_component(systems.systems(1).Path, 'sys', 'py')
                    error('TODOO');
                end
                
                if ~exist('dims', 'var')
                    error("Cannot deduce system i/o sizes. If system is a " + ...
                        "simulink block, make sure that you specified i/o port sizes. " + ...
                        "If Matlab or Python were used, get_dims_from_params function should be implemented.");
                end

                i_p = dims.Inputs;
                o_p = dims.Outputs;
            end
            systems.dims.Inputs = i_p;
            systems.dims.Outputs = o_p;
        end

        function add_from_tag_to_inport(handle, tag, idx, orient)
            pa = @BlockHelpers.path_append;
            offset = @BlockHelpers.move_block;

            if ~exist("orient", 'var')
                orient = 'right';
            end

            handle_path = getfullname(handle);
            sp = split(handle_path, '/');
            from_destination = join(sp(1:end-1), '/');
            from_destination = from_destination{1};


            pos = get_param(handle, 'Position');
            from_h = add_block('simulink/Signal Routing/From', pa(from_destination, 'From'), 'MakeNameUnique','on');
            from_ports = get_param(from_h, 'PortHandles');
            ports = get_param(handle, 'PortHandles');
            ports_pos = get_param(ports.Inport, 'Position');

            if strcmp(orient, 'left')
                sign = 1;
            else
                sign = -1;
            end

            blockObj = get_param(from_h, 'Object');
            blockObj.orientation = orient;

            w = (pos(3) - pos(1)) / 2 + 20;
            h = ports_pos{idx};
            off = h(2);

            pos = [pos(1), 0, pos(3), 0]; % to set absolute value in height
            offset(from_h, pos, [sign*w, off], 0.5, 0.3)
            set_param(from_h, 'GotoTag', tag);
            add_line(from_destination, from_ports.Outport, ports.Inport(idx));
        end


        function p = offset_position(position, off)
            % position vector is [p1_x p1_y, p2_x, p2_y]
            % create a new position vector offset by 2d vector off 
            p = position;
            p(1) = position(1) + off(1);
            p(2) = position(2) + off(2);
            p(3) = position(3) + off(1);
            p(4) = position(4) + off(2);
        end

        function n = path_append(varargin)
            % create string that inserts '/' between arguments
            n = varargin{1};
            for i=2:nargin
                if ~strcmp(varargin{i}, '') && ~strcmp(varargin{i}, "")
                    n = strcat(n, '/', varargin{i});
                end
            end
        end

        function n = name_append(varargin)
            % create string that inserts '_' between arguments
            n = varargin{1};
            for i=2:nargin
                if ~strcmp(varargin{i}, '')
                    n = [n, '_', varargin{i}];
                end
            end
        end

        function varargout = add_block_at(source, dest, varargin)
            % add unique block and set position, if given
            h = add_block(source, dest, 'MakeNameUnique','on');
            if nargin > 2
                set_param(h, 'Position', varargin{1});
            end
            varargout{1} = h;
            if nargout == 1
                return
            end
            name = get_param(h, 'Name');
            varargout{2} = name;
        end

        function n = get_name_or_empty(str, default)
            n = default;
            if is_valid_field(str, 'Name')
                n = convertStringsToChars(str.Name);
            end
        end

    end
end

