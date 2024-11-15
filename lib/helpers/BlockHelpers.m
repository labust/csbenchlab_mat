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

        function systems = get_system_io_port_dims(systems, sys_info)
            % get port dimensions of systems if they are present in the
            % simulink in/out ports        
            inport_h = getfullname(Simulink.findBlocksOfType(systems.systems(1).Path, 'Inport'));
            outport_h = getfullname(Simulink.findBlocksOfType(systems.systems(1).Path, 'Outport'));
            
            if ~iscell(outport_h) % if only 1 output, h is not a cell
                outport_h = {outport_h};
            end


            matches = strcmp(inport_h, strcat(systems.systems(1).Path, '/u'));
            in_h = inport_h{matches};
            matches = strcmp(outport_h, strcat(systems.systems(1).Path, '/y'));
            out_h = outport_h{matches};
        
            i_p = get_param(in_h, "PortDimensions");
            o_p = get_param(out_h, "PortDimensions");

            i_p = str2num(i_p);
            o_p = str2num(o_p);

            if i_p < 0 || o_p < 0

                if sys_info.Dims.input < 0 || sys_info.Dims.output < 0
                    error(['Cannot infer system input/output dimensions. ' ...
                        'If system is a Simulink block, try setting dimensions to ' ...
                        'input/output ports. If System is a Matlab Class, try specifying ' ...
                        'a dims struct as a system parameter']);
                end
                i_p = sys_info.Dims.input;
                o_p = sys_info.Dims.output;
            end
            systems.dims.input = i_p;
            systems.dims.output = o_p;
        end

        function add_from_tag_to_inport(model_name, handle, tag, idx)
            pa = @BlockHelpers.path_append;
            offset = @BlockHelpers.move_block;
            pos = get_param(handle, 'Position');
            ps = get_param(handle, 'PortHandles');
            from_h = add_block('simulink/Signal Routing/From', pa(model_name, 'From'), 'MakeNameUnique','on');
            
            off = (idx - (length(ps.Inport)+1) / 2) * 15;
            offset(from_h, pos, [-80, off], 0.7, 0.5)
            set_param(from_h, 'GotoTag', tag);
            from_ports = get_param(from_h, 'PortHandles');
            ports = get_param(handle, 'PortHandles');
            add_line(model_name, from_ports.Outport, ports.Inport(idx));
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

        function [h, name] = add_block_at(source, dest, varargin)
            % add unique block and set position, if given
            h = add_block(source, dest, 'MakeNameUnique','on');
            if nargin > 2
                set_param(h, 'Position', varargin{1});
            end
            name = get_param(h, 'Name');

        end

        function n = get_name_or_empty(str, default)
            n = default;
            if is_valid_field(str, 'Name')
                n = convertStringsToChars(str.Name);
            end
        end

    end
end

