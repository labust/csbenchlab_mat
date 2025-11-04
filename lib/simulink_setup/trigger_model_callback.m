function trigger_model_callback(model_name, info, cb_name)
    
    try
        mws = get_param(model_name, 'modelworkspace');
        callbacks = mws.getVariable('callbacks');
    catch
        return
    end
    trigger_cb(info.Metadata.Id, cb_name, callbacks);
    c = environment_components_it(info);
    for i=1:length(c)
        trigger_cb(c{i}.Id, cb_name, callbacks);
    end
end


function trigger_cb(comp_id, cb_name, callbacks)
    
    k = strcat(cb_name, ":", comp_id);
    if ~callbacks.isKey(k)
        return
    end
    v = callbacks(k);
    if iscell(v)
        v = v{1};
    end
    if isfield(v, 'external_function__')
        try
            eval(v.function);
        catch e
            warning("Error evaluating callbacks");
            rethrow(e);
        end
    elseif isa(v, 'py.function')
        v();
    end

end