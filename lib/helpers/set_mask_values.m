function set_mask_values(handle, varargin)
    
    if nargin == 2
        if ~isa(varargin{1}, 'struct')
            error('Cannot set mask values. Second argument must be a struct');
        end
        names = fieldnames(varargin{1});
        for i=1:length(names)
            params(i).Name = names{i};
            params(i).Value = varargin{1}.(names{i});
        end
    else

        c = 1;
        for i=2:2:length(varargin)
            params(c).Name = varargin{i-1};
            params(c).Value = varargin{i};
            c = c + 1;
        end
    end

    mo = get_param(handle, 'MaskObject');
    for i=1:length(params)
        p = params(i);
        for j=1:length(mo.Parameters)
            mo_p = mo.Parameters(j);
            if strcmp(p.Name, mo_p.Name)
                mo_p.Value = p.Value;
                break
            end
        end
    end
    ss = get_param(handle, 'MaskValues');
    a = 5;

end

