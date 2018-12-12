function load_msr_data( self, datafile )

% a msr file is organized in series, a series is divided in planes. 
% See https://docs.openmicroscopy.org/bio-formats/5.9.2/developers/matlab-dev.html

% To save memory, it is not required to have all data in memory, but they
% can be read once they are accessed, as long as they are not used.

self.data_info.filename = datafile;
self.ome_reader = bfGetReader();
self.ome_reader = loci.formats.Memoizer( self.ome_reader );

self.ome_reader.setId(datafile);

% Provide the content information
self.data_info.SeriesCount = self.ome_reader.getSeriesCount();
self.data_info.SeriesPlanesCount = zeros(self.data_info.SeriesCount,1);

for series = 0:self.data_info.SeriesCount - 1 % It uses java-indexing!
    self.ome_reader.setSeries(series);
    self.data_info.SeriesPlanesCount(series+1) = self.ome_reader.getImageCount();
end
self.ome_reader.close();

self.previewed_data = [0 0];
    

