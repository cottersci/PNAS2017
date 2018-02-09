classdef FieldView<handle
    %
    %Generates a plot of agent positions within the fiel. Called by Engine
    %
    
    properties
        field %The Field to be viewed
        hfig = NaN;  %The handle of the figure to darw in
        haxes = NaN; %Axes handel

        saveFigs = 0;
    end

    methods
        function obj = FieldView(field)
            obj.field = field;
        end

        %
        % Redraw the view
        %
        function update(obj)

            if ishandle(obj.hfig)
                %subplot(1,2,1)
                cla
                cellList = obj.field.cellList;
                coords = zeros(length(cellList),3);
                for i = 1:length(cellList)
                    [coords(i,1), coords(i,2)] = cellList{i}.getWrappedPosition();
                    coords(i,3) = cellList{i}.ori;
                end

                %cla(obj.haxes);
                %density = imresize(obj.field.density(:,:,max(obj.field.currentStep,1)),[obj.field.ySize,obj.field.xSize]);
                %density = (density - obj.field.dmin) ./ obj.field.drange;
                %imagesc(density);
                %imagesc(imresize(obj.field.density(:,:,end),[obj.field.ySize,obj.field.xSize]));
                hold on;
                %plot(coords(:,1),coords(:,2),'ow')
                %for i = 1:size(coords,1)
                %    density = obj.field.getDensity(coords(i,1),coords(i,2));
                %    if(density < 0)
                %        text(coords(i,1),coords(i,2),num2str(round(density,3)),'Color','r');
                %    else
                %        text(coords(i,1),coords(i,2),num2str(round(density,3)),'Color','k');
                %    end
                    %text(coords(i,1),coords(i,2),[num2str(round(coords(i,1),2)),',',num2str(round(coords(i,2),2))])
                %end
                obj.drawCell(obj.haxes,coords(:,1),coords(:,2),5,coords(:,3));
                xlim([0 obj.field.xSize])
                ylim([0 obj.field.ySize])
                xlabel('\mum');
                ylabel('\mum');

                plot(obj.field.aggs_in_frame.x,obj.field.aggs_in_frame.y,'ow')


                phi = linspace(0,2*pi,50);
                cosphi = cos(phi);
                sinphi = sin(phi);
                for k = 1:length(obj.field.aggs_in_frame.x)
                    xbar = obj.field.aggs_in_frame.x(k);
                    ybar = obj.field.aggs_in_frame.y(k);
                    theta = obj.field.aggs_in_frame.orientation(k);
                    a = obj.field.aggs_in_frame.majorAxis(k)/2;
                    b = obj.field.aggs_in_frame.minorAxis(k)/2;

                    R = [ cos(theta) sin(theta)
                         -sin(theta) cos(theta)];
                    xy = [a * cosphi; b*sinphi];
                    xy = R*xy;

                    plot(xy(1,:) + xbar, xy(2,:) + ybar); %, ...
                        %'Color',color_chooser(obj.field.aggs_in_frame.id(k)));
                end

                colormap('jet');
                colorbar;
                caxis([0 1]);
                drawnow

                %subplot(1,2,2)
                %    cla
                %    [~,density] = kde2d([coords(:,1) coords(:,2)],2^9,[0, 0],[obj.field.xSize obj.field.ySize]);
                %    imagesc(density .* 7.3544e+06)
                 %   colorbar;
                  %  drawnow;

            end
        end

        %
        % Activate the view
        %
        function obj = viewON(obj)
            if ~ishandle(obj.hfig)
                obj.hfig = figure;
                obj.haxes = axes;
                obj.update();
            end
        end

        %
        % Deactivate the view
        %
        function obj = viewOFF(obj)
            if ishandle(obj.hfig)
                close(obj.hfig);
            else
                %warning('No figure to close')
            end

            obj.hfig = NaN;
            obj.haxes = NaN;
        end

        function drawAlignmnet(obj)
            E = obj.field.curE;
            hold on;
            line([E.x - (3 * cos(E.o)) E.x + (3 * cos(E.o))]', ...
                 [E.y - (3 * sin(E.o)) E.y + (3 * sin(E.o))]', ...
                 'Color','w')
        end

        function drawCell(~,haxes,x,y,l,o)
            line([x - l * cos(o) x + l * cos(o)]', ...
                 [y - l * sin(o) y + l * sin(o)]', ...
                 'Parent',haxes);
        end

    end

end
