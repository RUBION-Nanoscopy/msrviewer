function preview_msr_data( self )
%PREVIEW_MSR_DATA Shows the current preview

self.ome_reader.setId( self.data_info.filename );

self.ome_reader.setSeries( self.previewed_data(1) );

% bfGetPlane uses MATLAB-like indexing, starting with 1
d = bfGetPlane(self.ome_reader, self.previewed_data(2)+1 );
self.gui.DataPreview.Data = d;

[d,f] = fileparts(self.data_info.filename);
self.gui.DataPreview.Info = {...
    'File', f; ...
    'Folder', d ...
};

self.ome_reader.close();

