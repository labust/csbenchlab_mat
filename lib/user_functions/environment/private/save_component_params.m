
function comp = save_component_params(comp, path)
    p = fullfile(path, 'params', strcat(comp.Id, '.mat'));
    Params = comp.Params;
    save(p, 'Params');
    comp.Params = comp.Id;
end


% OBSOLETE: Used for json storage, but is not used 
% because json encoding does not store matrix shape information
% function new_params = save_component_params(path, params)
% 
%     [new_params, ts_variables] = replace_timestruct_vars(params);
%     if ts_variables.numEntries > 0
%         params_path = fullfile(env_path, 'params');
%         save_timeseries_vars(params_path, ts_variables);
%     end
%     ks = keys(params);
%     for i=1:length(ks)
%         k = ks(i);
%         var = params{k};
%         save(fullfile(path, strcat(k, '.mat')), 'var');
%     end
% 
% 
% 
% end
% 
% function [ns, ts_variables] = replace_timestruct_vars(s)
% 
%     function [ns, ts] = replace_timestruct_vars_rec(s, ts)
%         names = fieldnames(s);
%         ns = s;
%         for i=1:length(names)
%             name = names{i};
%             if isa(s.(name), 'struct')
%                 ns.(name) = replace_timestruct_vars_rec(s.(name), ts);
%             elseif isa(s.(name), 'timeseries')
%                 k = strcat('__ts:', java.util.UUID.randomUUID.string);
%                 ns.(name) = k;
%                 ts{k} = s.(name);
%             end
%         end
% 
%     end
% 
% 
%     [ns, ts_variables] = replace_timestruct_vars_rec(s, dictionary);
% end