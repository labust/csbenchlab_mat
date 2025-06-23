function path = get_app_root_path()

    try
        files = matlab.apputil.getInstalledAppInfo;
    
        location = files(arrayfun(@(x) strcmp(x.name, 'csbenchlab'), files));
        path = fullfile(location(1).location);
    
    catch
        % remove before instalation
        % path = fullfile('.');
        path = fullfile('/home/luka/matlab/csbenchlab');
    end
end
