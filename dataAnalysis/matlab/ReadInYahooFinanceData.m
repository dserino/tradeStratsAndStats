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
      end
      k = k+1;
    end
  end
  fclose(fid);

  Ns = length(symbols);
  data = cell(1,Ns);

  fprintf('> Read %d symbols \n',Ns);

  %% get data from yahoo finance
  %  (1),  (2),  (3), (4),   (5),    (6),       (7)
  % date, open, high, low, close, volume, adj close
  for k = 1:Ns

    url = sprintf('%s%s%s%d%s%d%s%d%s%d%s%d%s%d%s', ...
                  'https://chart.finance.yahoo.com/table.csv?s=', ...
                  symbols{k}, ...
                  '&a=',month0,'&b=',day0,'&c=',year0, ...
                  '&d=',month1,'&e=',day1,'&f=',year1,'&g=d&ignore=.csv');
    file_name = '/home/dan/Dropbox/Matlab/finance/datafiles/tabletest.csv';
    try
      %file = websave(file_name,url);
      file = urlwrite(url,file_name);
    catch
      symbols{k}
      error('symbol not recognized')
    end
    data{k} = csvread(file,1,1);
    data{k} = data{k}(end:(-1):1,:);
    N = length(data{k}(:,1));

    
    fid = fopen(file);
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
    fprintf('> loaded [%d/%d] \n',k,Ns);
  end
  
  N = length(data{1}(:,1));
  save([dir,SaveFile],'data','dates','Ns','N','symbols');
  fprintf('> Saved data to %s \n',[dir,SaveFile]);
end