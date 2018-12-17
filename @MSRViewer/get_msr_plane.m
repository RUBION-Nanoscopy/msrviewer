function d = get_msr_plane(self)

self.ome_reader.setId( self.data_info.filename );

self.ome_reader.setSeries( self.previewed_data(1) );

% bfGetPlane uses MATLAB-like indexing, starting with 1
d = bfGetPlane(self.ome_reader, self.previewed_data(2)+1 );