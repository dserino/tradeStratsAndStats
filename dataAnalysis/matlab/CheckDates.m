function CheckDates(data,symbols)
  NN = length(data{1}(:,1));
  for k = 1:length(symbols)
    if length(data{k}(:,1)) ~= NN
      symbols{k}
      length(data{k}(:,1))
      error('some dates are skipped')
    end
  end
end