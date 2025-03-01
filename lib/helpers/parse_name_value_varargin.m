function obj = parse_name_value_varargin(pairs, names, obj)

    for i = 1:2:length(pairs)
 
        name = pairs{i};
        value = pairs{i+1};
        
        set = 0;
        for j=1:length(names)
            if strcmp(names{j}, name)
                obj.(name) = value;
                set = 1;
                break
            end
        end
        
        if ~set
            warning(['Unexpected parameter name "', as_char, '"']);
        end
        
    end