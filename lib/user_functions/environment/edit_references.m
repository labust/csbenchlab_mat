function edit_references(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    if length(varargin) > 0
        mat_path = varargin{1};
    else
        path = fileparts(which(env_name));
        mat_path = pa(path, 'autogen', strcat(env_name, '_refs.mat'));
    end

    signalEditor('DataSource', mat_path);

end