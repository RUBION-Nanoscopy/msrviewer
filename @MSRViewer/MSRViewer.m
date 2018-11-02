classdef MSRViewer < handle
    
    
    properties
        Figure
        Data
        Ax
        IconCounter
        SkipFirst
        Title
        FitSelector
        PsfAx
        DeconAx
        MainHB
        IData
        PSF
        DeconRes = {}
        DampingEdit
    end
    
    properties ( SetObservable )
        Idx
    end
    
    methods
        function self = MSRViewer( data )
            if ~iscell(data)
                try 
                    self.Data = bfopen(data);
                catch
                    error('MSRViewer:CouldNotReadFile','Could not open %s', data);
                end
            else
                self.Data = data;
            end
            
            self.composeGUI();
            self.addlistener('Idx', 'PostSet', ...
                @(~,~)self.show() ...
            );
            self.Idx = 1;
        end
    end
    
    methods ( Access = protected )
        function composeGUI(self)
            scsz = phutils.gui.getScreensize();
            self.Figure = figure(...
                'Position', [round((scsz(1)-768)/2) round(scsz(2)*2/3)-512/2 768 512] ...
            );
            hb = uix.HBox('Parent', self.Figure);
            self.Ax = axes('Parent', hb);
            self.DeconAx = axes('Parent', uicontainer('Parent', hb));
            vb = uix.VBox('Parent', hb);
            
            con = uix.HBox(...
                'Parent', vb ...
            );
            b1 = uicontrol('Parent',con, ...
                'String', '<', ...
                'Callback', @(~,~)self.shift(-1) ...
            );
            self.IconCounter = uix.Text('Parent',con);
            b2 = uicontrol('Parent',con, ...
                'String', '>', ...
                'Callback', @(~,~)self.shift(1) ...
            );
            
            con.Widths = [32 -1 32];
            
            self.SkipFirst = uicontrol('Parent',vb, ...
                'Style', 'checkbox', ...
                'String','Skip first column', ...
                'Callback', @(~,~)self.toggleSkip() ...
            );
            bft = uix.Panel(...
                'Parent',vb,...
                'Title','Fit beads'...
            );
            psf = uix.Panel(...
                'Parent', vb, ...
                'Title', 'PSF' ...
            );
            self.PsfAx = msrviewer.PSFField('Parent', psf');
            self.FitSelector = uibuttongroup(...
                'Parent', bft ...
            );
            uicontrol(...
                'Parent', self.FitSelector, ...
                'String', 'Gaussian', ...
                'Position',[5 29 123, 32], ...
                'Style', 'radio' ...
            );
            uicontrol(...
                'Parent', self.FitSelector, ...
                'String', 'Lorentzian', ...
                'Position',[5 5 123, 32], ... 
                'Style', 'radio' ...
            );
            dp = uix.Panel(...
                'Title', 'RL-Deconvolution', ...
                'Parent', vb );
            dvb = uix.VBox('Parent', dp);
            uicontrol(...
                'Parent', dvb, ...
                'Callback', @(~,~)self.doDecon(), ...
                'String', 'Start' ...
            );
            self.DampingEdit = uicontrol(...
                'Style','Edit', ...
                'Parent', dvb ...
            );
            hb.Widths = [-1 0 192];
            vb.Heights=[32 32 128 128+64 128];
            self.MainHB = hb;
        end
        
        function show(self, varargin)
            autoskip = true;
            if nargin == 2
                autoskip = varargin{1};
            end
            d = self.Data{self.Idx, 1}{1};
            meta = self.Data{self.Idx,2};
            [xpx, ypx] = size(d);
            imsz = meta.get('Lengths');
            scalex = xpx/imsz(1).get(0);
            scaley = ypx/imsz(1).get(1);
            if autoskip
                if all(d(:,1) > d(:,2))
                    imagesc(self.Ax, d(:,2:end));
                    self.SkipFirst.Value = true;
                    self.Ax.XTick=[1,xpx-1];
                    self.Ax.XTickLabels={1/scalex, imsz(1).get(0)};
                else
                    imagesc(self.Ax, d);
                    self.SkipFirst.Value = false;
                    self.Ax.XTick=[1,xpx];
                    self.Ax.XTickLabels={0, imsz(1).get(0)};
                end
            else
                if self.SkipFirst.Value == true
                    imagesc(self.Ax, d(:,2:end));
                    self.Ax.XTick=[1,xpx-1];
                    self.Ax.XTickLabels={1/scalex, imsz(1).get(0)};
                else
                    imagesc(self.Ax, d);
                    self.Ax.XTick=[1,xpx];
                    self.Ax.XTickLabels={0, imsz(1).get(0)};
                end
            end
            self.Ax.YTick = [1 ypx];
            self.Ax.YTickLabels={0, imsz(1).get(1)};
            colormap(self.Ax, hot);
            self.IconCounter.String = sprintf('%g/%g', self.Idx, size(self.Data,1));
            
            self.Title = title(self.Ax,meta.get('Name'));
        end
        
        function shift( self, by)
            idx = self.Idx + by;
            
            if idx > size(self.Data,1)
                self.Idx = 1;
            elseif idx < 1
                self.Idx = size(self.Data,1);
            else
                self.Idx = idx;
            end
            
        end
        
        function toggleSkip(self)
            %v = self.SkipFirst.Value;
            %self.SkipFirst.Value = ~v;
            self.show(false);
        end
        
        function doDecon(self)
            if isempty(self.DeconRes)
                psf = self.PsfAx.getPSF(1,1);
                if isnan(psf)
                    msgbox('Compute a PSF first', 'Error');
                    return
                end
                if self.MainHB.Widths(2) == 0
                    w = self.Ax.OuterPosition(3);
                    self.Figure.Position(1) = self.Figure.Position(1)-w/2;
                    self.Figure.Position(3) = self.Figure.Position(3)+w;
                    self.MainHB.Widths(2) = -1;
                end
            
                self.interpolate();
                
                q = quantile(self.IData(:), .15);
                w = ones(size(self.IData));
                w(self.IData>q) = 1;
                w(self.IData<=q) = .3;
                damp = str2double(self.DampingEdit.String);
                if isempty(damp)  || isnan(damp)
                    damp = 0;
                end
                fprintf('Running deconvolution. May take some time.\n');
                J = deconvlucy({self.IData}, self.PSF,1,damp,w);
            else
                q = quantile(self.IData(:), .15);
                w = ones(size(self.IData));
                w(self.IData>q) = 1;
                w(self.IData<=q) = .3;
                damp = str2double(self.DampingEdit.String);
                if isempty(damp)  || isnan(damp)
                    damp = 0;
                end
                fprintf('Running deconvolution. May take some time.\n');
                J = deconvlucy(self.DeconRes, self.PSF,1,damp,w);
            end
            fprintf('Deconvolution finished.\n');
            
            imagesc(self.DeconAx, J{2});
            colormap(hot);
            self.DeconRes = J;
        end
        
        function interpolate( self )
            fprintf('Interpolating (may take some time).\n');
            d = self.Data{self.Idx, 1}{1};
            meta = self.Data{self.Idx, 2};
            sz = meta.get('Lengths');
            xscale = size(d,1)/sz.get(0);
            yscale = size(d,2)/sz.get(1);
            
            xfaktor = 0;
            while (1/xscale)/2^xfaktor > 5e-3
                xfaktor = xfaktor +1;
            end
            yfaktor = 0;
            while (1/yscale)/2^yfaktor > 5e-3
                yfaktor = yfaktor +1;
            end
            if self.SkipFirst.Value == 1
                d = d(:,2:end);
                xstart = 1/xscale;
            else
                xstart = 0;
            end
            [xg,yg] = ndgrid(...
                linspace(0,sz.get(1), size(d,1)), ...
                linspace(xstart, sz.get(0), size(d,2)) ...
            );
            [xgi, ygi] = ndgrid(...
                linspace(0,sz.get(1), size(d,1)*2^yfaktor), ...
                linspace(xstart, sz.get(0), size(d,2)*2^xfaktor) ...
            );
            GI = griddedInterpolant(xg,yg,double(d),'nearest');
            idata = GI(xgi, ygi);
            
            self.IData = idata;
            psf_size = round(2 * xscale * 2^xfaktor);
            self.PSF = self.PsfAx.getPSF(psf_size, xscale*2^xfaktor);
            fprintf('Interpolating finished.\n');
        end
    end
end