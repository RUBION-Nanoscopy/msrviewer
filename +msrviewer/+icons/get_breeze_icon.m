function cdata = get_breeze_icon( icon, varargin )
    d = double(imread(['+msrviewer/+icons/' icon '.png']))/255;
    cdata = zeros(size(d,1), size(d,2), 3);
    cdata(:,:,1) = d;
    cdata(:,:,2) = d;
    cdata(:,:,3) = d;