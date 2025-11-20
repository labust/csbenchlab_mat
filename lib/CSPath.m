classdef CSPath


    methods (Static)

        function path = get_app_root_path()
            try
                files = matlab.apputil.getInstalledAppInfo;

                location = files(arrayfun(@(x) strcmp(x.name, 'csbenchlab'), files));
                path = fullfile(location(1).location);
            catch
                path = fileparts(which('csbenchlab'));
            end
        end

        function path = get_app_python_src_path()
            path = fileparts(CSPath.get_app_root_path());
        end

        function path = get_app_registry_path()
            path = fullfile(CSPath.get_appdata_path(), 'registry');
        end

        function path = get_app_template_path()
            path = ...
                fullfile(CSPath.get_app_root_path(), 'lib', 'helpers', 'templates');
        end

        function path = get_appdata_path()
            home = getenv('HOME');
            if isempty(home)
                home = getenv('USERPROFILE'); % Windows
            end
            path = fullfile(home, '.csbenchlab');
            if ~isfolder(path)
                mkdir(path);
            end
        end



    end
end

