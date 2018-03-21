function action1(src,event)
% This callback toggles the visibility of the line

if strcmp(event.Peer.Visible,'on')   % If current line is visible
    event.Peer.Visible = 'off';      %   Set the visibility to 'off'
else                                 % Else
    event.Peer.Visible = 'on';       %   Set the visibility to 'on'
end

