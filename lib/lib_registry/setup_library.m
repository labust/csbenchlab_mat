function s = setup_library(lib_path)

    info = get_library_info(lib_path, 0);
    s = 1;
    s = s && install_dependencies(info);
    s = s && install_pip_dependencies(lib_path);
    s = s && install_matlab_dependencies(lib_path);
    s = s && register_component_library(lib_path, 1);
end


function s = install_dependencies(info)
    s = 1;
end

function s = install_matlab_dependencies(lib_path)
    reqFile = fullfile(lib_path, 'm_requirements.txt');
    
    % Read all dependencies from the file
    fid = fopen(reqFile, 'r');
    if fid == -1
        error('Cannot open requirements file: %s', reqFile);
    end
    deps = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    deps = deps{1};
    
    % Get list of installed toolboxes/apps
    installed = ver;
    
    for i = 1:numel(deps)
        dep = strtrim(deps{i});
        if isempty(dep)
            continue; % skip empty lines
        end
        
        % Check if dependency is installed
        if check_matlab_dependency(dep, installed)
            fprintf('Dependency "%s" is already installed.\n', dep);
        else
            fprintf('Dependency "%s" is NOT installed. Installing...\n', dep);
            try
                % Placeholder for actual installation method
                % e.g. matlab.addons.install('path_to.mltbx_or_app')
                % or web-based install via APIs if available
                
                % Example message for now:
                fprintf('Installing %s (not implemented - please install manually).\n', dep);
                
                % After installation, optionally verify again
            catch ME
                fprintf('Failed to install %s: %s\n', dep, ME.message);
            end
        end
    end
end

function s = install_pip_dependencies(lib_path)
    requirements_path = fullfile(lib_path, 'requirements.txt');
    s = 1;
    if ~exist(requirements_path, 'file')
        return
    end
    disp("Installing pip dependencies...")
    try
        % Get the Python executable path MATLAB is using
        pyExe = char(py.sys.executable);
        
        % Construct the pip install command with requirements.txt in the current folder
        cmd = sprintf(strcat('"%s" -m pip install -r', requirements_path), pyExe);
        
        % Run the command in the system shell
        [status, cmdout] = system(cmd);
        
        % Display results
        if status == 0
            fprintf('Successfully installed pip requirements:\n%s\n', cmdout);
        else
            fprintf('Error installing requirements:\n%s\n', cmdout);
            s = 0;
        end
    catch
        s = 0;
    end
end



function s = check_matlab_dependency(dep_str, installed)
    % Example formats:
    % 'Robust Control Toolbox==24.1;>=R2024a'
    % 'Robust Control Toolbox>=24.1;>=R2024a'
    % 'Robust Control Toolbox<=24.1'
    
    % Define possible operators
    operators = {'==', '>=', '<=', '>', '<', '~='};
    
    % Find position of first operator in the string after toolbox name
    match_idx = [];
    match_op = '';
    for op = operators
        op_str = op{1};
        idx = strfind(dep_str, op_str);
        if ~isempty(idx)
            % Pick earliest occurrence
            first_idx = idx(1);
            if isempty(match_idx) || first_idx < match_idx
                match_idx = first_idx;
                match_op = op_str;
            end
        end
    end
    
    if isempty(match_idx)
        error('No valid version operator found in dependency string.');
    end
    
    % Extract toolbox name (before operator)
    toolbox_name = strtrim(dep_str(1:match_idx-1));
    % Extract rest (starting from operator)
    version_part = strtrim(dep_str(match_idx:end));
    
    % Split versionPart by ';' for MATLAB release constraints
    parts = strsplit(version_part, ';');
    
    % First part is version specifier like '==24.1'
    version_specifier = parts{1};
    % After operator removal, get version number
    version_number = strtrim(strrep(version_specifier, match_op, ''));
    
    % Optional MATLAB release constraint
    matlab_relese = '';
    if numel(parts) > 1
        matlab_relese = strtrim(parts{2});
    end

    % --- Actual installation checks would go here ---
    % Example: check if toolbox installed
    installed_names = {installed.Name};
    idx = find(strcmpi(installed_names, strtrim(toolbox_name)), 1);
    
    if isempty(idx)
        fprintf('Toolbox "%s" is NOT installed.\n', toolbox_name);
        return;
    end
    
    installed_version = installed(idx).Version;
    are_equal = strcmp(installed_version, version_number);
    is_less = verLessThan(strtrim(toolbox_name), version_number);
    % Simple version equality check (expand logic for other operators)
    switch match_op
        case '=='
            if ~are_equal
                fprintf('Version mismatch: required %s %s but installed %s\n', ...
                    match_op, version_number, installed_version);
            end
        case '<='
            if are_equal || is_less
                fprintf('Installed version %s is greater than required %s %s\n', ...
                    installed_version, match_op, version_number);
            end
        case '<'
        if is_less
            fprintf('Installed version %s is greater than required %s %s\n', ...
                installed_version, match_op, version_number);
        end
        case '>='
            if ~is_less || are_equal
                fprintf('Installed version %s is less than required %s %s\n', ...
                    installed_version, match_op, version_number);
            end
        case '>'
            if ~is_less
                fprintf('Installed version %s is less than required %s %s\n', ...
                    installed_version, match_op, version_number);
            end
        otherwise
            fprintf('Version check for operator %s not implemented.\n', matchOp);
    end
    
    % MATLAB release check
    if ~isempty(matlab_relese)
        % Expect format like '>=R2024a'
        if startsWith(matlab_relese, '>=')
            reqRel = matlab_relese(3:end);
            curRel = version('-release');
            if curRel < reqRel
                fprintf('MATLAB release too old: required >= %s, current is %s\n', reqRel, curRel);
            end
        else
            fprintf('MATLAB release check for %s not implemented.\n', matlabReleaseConstraint);
        end
    end
end
