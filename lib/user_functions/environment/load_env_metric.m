function m = load_env_metric(env_path, name, varargin)
    m = load_component_data(env_path, fullfile('parts', 'metrics', name, 'metric.json'), varargin{:});
    
end