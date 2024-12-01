function path = get_app_root_path()
    % files = matlab.apputil.getInstalledAppInfo;
    % 
    % location = files(arrayfun(@(x) strcmp(x.name, 'csbenchlab'), files));
    % path = fullfile(location(1).location);

    % remove before instalation
    path = fullfile('.');

end
