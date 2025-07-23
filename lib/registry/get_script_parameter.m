function p = get_script_parameter(script, param_name)
    lines = splitlines(script);
    p = '';
    for i=1:length(lines)
        l =  strtrim(lines{i});
        
        if ~startsWith(l, '%')
            return
        end
        
        if endsWith(l, ';')
            l = l(1:end-1);
        end

        splits = split(l(2:end), ':=');
        if length(splits) ~= 2
            error(strcat('Cannot parse parameter from line "', l, '"'));
        end
        if strcmp(strtrim(splits{1}), param_name)
            p = strtrim(splits{2});
            if startsWith(p, '"') && endsWith(p, '"')
                p = p(2:end-1);
            else
                error(strcat("Error while parsing scrip parameter '", param_name, "'."));
            end
            return
        end
    end
end

