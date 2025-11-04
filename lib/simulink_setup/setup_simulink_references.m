function setup_simulink_references(blocks, active_scenario)
    sig_editor_h = getSimulinkBlockHandle(fullfile(blocks.refgen.Path, 'ReferenceFile'));

    set_param(sig_editor_h, 'FileName', active_scenario.Reference);

end

