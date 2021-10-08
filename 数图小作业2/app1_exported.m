classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        EVLabel                       matlab.ui.control.Label
        EVSlider                      matlab.ui.control.Slider
        EVSliderLabel                 matlab.ui.control.Label
        defaultButton                 matlab.ui.control.StateButton
        SSlider                       matlab.ui.control.Slider
        SSliderLabel                  matlab.ui.control.Label
        FocusButtonGroup              matlab.ui.container.ButtonGroup
        BackgroundButton              matlab.ui.control.RadioButton
        ForegroundButton              matlab.ui.control.RadioButton
        ASlider                       matlab.ui.control.Slider
        ASliderLabel                  matlab.ui.control.Label
        ISOSlider                     matlab.ui.control.Slider
        ISOSliderLabel                matlab.ui.control.Label
        RightPanel                    matlab.ui.container.Panel
        RealtimeCameraSimulatorLabel  matlab.ui.control.Label
        PhotoButtonGroup              matlab.ui.container.ButtonGroup
        Optional1Button               matlab.ui.control.RadioButton
        Optional0Button               matlab.ui.control.RadioButton
        ExampleButton                 matlab.ui.control.RadioButton
        Image                         matlab.ui.control.Image
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
         example_foreground_path = "lounge-hdr-foreground.png";
         example_background_path = "lounge-hdr-background.png";
         optional_background_path = "op_bg.png";
         optional_foreground_path = "op_fg.png";
         optional_1_foreground_path = "op1_fg.png";
         optional_1_background_path = "op1_bg.png";
         photosel = "Example";
         author = "qsy"
         email = "qsy19@mails.tsinghua.edu.cn"
         focussel;
         ISO = 1100;
         A = 1.8;
         S = 28;
         k = 9;
         default_EV_ex = 3.04392;
         default_EV_op = 8.01792;
         default_EV_op_1 = 3.04392;
    end
    
    
    methods (Access = private)

        %%Process the image to show
        function improcess(app)
            background_path = "";
            foreground_path = "";
            %helpdlg(string(app.BackgroundButton.Value));
            switch app.photosel 
                case "Example"
                    background_path = app.example_background_path;
                    foreground_path = app.example_foreground_path;
                case "Optional"
                    background_path = app.optional_background_path;
                    foreground_path = app.optional_foreground_path;
                case "Optional1"
                    background_path = app.optional_1_background_path;
                    foreground_path = app.optional_1_foreground_path;
            end
            background = imread(background_path);
            foreground = imread(foreground_path);
            [foreground_full, ~, alpha] = imread(foreground_path);
            %filter by A 
            forescope = foreground > 0;
            alpha = double(alpha ./ 255);
            image_size = size(background(:, :, 1));
            image_processed = zeros(image_size(1), image_size(2), 3); %#ok<PREALL> 
%             filter_size = ceil(log(image_size(1) .* image_size(2) .* app.S)...
%                 .^ 2.4 ./ 30);%can be change; function to cal the size of filter
            filter_size = ceil((log(sqrt(image_size(1) .* image_size(2) ./ 500 ./ 300) ./ 2 + 1)) .*(33 - app.A) ./ 2.4);
            if app.focussel == "Foreground"
                
                %filter the background
                background = imfilter(background, fspecial("average", filter_size), 'replicate');
                %cat the back and fore
                se = strel('disk',4);
                image_processed = background.*uint8(~forescope) + foreground;
                image_processed = imclose(image_processed,se);
            else 
                %filter the background
                foreground = imfilter(foreground_full, fspecial("average", filter_size), 'replicate');
                %cat the back and fore
                se = strel('disk',4);
                image_processed = background.*uint8(1 - alpha) + foreground .* uint8(alpha);
                image_processed = imclose(image_processed,se);
            end
            %deltaPIX
            deltap = deltaPIX(app);
            image_processed = image_processed + deltap;
            app.Image.ImageSource = image_processed;
            
        end

        %%calculate EV
        function results = EV(app)
            results = log2(100 .* (app.A .^ 2) / (app.ISO .* app.S));
        end

        %%calculate deltaPIX
        function results = deltaPIX(app)
            switch app.photosel
                case "Example"
                    results = 256 .* (app.default_EV_ex - EV(app)) ./ app.k;
                case "Optional"
                    results = 256 .* (app.default_EV_op - EV(app)) ./ app.k;
                case "Optional1"
                    results = 256 .* (app.default_EV_op_1 - EV(app)) ./ app.k;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app)
            DefaultChanged(app, 0);
        end

        % Selection changed function: PhotoButtonGroup
        function PhotoChanged(app, event)
            selectedButton = app.PhotoButtonGroup.SelectedObject;
            switch selectedButton
                case app.ExampleButton
                    app.photosel = "Example";
                    DefaultChanged(app, 0);
                case app.Optional0Button
                    app.photosel = "Optional";
                    DefaultChanged(app, 0);
                case app.Optional1Button
                    app.photosel = "Optional1";
                    DefaultChanged(app, 0);
            end

        end

        % Selection changed function: FocusButtonGroup
        function FocusChanged(app, event)
            selectedButton = app.FocusButtonGroup.SelectedObject;
            if selectedButton == app.ForegroundButton
                app.focussel = "Foreground";
                improcess(app);
            else
                app.focussel = "Background";
                improcess(app);
            end
        end

        % Value changed function: defaultButton
        function DefaultChanged(app, event)
            %value = app.defaultButton.Value;
            app.defaultButton.Value = false;
            switch app.photosel
                case "Example"
                    app.A = 1.8;
                    app.ISO = 1100;
                    app.S = 1 ./ 28;
                case "Optional"
                    app.A = 1.8;
                    app.ISO = 125;
                    app.S = 1 ./ 100;     
                case "Optional1"
                    app.A = 1.8;
                    app.ISO = 1100;
                    app.S = 1 ./ 28;
            end
            app.focussel = "Foreground";
            app.ForegroundButton.Value = true;
            app.ISOSlider.Value = app.ISO;
            app.ASlider.Value = app.A;
            app.SSlider.Value = app.S;
            app.EVSlider.Value = EV(app);
            app.EVLabel.Text = string(vpa(EV(app), 2));
            improcess(app);
            

        end

        % Value changing function: ISOSlider
        function ISOChanging(app, event)
            changingValue = event.Value;
            app.ISO = changingValue;
            %change the EV value
            app.EVSlider.Value = EV(app);
            app.EVLabel.Text = string(vpa(EV(app), 2));
            app.improcess();
        end

        % Value changing function: SSlider
        function SChanging(app, event)
            changingValue = event.Value;
            app.S = changingValue;
            %change the EV value
            app.EVSlider.Value = EV(app);
            app.EVLabel.Text = string(vpa(EV(app), 2));
            app.improcess();
        end

        % Value changing function: ASlider
        function AChanging(app, event)
            changingValue = event.Value;
            app.A = changingValue;
            %change the EV value
            app.EVSlider.Value = EV(app);
            app.EVLabel.Text = string(vpa(EV(app), 2));
            app.improcess();
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
            app.ISOSliderLabel.Position = [13 281 26 22];
            app.ISOSliderLabel.Text = 'ISO';

            % Create ISOSlider
            app.ISOSlider = uislider(app.LeftPanel);
            app.ISOSlider.Limits = [100 6400];
            app.ISOSlider.ValueChangingFcn = createCallbackFcn(app, @ISOChanging, true);
            app.ISOSlider.Position = [50 290 172 3];
            app.ISOSlider.Value = 100;

            % Create ASliderLabel
            app.ASliderLabel = uilabel(app.LeftPanel);
            app.ASliderLabel.HorizontalAlignment = 'center';
            app.ASliderLabel.Position = [13 219 25 22];
            app.ASliderLabel.Text = 'A';

            % Create ASlider
            app.ASlider = uislider(app.LeftPanel);
            app.ASlider.Limits = [1.8 32];
            app.ASlider.ValueChangingFcn = createCallbackFcn(app, @AChanging, true);
            app.ASlider.Position = [50 228 172 3];
            app.ASlider.Value = 1.8;

            % Create FocusButtonGroup
            app.FocusButtonGroup = uibuttongroup(app.LeftPanel);
            app.FocusButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @FocusChanged, true);
            app.FocusButtonGroup.TitlePosition = 'centertop';
            app.FocusButtonGroup.Title = 'Focus';
            app.FocusButtonGroup.Position = [33 397 184 49];

            % Create ForegroundButton
            app.ForegroundButton = uiradiobutton(app.FocusButtonGroup);
            app.ForegroundButton.Text = 'Foreground';
            app.ForegroundButton.Position = [11 3 84 22];
            app.ForegroundButton.Value = true;

            % Create BackgroundButton
            app.BackgroundButton = uiradiobutton(app.FocusButtonGroup);
            app.BackgroundButton.Text = 'Background';
            app.BackgroundButton.Position = [94 3 86 22];

            % Create SSliderLabel
            app.SSliderLabel = uilabel(app.LeftPanel);
            app.SSliderLabel.HorizontalAlignment = 'center';
            app.SSliderLabel.Position = [15 343 25 22];
            app.SSliderLabel.Text = 'S';

            % Create SSlider
            app.SSlider = uislider(app.LeftPanel);
            app.SSlider.Limits = [0.00048828125 2];
            app.SSlider.MajorTicks = [0.00048828125 0.40048828125 0.80048828125 1.20048828125 1.60048828125 2];
            app.SSlider.MajorTickLabels = {'1/2048', '0.4', '0.8', '1.2', '1.6', '2'};
            app.SSlider.ValueChangingFcn = createCallbackFcn(app, @SChanging, true);
            app.SSlider.Position = [52 352 171 3];
            app.SSlider.Value = 0.00048828125;

            % Create defaultButton
            app.defaultButton = uibutton(app.LeftPanel, 'state');
            app.defaultButton.ValueChangedFcn = createCallbackFcn(app, @DefaultChanged, true);
            app.defaultButton.Text = 'default';
            app.defaultButton.Position = [73 65 100 22];

            % Create EVSliderLabel
            app.EVSliderLabel = uilabel(app.LeftPanel);
            app.EVSliderLabel.HorizontalAlignment = 'center';
            app.EVSliderLabel.FontSize = 16;
            app.EVSliderLabel.Position = [44 152 34 22];
            app.EVSliderLabel.Text = 'EV';

            % Create EVSlider
            app.EVSlider = uislider(app.LeftPanel);
            app.EVSlider.Limits = [-21 21];
            app.EVSlider.Enable = 'off';
            app.EVSlider.Position = [29 141 191 3];

            % Create EVLabel
            app.EVLabel = uilabel(app.LeftPanel);
            app.EVLabel.FontSize = 14;
            app.EVLabel.Position = [172 152 32 22];
            app.EVLabel.Text = '3.04';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create Image
            app.Image = uiimage(app.RightPanel);
            app.Image.Position = [49 125 300 273];

            % Create PhotoButtonGroup
            app.PhotoButtonGroup = uibuttongroup(app.RightPanel);
            app.PhotoButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @PhotoChanged, true);
            app.PhotoButtonGroup.TitlePosition = 'centertop';
            app.PhotoButtonGroup.Title = 'Photo';
            app.PhotoButtonGroup.Position = [81 52 235 48];

            % Create ExampleButton
            app.ExampleButton = uiradiobutton(app.PhotoButtonGroup);
            app.ExampleButton.Text = 'Example';
            app.ExampleButton.Position = [11 2 69 22];
            app.ExampleButton.Value = true;

            % Create Optional0Button
            app.Optional0Button = uiradiobutton(app.PhotoButtonGroup);
            app.Optional0Button.Text = 'Optional0';
            app.Optional0Button.Position = [81 2 74 22];

            % Create Optional1Button
            app.Optional1Button = uiradiobutton(app.PhotoButtonGroup);
            app.Optional1Button.Text = 'Optional1';
            app.Optional1Button.Position = [155 2 74 22];

            % Create RealtimeCameraSimulatorLabel
            app.RealtimeCameraSimulatorLabel = uilabel(app.RightPanel);
            app.RealtimeCameraSimulatorLabel.HorizontalAlignment = 'center';
            app.RealtimeCameraSimulatorLabel.FontName = 'Arial Black';
            app.RealtimeCameraSimulatorLabel.FontSize = 20;
            app.RealtimeCameraSimulatorLabel.Position = [44 409 310 53];
            app.RealtimeCameraSimulatorLabel.Text = 'Realtime Camera Simulator';

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

            % Execute the startup function
            runStartupFcn(app, @StartupFcn)

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