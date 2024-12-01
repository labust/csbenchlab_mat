
function comp = load_component_params(comp, path)

    p = fullfile(path, 'params', strcat(comp.Id, '.mat'));
    if exist(p, 'file')
        params = load(p, 'Params');
        comp.Params = params.Params;
    end
end




% OBSOLETE
% function ns = load_component_params(s, env_path)
% 
%     function ns = load_timeseries_vars_rec(s)
%         names = fieldnames(s);
%         ns = s;
%         for i=1:length(names)
%             name = names{i};
%             ns.(name) = load_var(ns.(name), env_path);
%         end
% 
%     end
% 
%     ns = load_timeseries_vars_rec(s);
% end
% 
% function var = load_var(var_value, env_path)
%     var = var_value;
%     if ~isa(var_value, 'string')
%         return
%     end
%     splits = split(var_value, ':');
%     if length(splits) ~= 2 || ~strcmp(splits{1}, '__ts')
%         return
%     end
%     var = load(fullfile(env_path, 'params', strcat(var_value, '.mat')));
%     var = var.var;
% end