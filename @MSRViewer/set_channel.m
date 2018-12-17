function set_channel(self, channel)
%SET_CHANNEL Assigns the current data in the preview to a channel
%
% Input args:
%   channel: number between 0 and 3. If 0, the next channel without data
%   is used, if 1<=channel<=3, the data is assigned to channel number
%   `channel`.


d = self.get_msr_plane();

if channel == 0
    channel = self.Ax.getNextEmptyChannel();
end

if isnan(channel) 
    return
end

self.Ax.(sprintf('C%g', channel)) = d;

