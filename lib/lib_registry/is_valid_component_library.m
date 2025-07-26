function t = is_valid_component_library(path)
    t = isfile(fullfile(path, 'package.json')) && ...
        isfile(fullfile(path, 'plugins.json'));
end