classdef DataPreview < uix.HBox
    
    properties
        
        % Callbacks
        NextClicked = []
        PrevClicked = []
        LastClicked = []
        FirstClicked = []
        ButtonBar
    end
    
    properties (Dependent)
        Data
        Info
        Text
    end
    
    properties (Access = protected) 
        
        info = {}
        ax
        counter
        prev_btn
        next_btn
        first_btn
        last_btn
        info_tbl
    end
    properties (Access = protected, SetObservable)
        data_
    end
    methods
        function self = DataPreview ( varargin )
            panel = uix.Panel(...
                'Parent', self, ...
                'Title', 'Preview' ...
            );
            vb = uix.VBox( ...
                'Parent', panel, ...
                'Spacing', 5 ...
            );
            self.ButtonBar = phutils.gui.ButtonBoxBar(...
                'Parent', vb ...
            );
            navigation = phutils.gui.LabeledButtonBox(...
                'Parent', self.ButtonBar, ...
                'ButtonSize', [32 32], ...
                'Label', 'Navigation' ...
            );
            self.first_btn = uicontrol(...
                'Parent', navigation , ...
                'CData', msrviewer.icons.get_breeze_icon('media-skip-backward'), ...
                'Callback', @self.call_callback ...
            );
        
            self.prev_btn = uicontrol(...
                'Parent', navigation , ...
                'CData', msrviewer.icons.get_breeze_icon('media-seek-backward'), ...
                'Callback', @self.call_callback ...
            );

            self.next_btn = uicontrol(...
                'Parent', navigation , ...
                'CData', msrviewer.icons.get_breeze_icon('media-seek-forward'), ...                
                'Callback', @self.call_callback ...
            );
            self.last_btn = uicontrol(...
                'Parent', navigation , ...
                'CData', msrviewer.icons.get_breeze_icon('media-skip-forward'), ...
                'Callback', @self.call_callback ...
            );
        
            counterbox = phutils.gui.LabeledHBox(...
                'Parent', self.ButtonBar, ...
                'PreferredWidth', 100, ...
                'Label', 'Info' ...
            );
            self.counter = uix.Text(...
                'Parent', counterbox, ...
                'VerticalAlignment','middle', ...
                'String', '' ...
            );    
            
        
            % This is required to circumvent a bug in the implementation of
            % ButtonBoxBar. 
            % @TODO: Fix the bug :)

            navigation.Parent = self.ButtonBar;
            counterbox.Parent = self.ButtonBar;
            self.ax = axes(...
                'Parent', uix.Panel(...
                    'BorderType', 'none', ...
                    'Parent', vb ...
                ) ...
            );
        
            
            panel = uix.Panel(...
                'Parent', self, ...
                'Title', 'File details' ...
            );
            self.info_tbl = uitable(...
                'ColumnName', {'Description', 'Value'}, ...
                'Units', 'normalized', ...
                'ColumnWidth', {'auto', 'auto'}, ...
                'Parent', panel ...
            );
            self.info_tbl.Position(3) = 1;
            vb.Heights = [self.ButtonBar.PreferredHeight -1];    
        
            self.Widths = [-1 -1];
            self.Spacing = 10;
            self.Padding = 10;
            try
                uix.set( self, varargin{:} )
            catch e
                delete( self )
                e.throwAsCaller()
            end
            
%            addlistener(self, 'Data', 'PostSet', ...
%                @self.show_data);
        end
        
        function set.Data( self, data )
            minX = self.ax.Position(3);
            minY = self.ax.Position(4);
            
            ratioX = minX / size(data,2);
            ratioY = minY / size(data,1);
            
            self.data_ = imresize( data, min( [ratioX, ratioY] ));
            
            self.show_data();
        end
        
        function d = get.Data( self )
            d = self.data_;
        end
        
        function set.Info ( self, info )
            self.info_tbl.Data = info;
        end
        function info = get.Info( self )
            info = self.info_tbl.Data;
        end
        function set.Text(self, txt)
            self.counter.String = txt;
        end
        function txt = get.Text(self)
            txt = self.counter.String;
        end
    end
    methods (Access = protected)
        function redraw( self )
            redraw@uix.HBox(self); drawnow;
            % A maybe not so nice hack to set the column width to fill the
            % parent container. Might be possible in an easier way.
            w = self.info_tbl.Parent.InnerPosition(3);
            self.info_tbl.ColumnWidth = {w/2 w/2};
            drawnow;
            we = self.info_tbl.Extent(3);
            self.info_tbl.ColumnWidth = {(w-(we-w))/2 (w-(we-w))/2};
        end
        
        function show_data( self )
            imagesc(self.ax, self.data_);
            self.ax.DataAspectRatio=[1 1 1];
            colormap(hot);
        end
        
        function call_callback(self, src, ~)
            if src == self.next_btn 
                cb = self.NextClicked;
                cbname = 'NextClicked';
            elseif src == self.prev_btn
                cb = self.PrevClicked;
                cbname = 'PrevClicked';
            elseif src == self.first_btn
                cb = self.FirstClicked;
                cbname = 'FirstClicked';
            elseif src == self.last_btn
                cb = self.LastClicked;
                cbname = 'LastClicked';
            end
            
            if isa(cb, 'function_handle')
                cb();
            elseif iscell(cb) && isa(cb{1}, 'function_handle')
                args = cb(2:end);
                cb = cb{1};
                cb(args{:}); %#ok<NOEFF>
            else
                error('MSRViewer:WrongCallbackFormat', ...
                    'The callback for %s should either be a function handle or a cell array with the first element being a function handle and the other elements being passed as arguments.', ...
                    cbname );
            end
        end
    end
end