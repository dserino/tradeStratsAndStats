#!/usr/bin/python
import urllib2
import sys
import math
import pickle
from dataDownloadFunctions import *
from statisticsFunctions import *

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
# - need to save symbols too
#

######
# Useful resources:
# yahoo finance api, current quotes
#  - https://greenido.wordpress.com/2009/12/22/work-like-a-pro-with-yahoo-finance-hidden-api/
# yahoo finance api, historical charts
#  - https://chart.finance.yahoo.com
#

def main():
    ### parse inputs and download/save data if necessary ###
    inputs = parseInputs()
    Symbols = inputs[0]
    AllData = inputs[1]
    b0 = inputs[2]
    nb = inputs[3]
    bp = inputs[4]
    pl = inputs[5]
    pp = inputs[6]
    ps = inputs[7]
    hp = inputs[8]
    Ns = len(Symbols)
    
    ### test data if necessary ###
    

    ### get statistics ###
    stats = CalculateNStdDev(AllData,10,Ns,4)
    Mu    = stats[0]
    Sigma = stats[1]
    Kappa = stats[2]
    
    ### initialize simulation ###

    ### perform simulation ###


    pass



def parseInputs():
    # Parse inputs, return the following 
    # (Symbols,AllData,b0,nb,bp,pl,pp,ps,hp)
    #
    # The columns are organized by
    # [date of quote, open, high, low, close, volume, adj close]
    #
    # Case 1:
    #   - a file with a list of symbols is read, then data from start date
    #     to end date is downloaded from yahoo finance
    # Case 2:
    #   - save file from previous run data is inputted to circumvent download process
    #
    # 

    
    print ">> parsing inputs"

    ### must have at least 3 inputs
    if len(sys.argv) < 3:
        print ">> not enough inputs supplied"
        usage()
    
    ### first try finding a load file
    try:
        # get index of arg
        i_l = sys.argv.index('-l')

        # open file of data
        l_filename = sys.argv[i_l+1]
        l_f = open(l_filename,'r')
        package = pickle.load(l_f)

        Symbols = package[0]
        AllData = package[1]

        assert(len(Symbols) == len(AllData))
        
        print ">> successfully loaded data from "+l_filename+ \
            ", read "+str(len(AllData))+" symbols"
        l_f.close()
        
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
                if line[0] == "#":
                    continue
                n = line.find("\n")
                Symbols.append(line[0:n])
                
                
            # print confirmation to screen
            print ">> opened "+dl_filename+", read "+str(len(Symbols))+" symbols"
            dl_f.close()

        except:
            # if download file does not exist
            # throw an error
            print ">> Load file and symbols file not inputted"
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
            
        print ">> Using data from "+ \
            str(m0)+"/"+str(d0)+"/"+str(y0)+" to "+ \
            str(m1)+"/"+str(d1)+"/"+str(y1)
        
        ### download data from internet
        print ">> downloading data from yahoo"

        try:
            AllData = downloadHistoricalData(Symbols, \
                                             y0,m0,d0, \
                                             y1,m1,d1)
        except:
            print ">> unable to download data"
            sys.exit()
            
        ### save data
        try:
            # open and save file
            i_s = sys.argv.index('-s')
            s_filename = sys.argv[i_s+1]
            s_f = open(s_filename,'w+')
            pickle.dump([Symbols,AllData],s_f)
            s_f.close()
            print ">> saved data to "+s_filename
        except:
            print ">> file didn't save"


    # need other inputs too, todo
    try:
        i = sys.argv.index('-b0')
        b0 = eval(sys.argv[i+1])
        
        i = sys.argv.index('-nb')
        nb = eval(sys.argv[i+1])
        
        i = sys.argv.index('-bp')
        bp = eval(sys.argv[i+1])
        
        i = sys.argv.index('-pl')
        pl = eval(sys.argv[i+1])
        
        i = sys.argv.index('-pp')
        pp = eval(sys.argv[i+1])
        
        i = sys.argv.index('-ps')
        ps = eval(sys.argv[i+1])
        
        i = sys.argv.index('-hp')
        hp = eval(sys.argv[i+1])

        print ">> input arguments read:"
    except:
        b0 = 2000
        nb = 1
        bp = 0.9
        pl = 0.0025
        pp = 0.0050
        ps = 0.7
        hp = 1

        print ">> default values used for inputs:"

    print ">>   bank        = "+str(b0)
    print ">>   Nbuy        = "+str(nb)
    print ">>   buyingPower = "+str(bp)
    print ">>   pLoss       = "+str(pl)
    print ">>   pProfit     = "+str(pp)
    print ">>   pSell       = "+str(ps)
    print ">>   holdPeriod  = "+str(hp)

    ### return everything
    return (Symbols,AllData, \
            b0,nb,bp,pl,pp,ps,hp)


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
