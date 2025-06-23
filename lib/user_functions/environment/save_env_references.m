function save_env_references(env_path, references)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    validate_references(references);
    [~, name, ~] = fileparts(env_path);
    ref_path = fullfile(env_path, 'parts', strcat(name, '_refs.mat'));
    save(ref_path, 'references');
    % 
    % if isa(references, 'Simulink.SimulationData.Dataset')
    %     names = {};
    %     for i=1:references.numElements
    %         names{end+1} = references{i}.Name;
    %         ds = Simulink.SimulationData.Dataset;
    %         ds = ds.addElement(references{i});
    %         eval(strcat(references{i}.Name, ' = ds;'));
    %     end
    %     save(ref_path, names{:});
    % else
    %     fnames = fieldnames(references);
    %     for i=1:length(fnames)
    %         ds = references.(fnames{i});
    %         eval(strcat(fnames{i}, ' = ds;'));
    %     end
    %     save(ref_path, fnames{:});
    % end

        % names = {};
    % for i=1:refs.numElements
    %     names{end+1} = refs{i}.Name;
    %     if isa(refs{i}, 'Simulink.SimulationData.Signal')
    %         ds = Simulink.SimulationData.Dataset;
    %         ds = ds.addElement(refs{i});
    %         eval(strcat(refs{i}.Name, ' = ds;'));
    %     else
    %         eval(strcat(refs{i}.Name, ' = refs{', num2str(i), '};'));
    %     end
    % 
    % end
end