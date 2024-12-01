function s = empty_plugin_container()
    s = struct('sys', empty_plugin_struct(), 'ctl', empty_plugin_struct(), ...
        'est', empty_plugin_struct(), 'dist', empty_plugin_struct());
end


function s = empty_plugin_struct()
    s = struct('Name', {}, 'Lib', {}, 'Type', {}, 'LibVersion', {});
end