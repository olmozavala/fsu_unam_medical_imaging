function [eignResult]=ExampleEignBreast(imageMatPath)
    % Takes the 4D .mat image for the DCE MRI and plots the graphs
    % ExampleEignBreast('/Users/Shared/Breast/DCE-MRI/0232016_p12_too_small_not_visible.mat')

    global  EignR EignL EignT minValue maxValue Temp Slice;


    %% We Load the image. 
    load(imageMatPath);
    eignResult=eigenbreast(stack_all);
    %% Save Variables to workspace
    [pcaR, pcaL, pcaT]= eignResult.pca;
    [EignR, EignL, EignT] = eignResult.eign;
    
    maxValue = max([pcaR(:); pcaL(:); pcaT(:)]);
    minValue = min([pcaR(:); pcaL(:); pcaT(:)]);

    %% PLOT 1 
    figure
    subplot(1,3,1); plot(pcaR); title('Right Breast'); xlabel('Temporal Index');ylim([minValue maxValue])
    subplot(1,3,2); plot(pcaL); title('Left Breast'); xlabel('Temporal Index');ylim([minValue maxValue])
    subplot(1,3,3); plot(pcaT); title('Both Breasts'); xlabel('Temporal Index');ylim([minValue maxValue])

    %% PLOT 2
    Temp = 1;
    maxValue = max([max(EignR(Temp,:)); max(EignL(Temp,:)); max(EignT(Temp,:))]);
    minValue = min([max(EignR(Temp,:)); min(EignL(Temp,:)); min(EignT(Temp,:))]);
    nslides = size(EignR,4);
    Slice = 1;
    sliderStepSize = 1 / (nslides - 1);
    figure
    uicontrol(...
    'style','slider',...
    'units','normalized',...
    'Min',1,...
    'Max',nslides,...
    'Value',1,...
    'position',[0 0 1 .05],...
    'SliderStep',[sliderStepSize sliderStepSize],...
    'callback',@scroll_Callback);
    % Create pop-up menu with 4 options
    uicontrol(...
    'Style', 'popup',...
    'String', {'Shot 1','Shot 2','Shot 3','Shot 4'},...
    'Position', [20 340 100 50],...
    'Callback', @popmenu_Callback);    
    subplot(1,3,1); imshow(squeeze(EignR(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Right Breast');
    subplot(1,3,2); imshow(squeeze(EignL(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Left Breast');
    subplot(1,3,3); imshow(squeeze(EignT(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Both Breasts'); 
end

function scroll_Callback(src,~)
    global  EignR EignL EignT minValue maxValue Temp;
    Slice = round(get(src,'value'));
    subplot(1,3,1); imshow(squeeze(EignR(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Right Breast');
    subplot(1,3,2); imshow(squeeze(EignL(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Left Breast');
    subplot(1,3,3); imshow(squeeze(EignT(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Both Breasts'); 
end

function popmenu_Callback(source,~)
    global  EignR EignL EignT minValue maxValue Temp Slice;
    Temp = source.Value;
    maxValue = max([max(EignR(Temp,:)); max(EignL(Temp,:)); max(EignT(Temp,:))]);
    minValue = min([max(EignR(Temp,:)); min(EignL(Temp,:)); min(EignT(Temp,:))]);
    subplot(1,3,1); imshow(squeeze(EignR(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Right Breast');
    subplot(1,3,2); imshow(squeeze(EignL(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Left Breast');
    subplot(1,3,3); imshow(squeeze(EignT(Temp,:,:,Slice)),[minValue maxValue],'Colormap',colormap('jet')); title('Both Breasts');    
end