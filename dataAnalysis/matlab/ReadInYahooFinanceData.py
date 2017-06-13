#!/usr/bin/python
import sys
import base64
import urllib
import urllib2
import time
import datetime
import ssl

if __name__ == '__main__':
    symbol = sys.argv[1]
    year0  = eval(sys.argv[2])
    month0 = eval(sys.argv[3])
    day0   = eval(sys.argv[4])
    year1  = eval(sys.argv[5])
    month1 = eval(sys.argv[6])
    day1   = eval(sys.argv[7])


    # convert to date time
    t1 = datetime.datetime(year0,month0,day0,0,0)

    # convert to date time
    t2 = datetime.datetime(year1,month1,day1,0,0)

    # get time in seconds based on standard of 1/1/70
    day0_key = (t1-datetime.datetime(1970,1,1)).total_seconds()
    day1_key = (t2-datetime.datetime(1970,1,1)).total_seconds()

    url = "%s%s?period1=%d&period2=%d&interval=1d&events=history&crumb=E.z47grLd4d" % ( \
              'https://query1.finance.yahoo.com/v7/finance/download/', \
              symbol, \
              day0_key,day1_key)

    # print url
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

    request  = urllib2.Request(url,data,header_params)
    gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
    response = urllib2.urlopen(request,context=gcontext)


    ### write to file 
    filename = "/home/dan/tabletest.csv"
    f = open(filename,'w+')
    f.write(response.read())
    # f.write("testing")
    f.close()


