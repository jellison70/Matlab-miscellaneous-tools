function action3(src,event,hAx)
% This callback displays the selected line on a different set of axes

x = event.Peer.XData;                   % Get X data of interest
y = event.Peer.YData;                   % Get Y data of interest
plot(hAx,x,y,'Color',event.Peer.Color)  % Plot data with the same color
title(hAx,event.Peer.DisplayName)       % Set the title to the line name