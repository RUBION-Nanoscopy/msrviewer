function change_preview(self, val)
% CHANGE_PREVIEW Updates the preview according to `val`
% val should be one of 'first', 'last', 'next', 'prev', a positive number
% (same as 'next'), a negative number (same as 'prev'), +inf (same as
% 'last'), -inf (same as 'first')


% Here, the different indexing of matlab and java makes things slightly
% confusing. self.previewed_data assumes java indexing...


%First
if isequal(val, -Inf) || strcmpi(val, 'first')
    self.previewed_data = [0 0];
    return
end

% Last
if isequal(val, +Inf) || strcmpi(val, 'last')
    self.previewed_data = ...
        [...
            self.data_info.SeriesCount-1 ...
            self.data_info.SeriesPlanesCount(end)-1 ...
        ];
    return
end

series = self.previewed_data(1);
plane =  self.previewed_data(2);

% Next 
if val > 0 || strcmpi(val, 'next')
    if plane < self.data_info.SeriesPlanesCount(series + 1) - 1 % Matlab indexing. Read "series"
        self.previewed_data(2) = plane + 1;
    elseif series < self.data_info.SeriesCount-1
        self.previewed_data = [series + 1, 0];
    else
        self.previewed_data = [0 0];
    end
    return
end

% Prev
if val < 0 || strcmpi(val, 'next')
    if plane > 0
        self.previewed_data(2) = plane - 1;
    elseif series > 0
        self.previewed_data = ...
            [ ...
                series - 1, ...
                self.data_info.SeriesPlanesCount(series) - 1 ... % Matlab indexing. Read "series - 1" 
            ];
    else
        self.previewed_data = ...
            [ ...
                self.data_info.SeriesCount-1, ...
                self.data_info.SeriesPlanesCount(end) - 1 ...
            ];
    end
    return
end

error('MSRViewer:WrongArgument',...
    'I do not know how to handle the argument passed to change_preview.'); 
