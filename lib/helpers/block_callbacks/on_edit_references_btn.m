function on_edit_references_btn()
    pa = @BlockHelpers.path_append;

    handle = gcbh;
    ref_name = getfullname(handle);

    env_name = gcs;
    env_path = fileparts(which(env_name));


    % if no config, this is not an environment
    if ~exist(pa(env_path, 'config.json'), 'file')
        return
    end
    edit_references(env_path);

    % env_h = get_param(env_name, 'Handle');
    % 
    % r_h = getSimulinkBlockHandle(pa(ref_name, 'Reference'));
    % mo = get_param(r_h, 'MaskObject');
    % 
    % path = '';
    % for i=1:length(mo.Parameters)
    %     if strcmp(mo.Parameters(i).Name, 'FileName')
    %         path = mo.Parameters(i).Value;
    %         break;
    %     end
    % end


end