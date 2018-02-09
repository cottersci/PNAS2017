function [] = saveFigures( varargin )
%[] = saveFigures( opts )
%   Export open figure(s) to a directory in mutiple formats. By default the
%   function exports the last active function in the png and fig formats.
%
%OPTIONAL INPUTS
% Style     Use the predefined export style. Unless 'none' is supplied
%                a default export style is applied.
%                saveFigures('Style','PosterFigure');
% Figures   vector containg the figure handles to save
%                saveFigures('Figures',[1 2 3])
% Formats   cell array of file types to save figure as (Default {'png','fig'})
%                supported types are: png, tiff, pdf, jpeg, fig
%                saveFigures('Types',{'png'})
% Path      the directory to have the files to (Default: Ask user)
%                saveFigures('Path','/home/someone/MATLAB/figures/')
% SaveAs    name of the file (Default: Figure name, if figure name empty
%                 ask user).
%                saveFigures('SaveAs','figure122')
%           also supports setting the entire path, this overrides the Path
%           setting
%                saveFigures('SaveAs','/home/someone/figure122')
%           if more than one figure is saved, then a postfix '-#' whith the
%           figure number of the figure (starting at 1) is added
% Render    The renderer to use, options are (Defualt is opengl):
%               painters, zbuffer, opengl 
%               see manual on the print function for detals
%               saveFigures('Render','zbuffer')
% r         resolution of the output (default is 300) see manual on the
%               print function option -R for more details
%               saveFigures('r',500)
% Size      size of the image, in [width height]. Default untis are
%               in points, can be changed with PaperUnits
%               saveFigures('Size',[10 20])
% Units     units Size is defined in. Options are
%               'inches' | 'centimeters' | 'normalized' | 'points' | 'picas'
%                default is picas
%                saveFigures('Size',[10 20],'PaperUnits','inches')

% Author: Chris Cotter (cotter@sciencesundries.com)

    p = inputParser;
    
    addParamValue(p,'Figures',gcf(),@isnumeric)
    addParamValue(p,'Formats',{'fig','png'},@iscell)
    addParamValue(p,'Style', '', @ischar);
    addParamValue(p,'SaveAs','',@ischar);
    addParamValue(p,'Path','',@ischar);
    addParamValue(p,'Render','opengl',@ischar);
    addParamValue(p,'r',300,@isnumeric);
    addParamValue(p,'Size',[],@(x) size(x,2) == 2);
    addParamValue(p,'Units','picas', ...
                    @(x) ismember(x,{'inches', 'centimeters', 'normalized', 'points'}));
                
    parse(p, varargin{:});

    SYLE_NAME = p.Results.Style;
    FIGURES = p.Results.Figures;
    SAVE_AS = p.Results.SaveAs;
    PATH = p.Results.Path;
    RENDER = p.Results.Render;
    RESOLUTION = p.Results.r;
    FORMATS = p.Results.Formats;
    SIZE = p.Results.Size;
    UNITS = p.Results.Units;
    
    %Override path if necessary and remove ext
    [save_as_path,save_as_fileName,~] = fileparts(SAVE_AS);
    
    opt_vars = {};
    for fig = FIGURES
        if strcmp(SYLE_NAME,'none')
            %%Do not apply any sytle
        elseif isempty(SYLE_NAME)      % Apply a default style
            style = struct();
            style.Version = '1';
            style.Format = 'eps';
            style.Preview = 'none';
            style.Width = 'auto';
            style.Height = 'auto';
            style.Units = 'centimeters';
            style.Color = 'rgb';
            style.Background = 'w';          % '' = no change; 'w' = white background
            style.FixedFontSize = '10';
            style.ScaledFontSize = 'auto';
            style.FontMode = 'fixed';
            style.FontSizeMin = '24';
            style.FixedLineWidth = '2';
            style.ScaledLineWidth = 'auto';
            style.LineMode = 'fixed';
            style.LineWidthMin = '2';
            style.FontName = 'auto';
            style.FontWeight = 'auto';
            style.FontAngle = 'auto';
            style.FontEncoding = 'latin1';
            style.PSLevel = '2';
            style.Renderer = 'auto';
            style.Resolution = 'auto';
            style.LineStyleMap = 'none';
            style.ApplyStyle = '0';
            style.Bounds = 'loose';
            style.LockAxes = 'on';
            style.ShowUI = 'on';
            style.SeparateText = 'off';

            hgexport(fig,'temp_dummy',style,'applystyle', true);

        else
            % Apply an existing style, defined as in the Export dialog
            % The files are in folder   fullfile(prefdir(0),'ExportSetup');
            style = hgexport('readstyle',SYLE_NAME);
            hgexport(fig,'temp_dummy',style,'applystyle', true);
        end

        %Set the filename
        if(isempty(save_as_fileName))
            fileName = get(fig,'Name');
        else
            if(~isnumeric(fig))
                  fileName = save_as_fileName;
            else
                  fileName = [save_as_fileName '-' num2str(fig)];
            end
        end
        
        %Set the path to the file
        filePath = PATH;
        if(~isempty(save_as_path))
            filePath = save_as_path;
        end
        if(isempty(fileName) || isempty(filePath))
            if(isempty(filePath))
                [fileName, filePath] = uiputfile('*','Save Figure',fileName);
            else
                [fileName, filePath] = uiputfile('*','Save Figure',[filePath '/' fileName]);
            end   
        end
        if(filePath == 0) %Exit if cancel is chosen
             return
        end
        if(~isempty(SIZE))
            if(strcmp(UNITS,'picas'))
                SIZE = SIZE .* 12;
                UNITS = 'points';
            end
            
            if(isnumeric(fig))
                f = findobj(0,'number',fig);
            else
                f = fig;
            end
            f.PaperUnits = UNITS;
            f.PaperPosition = [0 0 SIZE];  
            f.Position = [f.Position(1) f.Position(2) SIZE];
        end

        if(isnumeric(fig))
            f = findobj(0,'number',fig);
        else
            f = fig;
        end      
        ax = findobj(f,'type','axes');
        set(ax(1),'LooseInset',get(ax(1),'TightInset'))

        
        for f = FORMATS
            switch f{1}
                case 'png'
                    print(fig,'-dpng',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.png']);
                case 'fig'
                    savefig(fig,[filePath '/' fileName '.fig']);
                case 'jpeg'
                    print(fig,'-djpeg',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.jpeg']);
                case 'pdf'
                    print(fig,'-dpdf',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.pdf']);
                case 'tiff'
                    print(fig,'-dtiff',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.tiff']);
                case 'eps'
                    print(fig,'-painters','-depsc',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.eps']);
                    %saveas(fig,[filePath '/' fileName '.eps'],'eps');
                case 'svg' 
                    print(fig,'-dsvg',['-' RENDER],['-r' num2str(RESOLUTION)],[filePath '/' fileName '.svg']);
            end
        end
        
        %Default to the same path for the next figure
        save_as_path = filePath;
    end    
end

