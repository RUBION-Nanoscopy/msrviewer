classdef PSFField  < uix.VBox
    properties
        Ax
        Auto
        FWHMEdit
        DistSelector
        PSF
    end
    
    
    methods 
        function self = PSFField(varargin)
            
            self.Auto = uicontrol(...
                'Parent', self, ...
                'String', 'compute automatically', ...
                'Style', 'checkbox' ...
            );
            self.Ax = axes(...
                'Parent', self, ...
                'Visible', 'off' ...
            );
            self.DistSelector = uicontrol(...
                'Parent', self, ...
                'Style','popupmenu', ...
                'String', {'Gaussian', 'Lorentzian'} ...
            );
            hb = uix.HBox('Parent', self);
            uix.Text('Parent',hb,...
                'String','FWHM/nm:',...
                'HorizontalAlignment','right');
            self.FWHMEdit = uicontrol(...
                'Style', 'edit', ...
                'Parent', hb);
            uicontrol('Parent', hb, ...
                'String', 'OK', ...
                'Callback', @(~,~)self.update() ...
            );
            hb.Widths = [-1 -1 32];
            self.Heights = [24 -1 24 24];
            try
                uix.set( self, varargin{:} )
            catch e
                delete( self )
                e.throwAsCaller()
            end 
        end
        
        function psf = getPSF( self, width, scale )
            fwhm = str2double(self.FWHMEdit.String);
            if isempty(fwhm) || isnan(fwhm)
                psf = NaN; 
                return
            end
            switch self.DistSelector.String{self.DistSelector.Value}
                case 'Gaussian'
                    psf = gauss2D(width, fwhm*1e-3 * scale);
                case 'Lorentzian'
                    psf = lorentz2d(width, width, fwhm*1e-3 * scale);
            end
        end
        
    end
    
    methods (Access = protected)
        function update(self)
            self.PSF = self.getPSF(128, 128/1.5);
            imagesc(self.Ax, self.PSF);
            self.Ax.XTick=[1 128];
            self.Ax.XTickLabels=[0 1.5];
            self.Ax.YTick=[1 128];
            self.Ax.YTickLabels=[0 1.5];
            xlabel(self.Ax, 'x/µm');
            ylabel(self.Ax, 'y/µm');
            self.Ax.DataAspectRatio=[1 1 1];
            colormap(self.Ax, hot);
        end
    end
    
end