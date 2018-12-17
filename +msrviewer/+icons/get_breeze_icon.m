function cdata = get_breeze_icon( icon, varargin )
    [a,~,alpha] =  imread(['+msrviewer/+icons/' icon '.png']);
    d = double(a)/255;
    cdata = zeros(size(d,1), size(d,2), 3);

    bg = phutils.gui.getDefaultPanelBG();
    
    if size(d,3) > 1
        r = d(:,:,1);
        g = d(:,:,2);
        b = d(:,:,3);
    else
        r = d;
        g = d;
        b = d;
    end
    if ~isempty(alpha)
        alpha = double(alpha)/255;
        r = r.*alpha + (1-alpha)*bg(1);
        g = g.*alpha + (1-alpha)*bg(2);
        b = b.*alpha + (1-alpha)*bg(3);
    else
        % Fake transparency
        r(r == 1) = bg(1);
        g(g == 1) = bg(2);
        b(b == 1) = bg(3);
    end
    cdata(:,:,1) = r;
    cdata(:,:,2) = g;
    cdata(:,:,3) = b;
    
    
