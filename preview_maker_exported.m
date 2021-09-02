classdef preview_maker_exported < matlab.apps.AppBase
    %PREVIEW_MAKER_EXPORTED GatherTown Preview Image Maker
    %   User selects a rectangular region on poster to create a preview
    %   image for a GatherTown poster session.
    %   
    %   Original should be png or jpg for GatherTown.
    %   
    %   Copyright 2021. David Atkinson, University College London.
    %   D.Atkinson@ucl.ac.uk

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        SavePreviewButton              matlab.ui.control.Button
        PreviewFileNameEditField       matlab.ui.control.EditField
        PreviewFileNameEditFieldLabel  matlab.ui.control.Label
        RegionSelectButton             matlab.ui.control.Button
        InputFileNameTextArea          matlab.ui.control.TextArea
        InputFileNameTextAreaLabel     matlab.ui.control.Label
        BrowseButton                   matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
    end

    
    properties (Access = private) 
        roi   % roi of rectangle
        ffn   % full file name of poster image
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            % select file
            app.ffn = pref_uigetfile('preview_maker','filename')  ;

            if exist(app.ffn,'file')
                imshow(app.ffn,"Parent",app.UIAxes)
                axis(app.UIAxes,'image')

                [filepath,fname,ext] = fileparts(app.ffn) ;
                app.InputFileNameTextArea.Value = [fname, ext] ;

                % set output filename
                fnpreview = [fullfile(filepath,[fname,'_preview']),ext] ;
                app.PreviewFileNameEditField.Value = fnpreview ;

                % if it already exists, make red as warning
                if exist(fnpreview,'file')
                    app.PreviewFileNameEditField.FontColor = [1 0 0] ;
                else
                    app.PreviewFileNameEditField.FontColor = [0 0 0] ;
                end

            end

        end

        % Button pushed function: RegionSelectButton
        function RegionSelectButtonPushed(app, event)
            % Select rectangular region
            delete(app.roi)
            rect = drawrectangle("parent",app.UIAxes,"AspectRatio",0.25) ;
            app.roi = rect ;
        end

        % Button pushed function: SavePreviewButton
        function SavePreviewButtonPushed(app, event)
            % get output filename from edit area
            % crop image
            % save image

            info = imfinfo(app.ffn) ;

            % get current rectangle location
            xl = app.roi.Position(1) ;
            xu = xl + app.roi.Position(3) ;
            yl = app.roi.Position(2) ;
            yu = yl + app.roi.Position(4) ;
            
            ny = info.Height ; nx = info.Width ;
           
           
            img_poster = imread(app.ffn) ;
            img_preview = img_poster(max(1,round(yl)):min(ny,round(yu)) , ...
                                    max(1,round(xl)):min(nx,round(xu)), : ) ;
            

            imwrite(img_preview, app.PreviewFileNameEditField.Value)

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.Position = [38 98 572 292];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [55 413 76 37];
            app.BrowseButton.Text = 'Browse';

            % Create InputFileNameTextAreaLabel
            app.InputFileNameTextAreaLabel = uilabel(app.UIFigure);
            app.InputFileNameTextAreaLabel.HorizontalAlignment = 'right';
            app.InputFileNameTextAreaLabel.Position = [143 420 90 22];
            app.InputFileNameTextAreaLabel.Text = 'Input File Name';

            % Create InputFileNameTextArea
            app.InputFileNameTextArea = uitextarea(app.UIFigure);
            app.InputFileNameTextArea.Position = [247 413 195 36];

            % Create RegionSelectButton
            app.RegionSelectButton = uibutton(app.UIFigure, 'push');
            app.RegionSelectButton.ButtonPushedFcn = createCallbackFcn(app, @RegionSelectButtonPushed, true);
            app.RegionSelectButton.Position = [487 406 113 44];
            app.RegionSelectButton.Text = 'Region Select';

            % Create PreviewFileNameEditFieldLabel
            app.PreviewFileNameEditFieldLabel = uilabel(app.UIFigure);
            app.PreviewFileNameEditFieldLabel.HorizontalAlignment = 'right';
            app.PreviewFileNameEditFieldLabel.Position = [-4 45 105 22];
            app.PreviewFileNameEditFieldLabel.Text = 'Preview File Name';

            % Create PreviewFileNameEditField
            app.PreviewFileNameEditField = uieditfield(app.UIFigure, 'text');
            app.PreviewFileNameEditField.Position = [116 32 395 47];

            % Create SavePreviewButton
            app.SavePreviewButton = uibutton(app.UIFigure, 'push');
            app.SavePreviewButton.ButtonPushedFcn = createCallbackFcn(app, @SavePreviewButtonPushed, true);
            app.SavePreviewButton.Position = [524 35 88 40];
            app.SavePreviewButton.Text = 'Save Preview';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = preview_maker_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end