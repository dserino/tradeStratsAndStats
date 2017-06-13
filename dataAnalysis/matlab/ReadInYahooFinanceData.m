function ReadInYahooFinanceData(dir,filename,SaveFile, ...
                                year0,month0,day0, ...
                                year1,month1,day1)
  fprintf('> Loading in symbols from %s \n',[dir,filename]);
  
  fid = fopen([dir,filename]);
  k = 1;
  while 1
    tline = fgetl(fid);
    if ~ischar(tline)
      break
    else
      if tline(1) ~= '#'
        symbols{k} = tline;
        k = k+1;
      end
    end
  end
  fclose(fid);

  Ns = length(symbols);
  data = cell(1,Ns);
  
  fprintf('> Read %d symbols \n',Ns);

  % t1 = datetime(year0,month0,day0);
  % t2 = datetime(year1,month1,day1);
  
  % day0_key = posixtime(t1);
  % day1_key = posixtime(t2);
  
  %% get data from yahoo finance
  %  (1),  (2),  (3), (4),   (5),    (6),       (7)
  % date, open, high, low, close, volume, adj close
  for k = 1:Ns

    % url = sprintf('%s%s%s%d%s%d%s%d%s%d%s%d%s%d%s', ...
    %               'https://chart.finance.yahoo.com/table.csv?s=', ...
    %               symbols{k}, ...
    %               '&a=',month0,'&b=',day0,'&c=',year0, ...
    %               '&d=',month1,'&e=',day1,'&f=',year1,'&g=d&ignore=.csv');
    % url = sprintf(['%s%s?period1=%d&period2=%d&interval=1d&events=' ...
    %                'history&crumb=E.z47grLd4d'], ...
    %               'https://query1.finance.yahoo.com/v7/finance/download/', ...
    %               symbols{k},day0_key,day1_key);

    file_name = '/home/dan/tabletest.csv';
    [status,result] = ...
        unix(['python ', ...
              '/home/dan/tradeStratsAndStats/dataAnalysis/matlab/ReadInYahooFinanceData.py ', ...
              sprintf('%s %d %d %d %d %d %d', ...
                      symbols{k},year0,month0,day0, ...
                      year1,month1,day1)]);
    if ~isempty(result)
      symbols{k}
      error(result);
    end

    data{k} = csvread(file_name,1,1);
    tmp_ = data{k}(:,5);
    data{k}(:,5) = data{k}(:,6);
    data{k}(:,6) = tmp_;

    N = length(data{k}(:,1));

    
    fid = fopen(file_name);
    l = N;
    tline = fgetl(fid);
    while 1
      tline = fgetl(fid);
      if ~ischar(tline)
        break
      else
        tmp = textscan(tline,'%10s\n');
        dates{k}{l} = tmp{1};
        l = l-1;
      end
    end
    fprintf('> loaded %s [%d/%d] \n',symbols{k},k,Ns);
  end
  
  N = length(data{1}(:,1));
  save([dir,SaveFile],'data','dates','Ns','N','symbols');
  fprintf('> Saved data to %s \n',[dir,SaveFile]);
end