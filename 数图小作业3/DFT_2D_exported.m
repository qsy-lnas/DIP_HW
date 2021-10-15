classdef DFT_2D_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        TabGroup                    matlab.ui.container.TabGroup
        DeltaTab                    matlab.ui.container.Tab
        Slider_y                    matlab.ui.control.Slider
        Position_yLabel             matlab.ui.control.Label
        Slider_x                    matlab.ui.control.Slider
        Position_xLabel             matlab.ui.control.Label
        SineTab                     matlab.ui.container.Tab
        PhaseSlider                 matlab.ui.control.Slider
        PhaseSliderLabel            matlab.ui.control.Label
        FrequencySlider             matlab.ui.control.Slider
        FrequencySliderLabel        matlab.ui.control.Label
        AngleSlider                 matlab.ui.control.Slider
        AngleSliderLabel            matlab.ui.control.Label
        RectangleTab                matlab.ui.container.Tab
        HeightSlider                matlab.ui.control.Slider
        HeightSliderLabel           matlab.ui.control.Label
        LengthSlider                matlab.ui.control.Slider
        LengthSliderLabel           matlab.ui.control.Label
        Center_ySlider              matlab.ui.control.Slider
        Center_ySliderLabel         matlab.ui.control.Label
        Center_xSlider              matlab.ui.control.Slider
        Center_xSliderLabel         matlab.ui.control.Label
        AngleSlider_rec             matlab.ui.control.Slider
        AngleSlider_recLabel        matlab.ui.control.Label
        GaussTab                    matlab.ui.container.Tab
        VarianceSlider              matlab.ui.control.Slider
        VarianceSliderLabel         matlab.ui.control.Label
        GaborTab                    matlab.ui.container.Tab
        Variance_GaborSlider        matlab.ui.control.Slider
        Variance_GaborSliderLabel   matlab.ui.control.Label
        Phase_GaborSlider           matlab.ui.control.Slider
        Phase_GaborSliderLabel      matlab.ui.control.Label
        Frequency_GaborSlider       matlab.ui.control.Slider
        Frequency_GaborSliderLabel  matlab.ui.control.Label
        Angle_GaborSlider           matlab.ui.control.Slider
        Angle_GaborSliderLabel      matlab.ui.control.Label
        RightPanel                  matlab.ui.container.Panel
        ApproximateButton           matlab.ui.control.StateButton
        Data_enhanceButton          matlab.ui.control.StateButton
        myDFTButton                 matlab.ui.control.StateButton
        AmplitudeFigureLabel        matlab.ui.control.Label
        PhaseFigureLabel            matlab.ui.control.Label
        OriginFigureLabel           matlab.ui.control.Label
        Image_phase_2               matlab.ui.control.Image
        Image_ampli_2               matlab.ui.control.Image
        Image_origin_2              matlab.ui.control.Image
        Axes_phase                  matlab.ui.control.UIAxes
        Axes_ampli                  matlab.ui.control.UIAxes
        Axes_origin                 matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        Wavetype;
        Origin_fig_2;
        Amplitude_fig_2;
        Phase_fig_2;
        % parameter of Delta function
        position_x;
        position_y;
        % parameter of Sine function
        angle_sin;
        frequency;
        phase;
        % parameter of Rectangle function
        center_x;
        center_y;
        length;
        width;
        angle_rec;
        % parameter of Gauss function
        variance
        % parmeter of Gabor function
        angle_gabor;
        phase_gabor;
        frequency_gabor;
        variance_gabor;
    end
    
    methods (Access = private)
        %% generate origin figure 
        function Wave_generate(app)
            fig = zeros(256, 256);
            [X, Y] = meshgrid(1: 256);
            switch app.Wavetype
                case "Delta"
                    fig(257 - app.position_y, app.position_x) = 1;
                case "Sine"
                    an = app.angle_sin .* pi ./ 180;
                    ph = app.phase .* pi ./ 180;
                    fig = cos(2 .* pi .* app.frequency .* (cos(an) .* X + sin(an) .* Y) + ph);
                case "Rectangle"
                    % have to edit the logic of rotate
                    y_min = ceil(app.center_x - app.length ./ 2);
                    y_max = ceil(app.center_x + app.length ./ 2);
                    x_min = ceil(app.center_y - app.width ./ 2);
                    x_max = ceil(app.center_y + app.width ./ 2);
                    x_min = app.mapping1_256(x_min);
                    x_max = app.mapping1_256(x_max);
                    y_min = app.mapping1_256(y_min);
                    y_max = app.mapping1_256(y_max);
                    fig(x_min : x_max, y_min: y_max) = 1;
                    fig = imrotate(fig, app.angle_rec, "bilinear", "crop");
                case "Gauss"
                    fig = (X - 128.5) .^ 2 + (Y - 128.5) .^ 2;
                    fig = exp(- fig ./ (2 .* app.variance)) ./ (2 .* pi .* app.variance);
                case "Gabor"
                    an = app.angle_gabor .* pi ./ 180;
                    ph = app.phase_gabor .* pi ./ 180;
                    x_an =  (X - 128.5) .* cos(an) + (Y - 128.5) .* sin(an);
                    y_an = -(X - 128.5) .* sin(an) + (Y - 128.5) .* cos(an);
                    fig = ...
                    exp(-0.5 .* (x_an .^ 2 ./ app.variance_gabor + y_an .^ 2 ./ app.variance_gabor)) ...
                    .* cos(2 .* pi .* app.frequency_gabor .* x_an + ph);
            end
            app.Origin_fig_2 = fig;
        end
        
        %% generate the DFT figure
        function Ffigure = DFT_2(~, figure)
            [M, N] = size(figure);
            ux = (0 : M - 1)' * (0 : M - 1);
            vy = (0 : N - 1)' * (0 : N - 1);
            eMUX = exp(-2 * pi * 1i / M) .^ ux;
            eNVY = exp(-2 * pi * 1i / N) .^ vy;
            figure = figure + 0i;
            Ffigure = eMUX * figure * eNVY;
        end
        
        %% show the 3D surf
        function show_3D(app)
            step = 6;% to present better
            [X, Y] = meshgrid(1 : 256, 1 : 256);
            [X_step, Y_step] = meshgrid(1: step: 256, 1 : step : 256);
            switch app.Wavetype
                case "Delta"
                    surf(app.Axes_origin, X, Y, app.Origin_fig_2);
                    surf(app.Axes_ampli, X_step, Y_step, app.Amplitude_fig_2(1 : step : 256, 1 : step : 256));
                    surf(app.Axes_phase, X_step, Y_step, app.Phase_fig_2(1 : step : 256, 1 : step : 256));
                case {"Sine", "Rectangle", "Gauss", "Gabor"}
                    surf(app.Axes_origin, X_step, Y_step, ...
                        app.Origin_fig_2(1 : step : 256, 1 : step : 256));
                    surf(app.Axes_ampli, X_step, Y_step, ...
                        app.Amplitude_fig_2(1 : step : 256, 1 : step : 256));
                    surf(app.Axes_phase, X_step, Y_step, ...
                        app.Phase_fig_2(1 : step : 256, 1 : step : 256));
            end
        end
        
        %function to show the 6 figure
        function fig_show(app)
            app.Wave_generate();
            if app.myDFTButton.Text == "myDFT"
                DFT_origin = app.DFT_shift(app.DFT_2(app.Origin_fig_2));
            elseif app.myDFTButton.Text == "stdFFT"
                DFT_origin = fftshift(fft2(double(app.Origin_fig_2)));
            end
            app.Amplitude_fig_2 = abs(DFT_origin);
            if app.Data_enhanceButton.Value == true
                app.Amplitude_fig_2 = log(app.Amplitude_fig_2 + 1);
            end
            if app.ApproximateButton.Value == true
                app.Amplitude_fig_2 = round(app.Amplitude_fig_2, 2);
            end
            app.Phase_fig_2 = angle(DFT_origin);
            app.Image_origin_2.ImageSource = cat(3, app.Origin_fig_2, app.Origin_fig_2, app.Origin_fig_2); 
            app.Image_ampli_2.ImageSource = cat(3, app.Amplitude_fig_2, app.Amplitude_fig_2, app.Amplitude_fig_2);
            app.Image_phase_2.ImageSource = cat(3, app.Phase_fig_2, app.Phase_fig_2, app.Phase_fig_2); 
            app.show_3D();
        end
        
        %% tool function
        %function to mapping number
        function result = mapping1_256(app, x) %#ok<INUSL> 
            if x < 1
                x = 1;
            elseif x > 256
                x = 256;
            end
            result = x;
        end
        %function to shift the DFT figure
        function Shiftresult = DFT_shift(~, figure2shift)
            Shiftresult = zeros(256, 256);
            Shiftresult (1:128, 1:128) = figure2shift(129:256, 129:256);
            Shiftresult (129:256, 129:256) = figure2shift(1:128, 1:128);
            Shiftresult (1:128, 129:256) = figure2shift(129:256, 1:128);
            Shiftresult (129:256, 1:128) = figure2shift(1:128, 129:256);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app)
            app.DeltaSelected(0);
            %app.Axes_origin.TickLabelFormat = "%.2f";
        end

        % Button down function: DeltaTab
        function DeltaSelected(app, event)
            app.Wavetype = "Delta";
            app.Slider_x.Value = 128;
            app.Slider_y.Value = 128;
            app.position_x = 128;
            app.position_y = 128;
            app.fig_show();
        end

        % Button down function: SineTab
        function SineSelected(app, event)
            app.Wavetype = "Sine";
            app.AngleSlider.Value = 0;
            app.PhaseSlider.Value = 0;
            app.FrequencySlider.Value = 0.01;
            app.angle_sin = 0;
            app.phase = 0;
            app.frequency = 0.01;
            app.fig_show();
        end

        % Button down function: GaussTab
        function GaussSelected(app, event)
            app.Wavetype = "Gauss";
            app.variance = 1;
            app.VarianceSlider.Value = 1;
            app.fig_show();
        end

        % Button down function: RectangleTab
        function RectangleSelected(app, event)
            app.Wavetype = "Rectangle";
            app.Center_xSlider.Value = 128;
            app.Center_ySlider.Value = 128;
            app.AngleSlider_rec.Value = 0;
            app.HeightSlider.Value = 32;
            app.LengthSlider.Value = 64;
            app.center_x = 128;
            app.center_y = 128;
            app.angle_rec = 0;
            app.width = 32;
            app.length = 64;
            app.fig_show();
        end

        % Button down function: GaborTab
        function GaborSelected(app, event)
            app.Wavetype = "Gabor";
            app.angle_gabor = 0;
            app.Angle_GaborSlider.Value = 0;
            app.frequency_gabor = 0.01;
            app.Frequency_GaborSlider.Value = 0.01;
            app.phase_gabor = 0;
            app.Phase_GaborSlider.Value = 0;
            app.variance_gabor = 1;
            app.Variance_GaborSlider.Value = 1;
            app.fig_show();
        end

        % Value changing function: Slider_x
        function Position_x_Changing(app, event)
            changingValue = event.Value;
            app.position_x = round(changingValue);
            app.fig_show();
        end

        % Value changed function: Slider_x
        function Position_x_Changed(app, event)
            value = app.Slider_x.Value;
            app.position_x = round(value);
            app.fig_show();
        end

        % Value changing function: Slider_y
        function Position_y_Changing(app, event)
            changingValue = event.Value;
            app.position_y = round(changingValue);
            app.fig_show();
        end

        % Value changed function: Slider_y
        function Position_y_Changed(app, event)
            value = app.Slider_y.Value;
            app.position_y = round(value);
            app.fig_show();
        end

        % Value changed function: FrequencySlider
        function Frequency_Changed(app, event)
            value = app.FrequencySlider.Value;
            app.frequency = value;
            app.fig_show();
        end

        % Value changing function: FrequencySlider
        function Frequency_Changing(app, event)
            changingValue = event.Value;
            app.frequency = changingValue;
            app.fig_show();
        end

        % Value changed function: AngleSlider
        function Angle_Changed(app, event)
            value = app.AngleSlider.Value;
            app.angle_sin = value;
            app.fig_show();
        end

        % Value changing function: AngleSlider
        function Angle_Changing(app, event)
            changingValue = event.Value;
            app.angle_sin = changingValue;
            app.fig_show();
        end

        % Value changed function: PhaseSlider
        function Phase_Changed(app, event)
            value = app.PhaseSlider.Value;
            app.phase = value;
            app.fig_show();
        end

        % Value changing function: PhaseSlider
        function Phase_Changing(app, event)
            changingValue = event.Value;
            app.phase = changingValue;
            app.fig_show();
        end

        % Value changed function: AngleSlider_rec
        function Angle_rec_Changed(app, event)
            value = app.AngleSlider_rec.Value;
            app.angle_rec = value;
            app.fig_show();
        end

        % Value changing function: AngleSlider_rec
        function Angle_rec_Changing(app, event)
            changingValue = event.Value;
            app.angle_rec = changingValue;
            app.fig_show();
        end

        % Value changed function: Center_xSlider
        function Center_x_Changed(app, event)
            value = app.Center_xSlider.Value;
            app.center_x = value;
            app.fig_show();
        end

        % Value changing function: Center_xSlider
        function Center_x_Changing(app, event)
            changingValue = event.Value;
            app.center_x = changingValue;
            app.fig_show();
        end

        % Value changed function: Center_ySlider
        function Center_y_Changed(app, event)
            value = app.Center_ySlider.Value;
            app.center_y = value;
            app.fig_show();
        end

        % Value changing function: Center_ySlider
        function Center_y_Changing(app, event)
            changingValue = event.Value;
            app.center_y = changingValue;
            app.fig_show();
        end

        % Value changed function: LengthSlider
        function Length_Changed(app, event)
            value = app.LengthSlider.Value;
            app.length = value;
            app.fig_show();
        end

        % Value changing function: LengthSlider
        function Length_Changing(app, event)
            changingValue = event.Value;
            app.length = changingValue;
            app.fig_show();
        end

        % Value changed function: HeightSlider
        function Width_Changed(app, event)
            value = app.HeightSlider.Value;
            app.width = value;
            app.fig_show();
        end

        % Value changing function: HeightSlider
        function Width_Changing(app, event)
            changingValue = event.Value;
            app.width = changingValue;
            app.fig_show();
        end

        % Value changed function: VarianceSlider
        function Variance_Changed(app, event)
            value = app.VarianceSlider.Value;
            app.variance = value;
            app.fig_show();
        end

        % Value changing function: VarianceSlider
        function Variance_Changing(app, event)
            changingValue = event.Value;
            app.variance = changingValue;
            app.fig_show();
        end

        % Value changed function: Angle_GaborSlider
        function Angle_Gabor_Changed(app, event)
            value = app.Angle_GaborSlider.Value;
            app.angle_gabor = value;
            app.fig_show();
        end

        % Value changing function: Angle_GaborSlider
        function Angle_Gabor_Changing(app, event)
            changingValue = event.Value;
            app.angle_gabor = changingValue;
            app.fig_show();
        end

        % Value changed function: Frequency_GaborSlider
        function Frequency_Gabor_Changed(app, event)
            value = app.Frequency_GaborSlider.Value;
            app.frequency_gabor = value;
            app.fig_show();
        end

        % Value changing function: Frequency_GaborSlider
        function Frequency_Gabor_Changing(app, event)
            changingValue = event.Value;
            app.frequency_gabor = changingValue;
            app.fig_show();
        end

        % Value changed function: Phase_GaborSlider
        function Phase_Gabor_Changed(app, event)
            value = app.Phase_GaborSlider.Value;
            app.phase_gabor = value;
            app.fig_show();
        end

        % Value changing function: Phase_GaborSlider
        function Phase_Gabor_Changing(app, event)
            changingValue = event.Value;
            app.phase_gabor = changingValue;
            app.fig_show();
        end

        % Value changed function: Variance_GaborSlider
        function Variance_Gabor_Changed(app, event)
            value = app.Variance_GaborSlider.Value;
            app.variance_gabor = value;
            app.fig_show();
        end

        % Value changing function: Variance_GaborSlider
        function Variance_Gabor_Changing(app, event)
            changingValue = event.Value;
            app.variance_gabor = changingValue;
            app.fig_show();
        end

        % Value changed function: myDFTButton
        function DFT_Changed(app, event)
            value = app.myDFTButton.Value;
            if value == true
                app.myDFTButton.Text = "stdFFT";
            elseif value == false
                app.myDFTButton.Text = "myDFT";
            end
            app.fig_show();
        end

        % Value changed function: Data_enhanceButton
        function Data_Changed(app, event)
            %value = app.Data_enhanceButton.Value;
            app.fig_show();
        end

        % Value changed function: ApproximateButton
        function Approximate_Changed(app, event)
            %value = app.ApproximateButton.Value;
            app.fig_show();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {460, 460};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {240, '1x'};
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
            app.UIFigure.Position = [100 100 770 460];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {240, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.Position = [6 6 228 448];

            % Create DeltaTab
            app.DeltaTab = uitab(app.TabGroup);
            app.DeltaTab.Title = 'Delta';
            app.DeltaTab.ButtonDownFcn = createCallbackFcn(app, @DeltaSelected, true);

            % Create Position_xLabel
            app.Position_xLabel = uilabel(app.DeltaTab);
            app.Position_xLabel.Tag = 'PositionGroup';
            app.Position_xLabel.HorizontalAlignment = 'center';
            app.Position_xLabel.Position = [82 211 61 22];
            app.Position_xLabel.Text = 'Position_x';

            % Create Slider_x
            app.Slider_x = uislider(app.DeltaTab);
            app.Slider_x.Limits = [1 256];
            app.Slider_x.MajorTicks = [1 64 128 192 256];
            app.Slider_x.ValueChangedFcn = createCallbackFcn(app, @Position_x_Changed, true);
            app.Slider_x.ValueChangingFcn = createCallbackFcn(app, @Position_x_Changing, true);
            app.Slider_x.MinorTicks = [];
            app.Slider_x.Tag = 'PositionGroup';
            app.Slider_x.Position = [89 266 99 3];
            app.Slider_x.Value = 128;

            % Create Position_yLabel
            app.Position_yLabel = uilabel(app.DeltaTab);
            app.Position_yLabel.Tag = 'PositionGroup';
            app.Position_yLabel.HorizontalAlignment = 'center';
            app.Position_yLabel.Position = [82 179 61 22];
            app.Position_yLabel.Text = 'Position_y';

            % Create Slider_y
            app.Slider_y = uislider(app.DeltaTab);
            app.Slider_y.Limits = [1 256];
            app.Slider_y.MajorTicks = [1 64 128 192 256];
            app.Slider_y.Orientation = 'vertical';
            app.Slider_y.ValueChangedFcn = createCallbackFcn(app, @Position_y_Changed, true);
            app.Slider_y.ValueChangingFcn = createCallbackFcn(app, @Position_y_Changing, true);
            app.Slider_y.MinorTicks = [];
            app.Slider_y.Tag = 'PositionGroup';
            app.Slider_y.Position = [40 176 3 93];
            app.Slider_y.Value = 128;

            % Create SineTab
            app.SineTab = uitab(app.TabGroup);
            app.SineTab.Title = 'Sine';
            app.SineTab.ButtonDownFcn = createCallbackFcn(app, @SineSelected, true);

            % Create AngleSliderLabel
            app.AngleSliderLabel = uilabel(app.SineTab);
            app.AngleSliderLabel.HorizontalAlignment = 'center';
            app.AngleSliderLabel.Position = [5 327 36 22];
            app.AngleSliderLabel.Text = 'Angle';

            % Create AngleSlider
            app.AngleSlider = uislider(app.SineTab);
            app.AngleSlider.Limits = [0 180];
            app.AngleSlider.ValueChangedFcn = createCallbackFcn(app, @Angle_Changed, true);
            app.AngleSlider.ValueChangingFcn = createCallbackFcn(app, @Angle_Changing, true);
            app.AngleSlider.Position = [62 336 150 3];

            % Create FrequencySliderLabel
            app.FrequencySliderLabel = uilabel(app.SineTab);
            app.FrequencySliderLabel.HorizontalAlignment = 'right';
            app.FrequencySliderLabel.Position = [0 262 62 22];
            app.FrequencySliderLabel.Text = 'Frequency';

            % Create FrequencySlider
            app.FrequencySlider = uislider(app.SineTab);
            app.FrequencySlider.Limits = [0.002 0.2];
            app.FrequencySlider.MajorTicks = [0.002 0.1 0.2];
            app.FrequencySlider.ValueChangedFcn = createCallbackFcn(app, @Frequency_Changed, true);
            app.FrequencySlider.ValueChangingFcn = createCallbackFcn(app, @Frequency_Changing, true);
            app.FrequencySlider.Position = [83 271 135 3];
            app.FrequencySlider.Value = 0.01;

            % Create PhaseSliderLabel
            app.PhaseSliderLabel = uilabel(app.SineTab);
            app.PhaseSliderLabel.HorizontalAlignment = 'right';
            app.PhaseSliderLabel.Position = [3 200 40 22];
            app.PhaseSliderLabel.Text = 'Phase';

            % Create PhaseSlider
            app.PhaseSlider = uislider(app.SineTab);
            app.PhaseSlider.Limits = [0 360];
            app.PhaseSlider.ValueChangedFcn = createCallbackFcn(app, @Phase_Changed, true);
            app.PhaseSlider.ValueChangingFcn = createCallbackFcn(app, @Phase_Changing, true);
            app.PhaseSlider.Position = [64 209 150 3];

            % Create RectangleTab
            app.RectangleTab = uitab(app.TabGroup);
            app.RectangleTab.Title = 'Rectangle';
            app.RectangleTab.ButtonDownFcn = createCallbackFcn(app, @RectangleSelected, true);

            % Create AngleSlider_recLabel
            app.AngleSlider_recLabel = uilabel(app.RectangleTab);
            app.AngleSlider_recLabel.HorizontalAlignment = 'right';
            app.AngleSlider_recLabel.Position = [9 328 36 22];
            app.AngleSlider_recLabel.Text = 'Angle';

            % Create AngleSlider_rec
            app.AngleSlider_rec = uislider(app.RectangleTab);
            app.AngleSlider_rec.Limits = [0 180];
            app.AngleSlider_rec.ValueChangedFcn = createCallbackFcn(app, @Angle_rec_Changed, true);
            app.AngleSlider_rec.ValueChangingFcn = createCallbackFcn(app, @Angle_rec_Changing, true);
            app.AngleSlider_rec.Position = [66 337 150 3];

            % Create Center_xSliderLabel
            app.Center_xSliderLabel = uilabel(app.RectangleTab);
            app.Center_xSliderLabel.HorizontalAlignment = 'right';
            app.Center_xSliderLabel.Position = [4 272 54 22];
            app.Center_xSliderLabel.Text = 'Center_x';

            % Create Center_xSlider
            app.Center_xSlider = uislider(app.RectangleTab);
            app.Center_xSlider.Limits = [1 256];
            app.Center_xSlider.MajorTicks = [1 64 128 192 256];
            app.Center_xSlider.ValueChangedFcn = createCallbackFcn(app, @Center_x_Changed, true);
            app.Center_xSlider.ValueChangingFcn = createCallbackFcn(app, @Center_x_Changing, true);
            app.Center_xSlider.Position = [66 281 150 3];
            app.Center_xSlider.Value = 128;

            % Create Center_ySliderLabel
            app.Center_ySliderLabel = uilabel(app.RectangleTab);
            app.Center_ySliderLabel.HorizontalAlignment = 'right';
            app.Center_ySliderLabel.Position = [0 210 54 22];
            app.Center_ySliderLabel.Text = 'Center_y';

            % Create Center_ySlider
            app.Center_ySlider = uislider(app.RectangleTab);
            app.Center_ySlider.Limits = [1 256];
            app.Center_ySlider.MajorTicks = [1 64 128 192 256];
            app.Center_ySlider.ValueChangedFcn = createCallbackFcn(app, @Center_y_Changed, true);
            app.Center_ySlider.ValueChangingFcn = createCallbackFcn(app, @Center_y_Changing, true);
            app.Center_ySlider.Position = [66 220 150 3];
            app.Center_ySlider.Value = 128;

            % Create LengthSliderLabel
            app.LengthSliderLabel = uilabel(app.RectangleTab);
            app.LengthSliderLabel.HorizontalAlignment = 'right';
            app.LengthSliderLabel.Position = [1 148 42 22];
            app.LengthSliderLabel.Text = 'Length';

            % Create LengthSlider
            app.LengthSlider = uislider(app.RectangleTab);
            app.LengthSlider.Limits = [1 256];
            app.LengthSlider.MajorTicks = [1 64 128 192 256];
            app.LengthSlider.ValueChangedFcn = createCallbackFcn(app, @Length_Changed, true);
            app.LengthSlider.ValueChangingFcn = createCallbackFcn(app, @Length_Changing, true);
            app.LengthSlider.Position = [64 157 150 3];
            app.LengthSlider.Value = 64;

            % Create HeightSliderLabel
            app.HeightSliderLabel = uilabel(app.RectangleTab);
            app.HeightSliderLabel.HorizontalAlignment = 'right';
            app.HeightSliderLabel.Position = [5 82 40 22];
            app.HeightSliderLabel.Text = 'Height';

            % Create HeightSlider
            app.HeightSlider = uislider(app.RectangleTab);
            app.HeightSlider.Limits = [1 256];
            app.HeightSlider.MajorTicks = [1 64 128 192 256];
            app.HeightSlider.ValueChangedFcn = createCallbackFcn(app, @Width_Changed, true);
            app.HeightSlider.ValueChangingFcn = createCallbackFcn(app, @Width_Changing, true);
            app.HeightSlider.Position = [66 91 150 3];
            app.HeightSlider.Value = 32;

            % Create GaussTab
            app.GaussTab = uitab(app.TabGroup);
            app.GaussTab.Title = 'Gauss';
            app.GaussTab.ButtonDownFcn = createCallbackFcn(app, @GaussSelected, true);

            % Create VarianceSliderLabel
            app.VarianceSliderLabel = uilabel(app.GaussTab);
            app.VarianceSliderLabel.HorizontalAlignment = 'right';
            app.VarianceSliderLabel.Position = [3 316 52 22];
            app.VarianceSliderLabel.Text = 'Variance';

            % Create VarianceSlider
            app.VarianceSlider = uislider(app.GaussTab);
            app.VarianceSlider.MajorTicks = [1 20 40 60 80 100];
            app.VarianceSlider.ValueChangedFcn = createCallbackFcn(app, @Variance_Changed, true);
            app.VarianceSlider.ValueChangingFcn = createCallbackFcn(app, @Variance_Changing, true);
            app.VarianceSlider.Position = [63 326 150 3];
            app.VarianceSlider.Value = 100;

            % Create GaborTab
            app.GaborTab = uitab(app.TabGroup);
            app.GaborTab.Title = 'Gabor';
            app.GaborTab.ButtonDownFcn = createCallbackFcn(app, @GaborSelected, true);

            % Create Angle_GaborSliderLabel
            app.Angle_GaborSliderLabel = uilabel(app.GaborTab);
            app.Angle_GaborSliderLabel.HorizontalAlignment = 'right';
            app.Angle_GaborSliderLabel.FontSize = 14;
            app.Angle_GaborSliderLabel.Position = [52 366 100 40];
            app.Angle_GaborSliderLabel.Text = 'Angle_Gabor';

            % Create Angle_GaborSlider
            app.Angle_GaborSlider = uislider(app.GaborTab);
            app.Angle_GaborSlider.Limits = [0 180];
            app.Angle_GaborSlider.MajorTicks = [0 60 120 180];
            app.Angle_GaborSlider.ValueChangedFcn = createCallbackFcn(app, @Angle_Gabor_Changed, true);
            app.Angle_GaborSlider.ValueChangingFcn = createCallbackFcn(app, @Angle_Gabor_Changing, true);
            app.Angle_GaborSlider.FontSize = 14;
            app.Angle_GaborSlider.Position = [9 366 203 3];

            % Create Frequency_GaborSliderLabel
            app.Frequency_GaborSliderLabel = uilabel(app.GaborTab);
            app.Frequency_GaborSliderLabel.HorizontalAlignment = 'right';
            app.Frequency_GaborSliderLabel.FontSize = 14;
            app.Frequency_GaborSliderLabel.Position = [56 307 118 22];
            app.Frequency_GaborSliderLabel.Text = 'Frequency_Gabor';

            % Create Frequency_GaborSlider
            app.Frequency_GaborSlider = uislider(app.GaborTab);
            app.Frequency_GaborSlider.Limits = [0.002 0.2];
            app.Frequency_GaborSlider.MajorTicks = [0.002 0.04 0.08 0.12 0.16 0.2];
            app.Frequency_GaborSlider.MajorTickLabels = {'0.002', '0.04', '0.08', '0.12', '0.16', '0.2'};
            app.Frequency_GaborSlider.ValueChangedFcn = createCallbackFcn(app, @Frequency_Gabor_Changed, true);
            app.Frequency_GaborSlider.ValueChangingFcn = createCallbackFcn(app, @Frequency_Gabor_Changing, true);
            app.Frequency_GaborSlider.MinorTicks = [];
            app.Frequency_GaborSlider.Position = [15 302 201 3];
            app.Frequency_GaborSlider.Value = 0.02;

            % Create Phase_GaborSliderLabel
            app.Phase_GaborSliderLabel = uilabel(app.GaborTab);
            app.Phase_GaborSliderLabel.HorizontalAlignment = 'right';
            app.Phase_GaborSliderLabel.FontSize = 14;
            app.Phase_GaborSliderLabel.Position = [66 237 92 22];
            app.Phase_GaborSliderLabel.Text = 'Phase_Gabor';

            % Create Phase_GaborSlider
            app.Phase_GaborSlider = uislider(app.GaborTab);
            app.Phase_GaborSlider.Limits = [0 360];
            app.Phase_GaborSlider.ValueChangedFcn = createCallbackFcn(app, @Phase_Gabor_Changed, true);
            app.Phase_GaborSlider.ValueChangingFcn = createCallbackFcn(app, @Phase_Gabor_Changing, true);
            app.Phase_GaborSlider.FontSize = 14;
            app.Phase_GaborSlider.Position = [9 235 205 3];

            % Create Variance_GaborSliderLabel
            app.Variance_GaborSliderLabel = uilabel(app.GaborTab);
            app.Variance_GaborSliderLabel.HorizontalAlignment = 'right';
            app.Variance_GaborSliderLabel.FontSize = 14;
            app.Variance_GaborSliderLabel.Position = [59 169 106 22];
            app.Variance_GaborSliderLabel.Text = 'Variance_Gabor';

            % Create Variance_GaborSlider
            app.Variance_GaborSlider = uislider(app.GaborTab);
            app.Variance_GaborSlider.Limits = [1 400];
            app.Variance_GaborSlider.MajorTicks = [1 100 200 300 400];
            app.Variance_GaborSlider.ValueChangedFcn = createCallbackFcn(app, @Variance_Gabor_Changed, true);
            app.Variance_GaborSlider.ValueChangingFcn = createCallbackFcn(app, @Variance_Gabor_Changing, true);
            app.Variance_GaborSlider.Position = [9 167 206 3];
            app.Variance_GaborSlider.Value = 100;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create Axes_origin
            app.Axes_origin = uiaxes(app.RightPanel);
            app.Axes_origin.Position = [10 60 160 160];

            % Create Axes_ampli
            app.Axes_ampli = uiaxes(app.RightPanel);
            app.Axes_ampli.Position = [180 60 160 160];

            % Create Axes_phase
            app.Axes_phase = uiaxes(app.RightPanel);
            app.Axes_phase.Position = [350 60 160 160];

            % Create Image_origin_2
            app.Image_origin_2 = uiimage(app.RightPanel);
            app.Image_origin_2.Position = [40 280 128 128];

            % Create Image_ampli_2
            app.Image_ampli_2 = uiimage(app.RightPanel);
            app.Image_ampli_2.Position = [200 280 128 128];

            % Create Image_phase_2
            app.Image_phase_2 = uiimage(app.RightPanel);
            app.Image_phase_2.Position = [360 280 128 128];

            % Create OriginFigureLabel
            app.OriginFigureLabel = uilabel(app.RightPanel);
            app.OriginFigureLabel.FontSize = 16;
            app.OriginFigureLabel.Position = [55 232 98 22];
            app.OriginFigureLabel.Text = 'Origin Figure';

            % Create PhaseFigureLabel
            app.PhaseFigureLabel = uilabel(app.RightPanel);
            app.PhaseFigureLabel.FontSize = 16;
            app.PhaseFigureLabel.Position = [374 232 100 22];
            app.PhaseFigureLabel.Text = 'Phase Figure';

            % Create AmplitudeFigureLabel
            app.AmplitudeFigureLabel = uilabel(app.RightPanel);
            app.AmplitudeFigureLabel.FontSize = 16;
            app.AmplitudeFigureLabel.Position = [201 232 126 22];
            app.AmplitudeFigureLabel.Text = 'Amplitude Figure';

            % Create myDFTButton
            app.myDFTButton = uibutton(app.RightPanel, 'state');
            app.myDFTButton.ValueChangedFcn = createCallbackFcn(app, @DFT_Changed, true);
            app.myDFTButton.Text = 'myDFT';
            app.myDFTButton.Position = [55 19 100 22];

            % Create Data_enhanceButton
            app.Data_enhanceButton = uibutton(app.RightPanel, 'state');
            app.Data_enhanceButton.ValueChangedFcn = createCallbackFcn(app, @Data_Changed, true);
            app.Data_enhanceButton.Text = 'Data_enhance';
            app.Data_enhanceButton.Position = [227 19 100 22];

            % Create ApproximateButton
            app.ApproximateButton = uibutton(app.RightPanel, 'state');
            app.ApproximateButton.ValueChangedFcn = createCallbackFcn(app, @Approximate_Changed, true);
            app.ApproximateButton.Text = 'Approximate';
            app.ApproximateButton.Position = [388 19 100 22];
            app.ApproximateButton.Value = true;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DFT_2D_exported

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