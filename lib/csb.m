function varargout = csb(varargin)
    
    URI = "http://127.0.0.1:8000";
    commands = {"login"};
    objects = {"env", "lib", "comp", "ctl", "category"};
    if nargin == 0 
        error(strcat("Use one of the following commands: {'", strjoin([commands(:), objects(:)], "', '"), "'}"));
    end
    command = varargin{1};
    is_command = any(cellfun(@(x)strcmp(x, command), commands));
    if is_command
        if strcmp(command, 'login')
            login(URI, varargin{2:end})
        end
        return
    end

    is_object = any(cellfun(@(x)strcmp(x, command), objects));
    if ~is_object
        error(strcat("Object with name '", command, "' does not exist."));
    end

    object = command;
    command = varargin{2};
    if strcmp(command, 'login')
        login(URI, object, varargin{3:end})
    elseif strcmp(command, 'push')
        push(URI, object, varargin{3:end});
    elseif strcmp(command, 'pull')
        pull(URI, object, varargin{3:end});
    elseif strcmp(command, 'list')
        varargout{:} = list(URI, object, varargin{3:end});
    elseif strcmp(command, 'rm')
        rm(URI, object, varargin{3:end});
    elseif strcmp(command, 'create')
        create(URI, object, varargin{3:end});
    elseif strcmp(command, 'make')
        make(URI, object, varargin{3:end});
    elseif strcmp(command, 'info')
        varargout{:} = info(URI, object, varargin{3:end});
    end

end

function r = info(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    header = get_auth_header();
    if strcmp(object, 'env')
        params = {{"env", varargin{1}}};
        req_str = strcat(uri, "/env/get");        
    elseif strcmp(object, 'lib')
        params = {{"lib", varargin{1}}};
        req_str = strcat(uri, "/lib/get");   
    end
    q = get_querry_param_string(params);
    req = RequestMessage(RequestMethod.GET, header);
    resp = req.send(strcat(req_str, q));
    handle_resp_errors(resp);
    r = resp.Body.Data;
end

function make(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    
    if length(varargin) < 1
        error("Provide valid object name and destination");
    end

    header = get_auth_header();
    if strcmp(object, 'env')
        params = {{"env", varargin{2}}};
        uri = strcat(uri, strcat("/env/make_", varargin{1}));
    elseif strcmp(object, 'lib')
        params = {{"lib", varargin{2}}};
        uri = strcat(uri, strcat("/lib/make_", varargin{1}));
    end
    q = get_querry_param_string(params);
    req = RequestMessage(RequestMethod.GET, header);
    resp = req.send(strcat(uri, q));
    handle_resp_errors(resp);
    disp(strcat(varargin{2}, " made ", varargin{1}, " successfully"));
end

function create(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    
    if length(varargin) < 1
        error("Provide valid object name and destination");
    end
    
    if strcmp(object, 'category')
        header = get_auth_header();
        
        params = {{"category", varargin{1}}};
        q = get_querry_param_string(params);

        req = RequestMessage(RequestMethod.GET, header);
        resp = req.send(strcat(uri, "/env/create_category", q));
        handle_resp_errors(resp);
        disp("Category created successfully.");
    end
end

function data = pull(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    
    if length(varargin) < 1
        error("Provide valid object name and destination");
    end
    if strcmp(object, 'env')
        header = get_auth_header();
        params = {{"env", varargin{1}}};
        q = get_querry_param_string(params);

        req = RequestMessage(RequestMethod.GET, header);
        lib_name = resp.getFields('x-filename').Value;
        resp = req.send(strcat(uri, "/env/download", q));
        handle_resp_errors(resp);
        env_path = fullfile(get_env_download_path, lib_name);
        extract_zip(resp.Body.Data, env_path);
        disp("Environment downloaded successfully.");

        setup_environment(env_path)
        disp("Environment is set up and ready to use");

    elseif strcmp(object, 'lib')
        header = get_auth_header();
        params = {{"lib", varargin{1}}};
        q = get_querry_param_string(params);

        req = RequestMessage(RequestMethod.GET, header);
        resp = req.send(strcat(uri, "/lib/download", q));
        handle_resp_errors(resp);
        lib_name = resp.getFields('x-filename').Value;
        lib_path = fullfile(get_lib_download_path, lib_name);
        extract_zip(resp.Body.Data, lib_path);
        disp("Library downloaded successfully.");

        s = setup_library(lib_path);
        if s
            disp("Library is set up and ready to use");
        end
    end
end


function r = list(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*

    public = false;
    if has_arg(varargin, '--public')
        public = true;
    end
    q = '';
    if strcmp(object, 'env')
        if public
            header = [];
            req_str = strcat(uri, "/env/list_public");
        else
            header = get_auth_header();
            req_str = strcat(uri, "/env/list");
        end
        
    elseif strcmp(object, 'lib')
        if public
            header = [];
            req_str = strcat(uri, "/lib/list_public");
        else
            header = get_auth_header();
            req_str = strcat(uri, "/lib/list");
        end
    elseif strcmp(object, 'category')
        header = get_auth_header();
        
        req_str = strcat(uri, "/env/get_categories");
    end
    req = RequestMessage(RequestMethod.GET, header);
    resp = req.send(strcat(req_str, q));
    handle_resp_errors(resp);
    r = resp.Body.Data;
 
end


function login(uri, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*

    if length(varargin) ~= 2
        error("Provide valid username and password");
    end
    username = varargin{1};
    password = varargin{2};
    
    formData = FormProvider('username', username, 'password', password);
    req = RequestMessage(RequestMethod.POST, [], formData);
    resp = req.send(strcat(uri, '/login'));
    handle_resp_errors(resp);
    writelines(resp.Body.Data.access_token, fullfile(get_default_download_path, 'csb_tok'));
    disp("Login successful");
end


function push(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    
    if length(varargin) < 1
        error("Provide valid object name and destination");
    end
    override = false;
    if has_arg(varargin, '--override')
        override = true;
    end
    public = false;
    if has_arg(varargin, '--public')
        public = true;
    end
    
    if strcmp(object, 'env')
        path = get_env_path(varargin{1});
            
        
        [is_zipped, full_path] = zip_if_folder(path);
        fileProvider = FileProvider(full_path);
        formData = MultipartFormProvider( ...
            "env_file", fileProvider, ...
            "override_existing", lower(string(override)), ...
            "is_public", lower(string(public)) ...
        );
        header = get_auth_header();
        req = RequestMessage(RequestMethod.POST, header, formData);
        resp = req.send(strcat(uri, "/env/add"));
        if is_zipped
            delete(full_path);
        end
        handle_resp_errors(resp);
        disp(resp.Body.Data.msg);
        
    elseif strcmp(object, 'lib')
        path = varargin{1};
        if ~is_valid_component_library(path)
            path = get_library_path(path);
        end
        [is_zipped, full_path] = zip_if_folder(path);
       
        fileProvider = FileProvider(full_path);
        formData = MultipartFormProvider( ...
            "lib_file", fileProvider, ...
            "override_existing", lower(string(override)), ...
            "is_public", lower(string(public)) ...
        );
        header = get_auth_header();
        req = RequestMessage(RequestMethod.POST, header, formData);
        resp = req.send(strcat(uri, "/lib/add"));

        if is_zipped
            delete(full_path);
        end
        handle_resp_errors(resp);
        disp(resp.Body.Data.msg);
    end
end


function rm(uri, object, varargin)
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*
    
    if length(varargin) < 1
        error("Provide valid object name and destination");
    end
    
    if strcmp(object, 'env')
        path = get_env_path(varargin{1});

        data = load_env_metadata(path);
        
        header = get_auth_header();
        params = {{'env', data.Id}};
        q = get_querry_param_string(params);
        req = RequestMessage(RequestMethod.GET, header);
        resp = req.send(strcat(uri, "/env/remove", q));
        handle_resp_errors(resp);
        disp(resp.Body.Data.msg);
        
    elseif strcmp(object, 'lib')
        header = get_auth_header();
        params = {{'lib', varargin{1}}};
        q = get_querry_param_string(params);
        req = RequestMessage(RequestMethod.GET, header);
        resp = req.send(strcat(uri, "/lib/remove", q));
        handle_resp_errors(resp);
        disp(resp.Body.Data.msg);
    elseif strcmp(object, 'category')      
        header = get_auth_header();
        params = {{'category', varargin{1}}};
        q = get_querry_param_string(params);
        req = RequestMessage(RequestMethod.GET, header);
        resp = req.send(strcat(uri, "/env/remove_category", q));
        handle_resp_errors(resp);
        disp(resp.Body.Data.msg);
    end
end

function [is_zipped, path] = zip_if_folder(path)
    if isfile(path) && endsWith(path, '.zip')
        is_zipped = 0;
        return
    end

    [~, name, ~] = fileparts(path);
    full_path = strcat(tempdir, strcat(name, '.zip'));
    if exist(full_path, 'file')
        delete(full_path);
    end
    [folder_parent, name, ~] = fileparts(path);
    oldDir = cd(folder_parent);
    zip(full_path, name);
    is_zipped = 1;
    cd(oldDir);
    path = full_path;
end

function t = get_auth_header()
    import matlab.net.*
    import matlab.net.http.*
    t = readlines(fullfile(tempdir, 'csb_download', 'csb_tok'));
    t = t{1};
    t = HeaderField("Authorization", "Bearer " + t);
end


function t = has_arg(cell, arg_name)
    t = any(cellfun(@(x)strcmp(x, arg_name), cell));
end

function t = get_arg(cell, arg_name, default_value)
    
    if ~iscell(arg_name)
        arg_name = {arg_name};
    end
    r = 0;
    for i=1:length(cell)
        for j=1:length(arg_name)
            if strcmp(cell{i}, arg_name{j})
                r = 1;
                break
            end
        end
        if r == 1
            break
        end
    end

    if r == 0
        t = default_value;
        return
    end
    
    if i+1 > length(cell)
        error("Argument not provided");
    end
    t = cell{i+1};
end

function handle_resp_errors(resp)
    if strcmp(resp.StatusCode, 'OK')
        return
    elseif strcmp(resp.StatusCode, 'Unauthorized')
        error(strcat(resp.Body.Data.detail, ...
        ". You are not authorized for this command. Try to login first. "));
    else
        if isfield(resp.Body.Data, 'detail')
            error(resp.Body.Data.detail);
        else
            error("Unknown server error");
        end
    end 
end

function q = get_querry_param_string(params)
    q = "?";
    for i=1:length(params)
        p = params{i};
        q = strcat(q, p{1}, '=', p{2});
        if i ~= length(params)
            q = q + "&";
        end
    end

end



function t = get_env_download_path()
    t = fullfile(get_default_download_path(), 'envs');
    if ~exist(t, 'dir')
        mkdir(t);
    end
end

function t = get_lib_download_path()
    t = fullfile(get_default_download_path(), 'libs');
    if ~exist(t, 'dir')
        mkdir(t);
    end
end

function t = get_comp_download_path()
    t = fullfile(get_default_download_path(), 'comps');
    if ~exist(t, 'dir')
        mkdir(t);
    end
end

function t = get_default_download_path()
    t = fullfile(tempdir, 'csb_download');
    if ~exist(t, 'dir')
        mkdir(t);
    end
end

function extract_zip(zip_f, extract_dir)
    if ~exist(extract_dir, 'dir')
        mkdir(extract_dir)
    end
    f = fopen(fullfile(extract_dir, 'tmp_ext'), 'w+');
    fwrite(f, zip_f);
    fclose(f);
    unzip(fullfile(extract_dir, 'tmp_ext'), extract_dir);
    delete(fullfile(extract_dir, 'tmp_ext'));
end