function rel_path = component_relative_path(component)
    

    component_type = component.ComponentType;
    if ~is_valid_field(component, 'ParentComponentType')
        rel_path = get_rel_path_for_component(component_type);
        return
    end
    parent_component_type = component.ParentComponentType;
    parent_component_id = component.ParentComponentId;
    dest_path = component.DestinationPath;
    rel_path = get_rel_path_for_component(parent_component_type);
    rel_path = fullfile(rel_path, parent_component_id, 'subcomponents', ...
        dest_path);

    
end

function rel_path = get_rel_path_for_component(component_type)
    rel_path = 'parts';
    switch component_type
        case 'controller'
            rel_path = fullfile(rel_path, 'controllers');
        case 'metric'
            rel_path = fullfile(rel_path, 'metrics');
        case 'scenario'
            rel_path = fullfile(rel_path, 'scenarios');
        case 'system'
            rel_path = fullfile(rel_path, 'systems');
        otherwise
            error('Unknown component type: %s', component_type);
    end
end
