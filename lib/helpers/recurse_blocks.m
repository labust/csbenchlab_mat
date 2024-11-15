function blocks = recurse_blocks(block)
    % Recursively explores blocks and subsystems to find and list output ports
    
    % Get all blocks in the current level
    blocks = find_system(block, 'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
        'MatchFilter', @Simulink.match.activeVariants);
    % blocks = find_system(block, 'LookUnderMasks', 'all');
    
end