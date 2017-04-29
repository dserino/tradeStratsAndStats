import urllib2

def downloadHistoricData(Symbols, \
                         year0,month0,day0, \
                         year1,month1,day1):
    # download historical data from yahoo finance
    # returns AllData
    # AllData[k_symbol][k_date][k_column]
    # date of quote, open, high, low, close, volume, adj close
    
    AllData = []
    
    # loop over all symbols
    for k in range(0,len(Symbols)):
        # create url using yahoo finance api
        url = "%s%s%s%d%s%d%s%d%s%d%s%d%s%d%s" % ( \
              'https://chart.finance.yahoo.com/table.csv?s=', \
              Symbols[k], \
              '&a=',month0,'&b=',day0,'&c=',year0, \
              '&d=',month1,'&e=',day1,'&f=',year1,'&g=d&ignore=.csv')

        # download data from url
        response = urllib2.urlopen(url)

        # read response
        chart = response.read()

        # split rows into array 
        data1 = chart.split('\n')

        # for each row, split comma separated data into columns 
        data2 = []
        # loop to length-1 because last row will be blank
        for n in range(0,len(data1)-1):
            data2.append(data1[n].split(','))

        # append to all data
        AllData.append(data2)

        print "["+str(k)+","+str(len(Symbols))+"]"

    # return all data
    return AllData
