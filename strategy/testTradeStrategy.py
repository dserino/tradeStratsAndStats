#!/usr/bin/python
import urllib2
import sys
import math
import pickle
from dataDownloadFunctions import *
from statisticsFunctions import *
from brokerageClasses import *

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
#   -db debugMode   --user hits enter to advance
#
# -dl or -l is required

######
# Todo:
# - Consider consistent stream of money coming into account
# - Make a simulator out of this. Ask user for inputs

######
# Useful resources:
# yahoo finance api, current quotes
#  - https://greenido.wordpress.com/2009/12/22/work-like-a-pro-with-yahoo-finance-hidden-api/
# yahoo finance api, historical charts
#  - https://chart.finance.yahoo.com
#

def main():
    ######
    ### parse inputs and download/save data if necessary ###
    inputs = parseInputs()

    # symbols
    Symbols = inputs[0]
    Ns = len(Symbols)

    # all data
    AllData = inputs[1]
    # AllData[k_symbol][k_date][k_column]
    # The columns are organized by
    # [date of quote, open, high, low, close, volume, adj close]
    n_date      = 0
    n_open      = 1
    n_high      = 2
    n_low       = 3
    n_close     = 4
    n_volume    = 5
    n_adj_close = 6

    # trade parameters
    B0          = inputs[2]
    Nbuy        = inputs[3]
    buyingPower = inputs[4]
    pLoss       = inputs[5]
    pProfit     = inputs[6]
    pSell       = inputs[7]
    holdPeriod  = inputs[8]
    debugMode   = inputs[9]
    minBuyScore = -1.0
    
    ######
    ### get statistics ###
    stats = CalculateNStdDev(AllData,10,Ns,4)

    # mean and std dev
    Mu    = stats[0]
    Sigma = stats[1]
    Kappa = stats[2]

    ######
    ### test data if necessary ###
    # todo, have a debug flag, generate plots to
    # check data

    ######
    ### initialize simulation ###
    # account value
    AV = []
    # bank balance
    B = []
    # value of positions
    PV = []
    # funds to be settled
    SF = []

    # positions
    Positions = []
    # unsettled funds
    UnsettledFunds = []
    
    # initial conditions
    B.append(B0)
    AV.append(B0)
    PV.append(0.0)
    SF.append(0.0)

    ######
    ### perform simulation ###
    checkDates(AllData,Symbols,Ns)
    N = len(AllData[0])

    # statistics to keep track of
    total_positive_gain = [0.]
    total_negative_gain = [0.]
    total_invested = [[]]
    total_profit = [[]]
    for k in range(0,Ns):
        total_invested[0].append(0.)
        total_profit[0].append(0.)
        
    current_year = AllData[0][0][n_date][0:4]
        
    print ">> starting simulation"
    # date index
    for n in range(0,N):
        ### get date
        year = AllData[0][n][n_date][0:4]
        if year != current_year:
            if n != 0:
                print ">> happy new year!"
            current_year = year
            total_positive_gain.append(0.)
            total_negative_gain.append(0.)
            total_invested.append([])
            total_profit.append([])
            for k in range(0,Ns):
                total_invested[-1].append(0.)
                total_profit[-1].append(0.)

        # print total_invested
        # print total_profit
        # print total_positive_gain
        # print total_negative_gain
        
        ### update bank
        B.append(B[n])

        ### todays decisions
        TodaysDecisions = []
        
        ### determine scores for each symbol
        # todo, check if indeces are right here, need to use past data
        scores = GetScores(Kappa,n,minBuyScore,Nbuy,Ns)
        s_K       = scores[0]
        order     = scores[1]
        Nbuy_true = scores[2]
        kappa_    = scores[3]
        # print kappa_
        # print s_K
        # print order
        # print Nbuy_true
        

        ### settled funds
        # release settled funds to bank
        s = 0
        while s < len(UnsettledFunds):
            # substract days from each fund
            UnsettledFunds[s].days_left -= 1
            
            if UnsettledFunds[s].days_left == 0:
                # remove and add to bank
                B[n+1] += UnsettledFunds[s].amount
                TodaysDecisions.append("$%6.2f settled" % UnsettledFunds[s].amount)
                UnsettledFunds.pop(s)
            else:
                s += 1
            
        ### determine to sell positions or not
        p = 0
        while p < len(Positions):
            # for each position

            # get index
            k = Positions[p].index

            # calculate value
            # todo: figure out current value based on time checking
            # usually I check in the middle/end of the day for buying
            # and beginning of day for selling
            Positions[p].current_value = AllData[k][n][n_open]
            
            # determine selling point
            if Positions[p].current_value >= Positions[p].exit_high or \
               Positions[p].current_value <= Positions[p].exit_low:
                
                # sell percentage of holdings
                # todo, figure out how many shares to sell
                if Positions[p].current_value >= Positions[p].exit_high:
                    nShares = math.ceil(pSell*Positions[p].n_shares)
                else:
                    nShares = Positions[p].n_shares
                    
                # determine net gain from cost basis
                # todo, keep track of capital gain for estimating tax
                gain = (Positions[p].current_value \
                        -Positions[p].cost_basis/(Positions[p].n_shares*1.0) ) \
                    /(Positions[p].cost_basis/(Positions[p].n_shares*1.0))*100.0
                net_gain = (Positions[p].current_value \
                            -Positions[p].cost_basis/(Positions[p].n_shares*1.0))*nShares

                # fill in for end statistics
                if net_gain > 0:
                    total_positive_gain[-1] += net_gain
                else:
                    total_negative_gain[-1] += net_gain
                total_profit[-1][k] += net_gain
                
                # keep number of old shares
                old_n_shares = Positions[p].n_shares
                # update position lot to reflect shares sold
                Positions[p].n_shares -= nShares
                # total amount made from sell (not profit)
                amount = nShares*Positions[p].current_value

                # add message for today's decisions
                TodaysDecisions.append(("sell %6d shares of %6s at $%6.2f (%5.2f%%), " \
                                        % (nShares,Symbols[k], \
                                           Positions[p].current_value,gain)) + \
                                       ("net gain = $%6.2f" % (net_gain)))

                # add to settled funds
                UnsettledFunds.append(unsettledFunds(amount,holdPeriod))

                if Positions[p].n_shares == 0:
                    Positions.pop(p)
                    continue
                else:
                    # set new exits for rest of shares
                    # exit low is a break even
                    Positions[p].exit_low = Positions[p].cost_basis \
                                            /(Positions[p].n_shares*1.0)
                    # exit high is 1+pProfit times greater than current value
                    Positions[p].exit_high = Positions[p].current_value*(1+pProfit)

                    # adjust cost basis
                    Positions[p].cost_basis = Positions[p].cost_basis \
                                              *Positions[p].n_shares/(old_n_shares*1.0)



            # if Positions[p].n_shares == 0:
            #     # remove position
            #     Positions.pop(p)
            # else:
            p += 1
                
        ### determine to buy or not
        todaysFunds = buyingPower*B[n+1]
        for nb in range(Nbuy_true):
            # stock index
            k = order[nb]

            # go through each stock and buy
            availableFunds = todaysFunds/(Nbuy_true*1.0)

            # number of shares
            # todo determine when to buy/what price
            nShares = math.floor(availableFunds/AllData[k][n][n_close])
            if nShares > 0:
                buyPrice = AllData[k][n][n_close]
                
                cost = nShares*buyPrice

                total_invested[-1][k] += cost
                
                # subtract from account
                todaysFunds = todaysFunds-cost
                B[n+1] = B[n+1]-cost

                # add to positions
                Positions.append(positionLot(cost,nShares,Symbols[k],pProfit,pLoss,k))
                
                # print decision
                TodaysDecisions.append("buy  %6d shares of %6s at $%6.2f" % \
                                       (nShares,Symbols[k],buyPrice))

        ### calculate value
        Value = CalculateValue(B[n+1],Positions,UnsettledFunds)
        AV.append(Value[0])
        SF.append(Value[1])
        PV.append(Value[2])

        ### print out days decisions
        # date
        print AllData[0][n][n_date]+":"
        for k in range(0,len(TodaysDecisions)):
            print "  "+TodaysDecisions[k]
        # total value
        print "  Positions Value: $%.2f" % PV[n+1]
        print "  Unsettled Funds: $%.2f" % SF[n+1]
        print "  Bank Value:      $%.2f" % B[n+1]
        print "  Account Value:   $%.2f" % AV[n+1]
        if debugMode:
            if n == 0:
                raw_input(">> hit [enter] to advance ")
                print ""
            else:
                raw_input("")
        
    # plotting
    # print some performance stats
    # total positive gain
    # total negative gain
    # performance by symbol
    # total invested
    # total profit
    #

    print ""
    print "###"
    print "###"
    print "###"
    print "###"
    print "###"
    print "# Trade Strategy Performance:"
    
    current_year = eval(AllData[0][0][n_date][0:4])
    for n_year in range(len(total_positive_gain)):
        print "###"
        print "# year: "+str(current_year)
        
        print "%7s  %14s  %12s %14s" % ("symbol","total invested", \
                                     "total profit","percent profit")
        for k in range(Ns):
            if total_invested[n_year][k] == 0:
                print "%7s  $%13.2f  $%11.2f " % \
                    (Symbols[k],total_invested[n_year][k], \
                     total_profit[n_year][k])
            else:
                print "%7s  $%13.2f  $%11.2f %13.2f%%" % \
                    (Symbols[k],total_invested[n_year][k], \
                     total_profit[n_year][k], \
                     total_profit[n_year][k] \
                     /total_invested[n_year][k]*100.0)


        print ""
        print "total positive gain: $%9.2f" % (total_positive_gain[n_year])
        print "total negative gain: $%9.2f" % (total_negative_gain[n_year])
        print "net gain:            $%9.2f" % (total_positive_gain[n_year]+ \
                                                 total_negative_gain[n_year])
        print "win/loss ratio:       %9.2f" % -(total_positive_gain[n_year]/ \
                                                  total_negative_gain[n_year])

        current_year += 1
        print ""
    

        


def CalculateValue(B,Positions,UnsettledFunds):
    """
    calculate daily value of account given bank, position lots, and unsettled funds
    """

    ### settled funds
    SF = 0
    for k in range(0,len(UnsettledFunds)):
        SF += UnsettledFunds[k].amount

    ### positions values
    PV = 0
    for k in range(0,len(Positions)):
        PV += Positions[k].current_value*Positions[k].n_shares

    AV = PV+SF+B

    return (AV,SF,PV)




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

    try:
        i = sys.argv.index('-db')
        db = True
    except:
        db = False
        
    print ">>   bank        = "+str(b0)
    print ">>   Nbuy        = "+str(nb)
    print ">>   buyingPower = "+str(bp)
    print ">>   pLoss       = "+str(pl)
    print ">>   pProfit     = "+str(pp)
    print ">>   pSell       = "+str(ps)
    print ">>   holdPeriod  = "+str(hp)
    print ">>   debugMode   = "+str(db)
    
    ### return everything
    return (Symbols,AllData, \
            b0,nb,bp,pl,pp,ps,hp,db)


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
