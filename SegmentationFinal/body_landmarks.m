function [ PPrimaL, PPrimaR, PM] = body_landmarks( detectedEdes )
% Detected Edges are the EM edges that intersect the body fat mask
%% Get chest edge
% Get the boundaries of the mask
[B, L] = bwboundaries(detectedEdes,'noholes');
% get the outer most boundary
[~, OuterIndex]=max(cellfun(@numel,B));
OuterBoundary = B{OuterIndex};



%% Get Pl And Pr Points from outer edge
% I find this points as the extreme points of the 
% outer most detected edge
% PL And PR
[ply,plidx] = min(OuterBoundary(:,1));
plx = OuterBoundary(plidx,2);
[pry,pridx] = max(OuterBoundary(:,1));
prx = OuterBoundary(pridx,2);

%% find PM based on simetry of the chest area. 
% the Pm Point is in the middle of the chest
pmy = ceil((ply-pry)/2) + pry;
pmidx = OuterBoundary(:,1)==pmy;
pmx = OuterBoundary(pmidx,2);
pmx = max(pmx); % The area af the chest is probably flat so this array
               %may contain repeated elements, get the first one

lowLine = ceil(min([prx plx])+((max([prx plx])-min([prx plx]))/2));
PlrPx = ceil(min([lowLine pmx])+((max([lowLine pmx])-min([lowLine pmx]))/3));

ppidx = find(OuterBoundary(:,2)==PlrPx);
plpy = min(OuterBoundary(ppidx,1));
prpy = max(OuterBoundary(ppidx,1));

%%% Save Points 
PPrimaL = [PlrPx plpy];
PPrimaR = [PlrPx prpy];
PM = [pmx pmy];

% imshow(label2rgb(L,@jet,[.5,.5,.5]))
% hold on
% plot(OuterBoundary(:,2),OuterBoundary(:,1),'W', 'LineWidth',2);
% scatter([PPrimaL(1), PPrimaR(1), PM(1)],[PPrimaL(2), PPrimaR(2), PM(2)],'filled','G');
% title('Lateral-Posterior Breast Ends');
% hold off
% waitforbuttonpress


end

