function sl_customization(cm)
  cm.addCustomFilterFcn('csb_custom_component:stopSimulationAction',@stop_filter);
  cm.addCustomFilterFcn('csb_custom_component:runSimulationAction',@start_filter);
end

function state = start_filter(callbackInfo)
  env_name = extract_env_name(gcs);
  state = 'Enabled';
  if ~is_env(env_name)
        return
  end
  hws = get_param(env_name, 'modelworkspace');  
  trigger = 0;
  if hws.hasVariable('runsim_trigger')
      trigger = 1;
  end
  if trigger
      state = 'Disabled';
  end
end

function state = stop_filter(callbackInfo)
    env_name = extract_env_name(gcs);
    state = 'Disabled';

    if ~is_env(env_name)
        return
    end
    hws = get_param(env_name, 'modelworkspace');  
    trigger = 0;
    if hws.hasVariable('runsim_trigger')
        trigger = 1;
    end
    if trigger
        state = 'Enabled';
    end
end

function rm_trigger(varargin)
    a = 5;
end

function env_name = extract_env_name(env_name)
    splits = split(env_name, '/');
    env_name = splits{1};
end