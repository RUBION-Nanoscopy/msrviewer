classdef MSRViewer < handle
    
    
    properties
        Figure
        
        Data
        Meta
        
        IconCounter
        SkipFirst
        Title
        FitSelector
        Ax
        PsfAx
        DeconAx
        LineProfileAx 
        TabPanel
        MainHB
        IData
        PSF
        DeconRes = {}
        DampingEdit
        AxSelection

        FitResultTable
        
        Listeners = struct();
    end
    
    properties ( SetObservable )
        Idx
    end
    
    properties %(Access = protected)
        gui = struct()
        data_info = struct()
        internals = struct()
        ome_reader 
    end
    
    properties ( SetObservable )
        previewed_data = NaN;
    end
    
    methods
        function self = MSRViewer( varargin )
            
            
            self.composeGUI();
            
            self.Listeners.Preview = addlistener(self,...
                'previewed_data', 'PostSet', ...
                @(~, ~)self.preview_msr_data ...
            );
            
            
            if nargin > 0
                self.load_msr_data(varargin{1});
            end
            
            
                
            
        end
    end
    
    methods ( Access = protected )
        function composeGUI(self)
            % scsz = phutils.gui.getScreensize();
            
            % The GUI consists of three parts:
            % Main axes 
            % Analysis Tab
            % Control 
            self.Figure = figure(...
                ... %'Position', [round((scsz(1)-1280)/2) round(scsz(2)*2/3)-1280/2 1280 512], ...
                'Toolbar', 'none',...
                'Menubar', 'none', ...
                'WindowState', 'maximized', ... 
                'Name', 'MSRViewer' ...
            );
        
            self.addMenu();
            
            
            hb = uix.HBox(...
                'Parent', self.Figure, ...
                'Padding', 5 ...
            );
            
            vboxsettings = {'Spacing', 5};
        
            lvbox = uix.VBox(...
                'Parent', hb, ...
                vboxsettings{:} ...
            );
            rvbox = uix.VBox(...
                'Parent', hb, ...
                vboxsettings{:} ...
            );
            
            hb.Widths = [-2 -3];
            
            % The left VBox lvbox has three rows. For sinmplicity, I surround
            % every row with a hbox.
            
            self.gui.l_row1 = uix.HBox('Parent', lvbox);
            self.gui.l_row2 = uix.HBox('Parent', lvbox);
            self.gui.l_row3 = uix.HBox('Parent', lvbox);
            
            lvbox.Heights = [-1 -1 -1];
            
            % The right vbox consists of three rows, too.
            
            self.gui.r_row1 = uix.HBox('Parent', rvbox);
            self.gui.r_row2 = uix.HBox('Parent', rvbox);
            self.gui.r_row3 = uix.HBox('Parent', rvbox);
            
            rvbox.Heights = [64 -1 -8];
            
            self.compose_gui_psf();
            self.compose_gui_decon();
            self.compose_gui_orig();
            
            self.compose_gui_toolbar();
            
            self.Ax = phutils.gui.ThreeChannelImage(...
                'Parent', self.gui.r_row3 ...
            );
            
        end
        
        compose_gui_psf( self )
        compose_gui_decon( self )
        compose_gui_orig( self )
        compose_gui_toolbar( self )
        
        menu_file_open( self )
        
        load_msr_data ( self, data )
        
        preview_msr_data ( self )
        
        
        function show(self, varargin)
%             autoskip = true;
%             if nargin == 2
%                 autoskip = varargin{1};
%             end
%             d = uint16(self.Data{self.Idx, 1}{1});
%             meta = self.Data{self.Idx,2};
%             [xpx, ypx] = size(d);
%             imsz = meta.get('Lengths');
%             scalex = xpx/imsz(1).get(0);
%             scaley = ypx/imsz(1).get(1);
%             if autoskip
%                 if all(d(:,1) > d(:,2))
%                     
%                     imagesc(self.Ax, d(:,2:end),'HitTest','off');
%                     self.SkipFirst.Value = true;
%                     self.Ax.XTick=[1,xpx-1];
%                     self.Ax.XTickLabels={1/scalex, imsz(1).get(0)};
%                 else
%                     imagesc(self.Ax, d,'HitTest','off');
%                     self.SkipFirst.Value = false;
%                     self.Ax.XTick=[1,xpx];
%                     self.Ax.XTickLabels={0, imsz(1).get(0)};
%                 end
%             else
%                 if self.SkipFirst.Value == true
%                     imagesc(self.Ax, d(:,2:end),'HitTest','off');
%                     self.Ax.XTick=[1,xpx-1];
%                     self.Ax.XTickLabels={1/scalex, imsz(1).get(0)};
%                 else
%                     imagesc(self.Ax, d,'HitTest','off');
%                     self.Ax.XTick=[1,xpx];
%                     self.Ax.XTickLabels={0, imsz(1).get(0)};
%                 end
%             end
%             self.Ax.YTick = [1 ypx];
%             self.Ax.YTickLabels={0, imsz(1).get(1)};
%             colormap(self.Ax, hot);
%             self.Ax.YLim = [0 size(d,2)];
%             self.Ax.XLim = [0 size(d,1)];
%             self.Ax.DataAspectRatio=[1 1 1];
%             self.IconCounter.String = sprintf('%g/%g', self.Idx, size(self.Data,1));
%             
%             self.Title = title(self.Ax,meta.get('Name'));
        end
        function addMenu(self)
            file = uimenu(...
                'Parent', self.Figure, ...
                'Text',  'File' ...
            );
            f_open = uimenu(...
                'Parent', file, ...
                'MenuSelectedFcn', @(~,~)self.menu_file_open, ...
                'Text', 'Open'...
            );
            f_save = uimenu(...
                'Parent', file, ...
                'Text', 'Save' ...
            );
            f_quit = uimenu(...
                'Parent', file, ...
                'Separator','on', ...
                'Text', 'Quit' ...
            );
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
                w(self.IData<=q) = .1;
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
        function update_line_profile(self, evt, src)
            p = improfile(self.Ax.Children(2).CData, ...
                self.AxSelection.Selection(:,1), ...
                self.AxSelection.Selection(:,2)...
            );
            plot(self.LineProfileAx, p);
        end
        function fit_to_profile(self)
            p = improfile(self.Ax.Children(2).CData, ...
                self.AxSelection.Selection(:,1), ...
                self.AxSelection.Selection(:,2)...
            );
            
            if strcmp(self.FitSelector.SelectedObject.String, 'Gaussian')
                ffunc = @(a,BG,x0,fwhm,x)(...
                    BG + a.* ... 
                    exp(...
                        -((x-x0).^2) ... % Nominator
                        /...
                        ((fwhm/(2*sqrt(2*log(2)))).^2) ... % denominator
                    ) ...
                );
                ftype = 'Gaussian';
            elseif strcmp(self.FitSelector.SelectedObject.String, 'Lorentzian')
                ffunc = @(a,BG,x0,fwhm,x)(...
                    BG + a.* ...
                    (fwhm/2).^2 ./ ((x-x0).^2+(fwhm/2).^2) ...
                );
                ftype = 'Lorentz';
            end
            idx = find(p == max(p));
            if numel(idx) > 1
                idx = idx(1);
            end
            xpos = 1:numel(p);
            fo = fitoptions(...
               'Method', 'NonLinearLeastSquares', ...
               'Lower',[0,0,0,0],...
               'Upper',[max(p),max(p), numel(p), numel(p)/2],...
               'StartPoint',[max(p), 0, xpos(idx), 1]);
           
           
            F = fit((1:numel(p))', p, ffunc, fo);
            self.LineProfileAx.NextPlot = 'add';
            fplot = plot(self.LineProfileAx, ...
                (1:numel(p))', feval(F, (1:numel(p))'), 'r');
            self.LineProfileAx.NextPlot = 'replace';
            ci = confint(F);
            d = uint16(self.Data{self.Idx, 1}{1});
            meta = self.Data{self.Idx,2};
            [xpx, ypx] = size(d);
            imsz = meta.get('Lengths');
            scalex = xpx/imsz(1).get(0);
            scaley = ypx/imsz(1).get(1);
            self.FitResultTable.Data(end+1,:) = {ftype, F.fwhm/scalex ,(F.fwhm - ci(1,4))/scalex, true};
        end
    end
end