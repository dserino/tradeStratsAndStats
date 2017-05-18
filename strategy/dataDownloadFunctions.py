import time
import base64
import urllib
import urllib2
import datetime

def downloadHistoricalData(Symbols, \
                         year0,month0,day0, \
                         year1,month1,day1):
    # download historical data from yahoo finance given
    # initial date and end date.
    # AllData is returned in format:
    #   - AllData[k_symbol][k_date][k_column]
    # The columns are organized by
    # [date of quote, open, high, low, close, adj close, volume]

    ### Deal with inputs for dates
    # Yahoo wants these to be in seconds

    # convert dates to date time
    t1 = datetime.datetime(year0,month0,day0,0,0)
    t2 = datetime.datetime(year1,month1,day1,0,0)

    # get time in seconds based on standard of 1/1/70
    day0_key = (t1-datetime.datetime(1970,1,1)).total_seconds()
    day1_key = (t2-datetime.datetime(1970,1,1)).total_seconds()

    ### Deal with api access key
    client_id = "dj0yJmk9dXVURnhKZVJtbXRVJmQ9WVdrOVExYzNkbTVKTldNbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iYQ--"
    client_secret = "98767d5780570c652504bee46626de23b1d294a1"
    credentials = "%s:%s" % (client_id, client_secret)
    encode_credential = base64.b64encode(credentials.encode('utf-8')).decode('utf-8').replace("\n", "")
    header_params = {
        "Authorization": ("Basic %s" % encode_credential),
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json"
    }
    param = {
        'grant_type': 'client_credentials',
    }
    data = urllib.urlencode(param)


    ### allocate for all data
    AllData = []
    
    # loop over all symbols
    for k in range(0,len(Symbols)):
        # create url using yahoo finance api
        url = "%s%s?period1=%d&period2=%d&interval=1d&events=history&crumb=E.z47grLd4d" % ( \
              'https://query1.finance.yahoo.com/v7/finance/download/', \
              Symbols[k], \
              day0_key,day1_key)

        # download data from url
        request  = urllib2.Request(url,data,header_params)
        response = urllib2.urlopen(request)

        # read response
        chart = response.read()

        # split rows into array 
        data1 = chart.split('\n')

        # for each row, split comma separated data into columns 
        data2 = []
        # start from second row and 
        # loop to length-1 because last row will be blank
        for n in range(1,len(data1)-1):
            tmp = data1[n].split(',')

            # now change appropriate numbers to 
            for col in range(1,len(tmp)):
                tmp[col] = eval(tmp[col])
                             
            data2.append(tmp)

        # append to all data
        AllData.append(data2)

        print "["+str(k+1)+"/"+str(len(Symbols))+"]"

    # return all data
    return AllData


def downloadHistoricalDataOld(Symbols, \
                                year0,month0,day0, \
                                year1,month1,day1):
    # download historical data from yahoo finance given
    # initial date and end date.
    # AllData is returned in format:
    #   - AllData[k_symbol][k_date][k_column]
    # The columns are organized by
    # [date of quote, open, high, low, close, volume, adj close]
    # 
    # This is the old way to download from yahoo. Recently Yahoo closed down this
    # way into the server


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
        # start from second row and 
        # loop to length-1 because last row will be blank
        for n in range(1,len(data1)-1):
            tmp = data1[n].split(',')
            
            # now change appropriate numbers to 
            for col in range(1,len(tmp)):
                tmp[col] = eval(tmp[col])
                             
            data2.append(tmp)

        # append to all data
        data2.reverse()
        AllData.append(data2)

        print "["+str(k+1)+"/"+str(len(Symbols))+"]"

    # return all data
    return AllData
    
    
