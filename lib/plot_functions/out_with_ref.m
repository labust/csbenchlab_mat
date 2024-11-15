function out_with_ref(out, plot_cfg, f_handle)
    
    if ~exist('f_handle', 'var')
        f = figure;  
    else
        f = f_handle;
        set(0, 'CurrentFigure', f_handle)
    end

    hold on; 

    if is_valid_field(plot_cfg, 'Grid')
        grid on;
    end

    if is_valid_field(plot_cfg, 'Name')
        set(f, 'Name',  plot_cfg.Name);
    end

    lw = 1;
    if is_valid_field(plot_cfg, 'LineWidth')
        lw = plot_cfg.LineWidth;
    end
    
    
    if is_valid_field(plot_cfg, 'RefDimensions')
        ref_dims = plot_cfg.RefDimensions;
    else
        ref_dim = size(out.ref.Data, 2);
        ref_dims = linspace(1, ref_dim, ref_dim);
    end

    if is_valid_field(plot_cfg, 'OutDimensions')
        out_dims = plot_cfg.OutDimensions;
    else
        out_dim = size(out.y.Data, 2);
        out_dims = linspace(1, out_dim, out_dim);
    end



    plot(out.ref.Time, out.ref.Data(:, ref_dims), 'LineWidth', lw, 'LineStyle', '--');

    names = fieldnames(out.y);
    for i=1:length(names)
        n = names{i};
        data = out.y.(n);
        sz = size(data.Data);
        if sz(end) == length(data.Data)
            plot(data.Time, squeeze(data.Data(out_dims, :, :)), 'LineWidth', lw);
        else
            plot(data.Time, squeeze(data.Data(:, out_dims)), 'LineWidth', lw);
        end
    end

    if is_valid_field(plot_cfg, 'Axis')
        axis(plot_cfg.Axis);
    end 

    if is_valid_field(plot_cfg, 'Position')
        set(gcf, 'Position',  plot_cfg.Position);
    end 

    if is_valid_field(plot_cfg, 'XLabel')
        xlabel(plot_cfg.XLabel);
    end

    if is_valid_field(plot_cfg, 'YLabel')
        ylabel(plot_cfg.YLabel);
    end

    if is_valid_field(plot_cfg, 'Legend')
        legend(plot_cfg.Legend{:});
    end

end

