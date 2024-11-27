function [vars, types] = list_vars_from_workspace(type)
    vars = evalin('base', 'who');
    if strempty(type)
        types = strings(length(vars), 1);
        for i=1:length(vars)
            types(i) = string(class(evalin('base', vars{i})));
        end
    else
        iter_vars = vars;
        vars = {};
        types = strings(0, 1);
        for i=1:length(iter_vars)
            typ = string(class(evalin('base', vars{i})));
            if strcmp(typ, type)
                vars{end+1} = string(class(evalin('base', vars{i})));
            end
            types(end+1) = typ;
        end
    end
end

