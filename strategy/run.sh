#!/bin/sh

iRun=1

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

# start date
y0=2015
m0=1
d0=1

# end date
y1=2017
m1=6
d1=1

# initial available money to trade
b0=2000

# max number of stocks purchased in a day
nb=2 

# percent of available funds for trading
bp=0.9

# sell security when percentage lost dips below pLoss
pl=.0025

# sell security when percentage gain is above pPlofit
pp=.0050

# sell this percentage of position 
ps=0.9

# time for funds to settle
hp=1

if [ "$iRun" = "1" ]
then
    symbols="symbolFiles/testSymbols.txt"
    saveFile="saveFiles/testSymbols_save_1.p"

else
    echo "invalid iRun number"
    exit
fi

if [ "$1" = "1" ]
then
    loadFile=""
else
    loadFile=$saveFile
fi

if [ "$2" = "1" ]
then
    db="-db"
else
    db=""
fi

# use inputs from above
./testTradeStrategy.py -dl $symbols -s $saveFile \
		       -l $loadFile \
		       -y0 $y0 -m0 $m0 -d0 $d0 \
		       -y1 $y1 -m1 $m1 -d1 $d1 \
		       -b0 $b0 -nb $nb -bp $bp \
		       -pl $pl -pp $pp -ps $ps \
		       -hp $hp $db


