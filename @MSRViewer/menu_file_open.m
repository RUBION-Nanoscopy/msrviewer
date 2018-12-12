function menu_file_open( self )
%MENU_FILE_OPEN opens a msr file
    
    
    datapath = [];
    try
        datapath = phutils.data.get_user_datapath();
    catch 
    end
    
    try 
        datapath = self.internals.last_open_dir;
    catch 
    end
    
    if isempty(datapath)
        datapath = '.';
    end
    try 
        [f, p, idx] = uigetfile(...
            { ...
                '*.msr', 'Imspector Data Files (*.msr)' ...
            }, ...
            'Select data file to open', ...
            datapath ...   
        );
    catch e
        
    end
    
    if isequal(f, 0)
        return
    end
    
    self.internals.last_open_dir = p;
    
    self.load_msr_data(fullfile( p, f ));
    