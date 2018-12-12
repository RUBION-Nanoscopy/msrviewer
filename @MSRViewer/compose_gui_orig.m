function compose_gui_orig( self )
%COMPOSE_GUI_ORIG Composes the components of the original data preview


panel = uix.Panel(...
    'Parent', self.gui.l_row1, ...
    'Title', 'Original data' ...
);


self.gui.DataPreview = msrviewer.gui.DataPreview(...
    'Parent', panel ...
);


