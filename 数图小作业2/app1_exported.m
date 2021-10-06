classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        LeftPanel       matlab.ui.container.Panel
        ASlider         matlab.ui.control.Slider
        ASliderLabel    matlab.ui.control.Label
        EVLabel         matlab.ui.control.Label
        EVValueLabel    matlab.ui.control.Label
        ISOSlider       matlab.ui.control.Slider
        ISOSliderLabel  matlab.ui.control.Label
        RightPanel      matlab.ui.container.Panel
        Image           matlab.ui.control.Image
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changing function: ISOSlider
        function ISOChanging(app, event)
            changingValue = event.Value;
            app.EVValueLabel.Text = string(round(changingValue));
        end

        % Value changed function: ISOSlider
        function ISOChanged(app, event)
            value = app.ISOSlider.Value;
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {242, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {242, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create ISOSliderLabel
            app.ISOSliderLabel = uilabel(app.LeftPanel);
            app.ISOSliderLabel.HorizontalAlignment = 'right';
            app.ISOSliderLabel.Position = [22 261 26 22];
            app.ISOSliderLabel.Text = 'ISO';

            % Create ISOSlider
            app.ISOSlider = uislider(app.LeftPanel);
            app.ISOSlider.Limits = [100 6400];
            app.ISOSlider.ValueChangedFcn = createCallbackFcn(app, @ISOChanged, true);
            app.ISOSlider.ValueChangingFcn = createCallbackFcn(app, @ISOChanging, true);
            app.ISOSlider.Position = [69 270 150 3];
            app.ISOSlider.Value = 100;

            % Create EVValueLabel
            app.EVValueLabel = uilabel(app.LeftPanel);
            app.EVValueLabel.HorizontalAlignment = 'center';
            app.EVValueLabel.Position = [119 77 61 22];
            app.EVValueLabel.Text = '100';

            % Create EVLabel
            app.EVLabel = uilabel(app.LeftPanel);
            app.EVLabel.HorizontalAlignment = 'center';
            app.EVLabel.Position = [77 77 25 22];
            app.EVLabel.Text = 'EV';

            % Create ASliderLabel
            app.ASliderLabel = uilabel(app.LeftPanel);
            app.ASliderLabel.HorizontalAlignment = 'center';
            app.ASliderLabel.Position = [31 187 25 22];
            app.ASliderLabel.Text = 'A';

            % Create ASlider
            app.ASlider = uislider(app.LeftPanel);
            app.ASlider.Position = [77 196 150 3];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create Image
            app.Image = uiimage(app.RightPanel);
            app.Image.Position = [38 89 300 273];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_exported

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