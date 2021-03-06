function preview_msr_data( self )
%PREVIEW_MSR_DATA Shows the current preview


self.gui.DataPreview.Data = self.get_msr_plane();




[d,f] = fileparts(self.data_info.filename);
self.gui.DataPreview.Info = {...
    'File', f; ...
    'Folder', d ...
};

self.gui.DataPreview.Text = sprintf('S: %g/%g, I: %g/%g', ...
    self.previewed_data(1)+1, ...
    self.data_info.SeriesCount, ...
    self.previewed_data(2)+1, ...
    self.data_info.SeriesPlanesCount(self.previewed_data(1)+1) ...
);

self.ome_reader.close();