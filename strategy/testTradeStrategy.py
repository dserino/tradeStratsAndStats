#!/usr/bin/python
import urllib2
import sys
import math
from dataDownloadFunctions import *

######
# Usage:
# ./testTradeStrategy [args...]
#
#   -dl symbols.txt --download data for stock symbols in symbols.txt file
#   -s  data.txt    --save downloaded data to data.txt
#   -l  data.txt    --load previously saved data.txt file
#   -y0 year        --start year
#   -m0 month       --start month
#   -d0 day         --start day
#   -y1 year        --end year
#   -m1 month       --end month
#   -d1 day         --end day
#   -b0 bank        --starting money in bank
#   -nb Nbuy        --max number of stocks purchased in a day
#   -bp buyingPower --percent of available funds for trading
#   -pl pLoss       --sell security when percentage lost dips below pLoss
#   -pp pProfit     --sell security when percentage gain is above pPlofit
#   -ps pSell       --sell this percentage of position 
#   -hp holdPeriod  --time for funds to settle
#
# -dl or -l is required

######
# Todo:
# - consider consistent stream of money coming into account

######
# Useful resources:
# yahoo finance api, current quotes
#  - https://greenido.wordpress.com/2009/12/22/work-like-a-pro-with-yahoo-finance-hidden-api/
# yahoo finance api, historical charts
#  - https://chart.finance.yahoo.com
#

def main():
    ### parse inputs and download/save data if necessary ###
    parseInputs()

    ### parse data ###

    ### analyze data ###

    ### test data if necessary ###

    ### initialize simulation ###

    ### perform simulation ###


    pass



def parseInputs():
    print ">> parsing inputs"

    ### must have at least 3 inputs
    if len(sys.argv) < 3:
        print "not enough inputs supplied"
        usage()
    
    ### first try finding a load file
    try:
        # get index of arg
        i_l = sys.argv.index('-l')

        # open file of data
        
        # todo, for now, loading capability is not implemented
        assert(0==1)

    except:
        # initialize variables
        Symbols = []

        # if load file does not exist
        ### try finding download file
        try:
            # open file
            i_dl = sys.argv.index('-dl')
            dl_filename = sys.argv[i_dl+1]
            dl_f = open(dl_filename,'r')
            
            # add symbols to a list
            for line in dl_f:
                Symbols.append(line)
                
            # print confirmation to screen
            print ">> opened "+dl_filename+", read "+str(len(Symbols))+" symbols"
            dl_f.close()

        except:
            # if download file does not exist
            # throw an error
            print "Load file and symbols file not inputted"
            usage()

        ### get start date and end date
        try:
            # obtain inputted start dates 
            i_y0 = sys.argv.index('-y0')
            i_m0 = sys.argv.index('-m0')
            i_d0 = sys.argv.index('-d0')
            i_y1 = sys.argv.index('-y1')
            i_m1 = sys.argv.index('-m1')
            i_d1 = sys.argv.index('-d1')
            
            y0 = eval(sys.argv[i_y0+1])
            m0 = eval(sys.argv[i_m0+1])
            d0 = eval(sys.argv[i_d0+1])
            y1 = eval(sys.argv[i_y1+1])
            m1 = eval(sys.argv[i_m1+1])
            d1 = eval(sys.argv[i_d1+1])
        except:
            # use default start dates
            y0 = 2014
            m0 = 1
            d0 = 1
            y1 = 2017
            m1 = 5
            d1 = 1
            

        ### download data from internet
        downloadHistoricalData(Symbols, \
                               y0,m0,d0, \
                               y1,m1,d1)
        
        


def usage():
    print "Usage:"
    print "./testTradeStrategy [args...]"
    print ""
    print "  -dl symbols.txt --download data for stock symbols in symbols.txt file"
    print "  -s  data.txt    --save downloaded data to data.txt"
    print "  -l  data.txt    --load previously saved data.txt file"
    print "  -y0 year        --start year"
    print "  -m0 month       --start month"
    print "  -d0 day         --start day"
    print "  -y1 year        --end year"
    print "  -m1 month       --end month"
    print "  -d1 day         --end day"
    print "  -b0 bank        --starting money in bank"
    print "  -nb Nbuy        --max number of stocks purchased in a day"
    print "  -bp buyingPower --percent of available funds for trading"
    print "  -pl pLoss       --sell security when percentage lost dips below pLoss"
    print "  -pp pProfit     --sell security when percentage gain is above pPlofit"
    print "  -ps pSell       --sell this percentage of position "
    print "  -hp holdPeriod  --time for funds to settle"
    print ""
    print "  -dl or -l is required"
    
    sys.exit()


if __name__ == "__main__":
    main()
