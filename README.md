# tradeStratsAndStats

This repo is for researching statistics and trading strategies for stock exchanges. 

Primary goals include (TODO)
1) Build historical database
2) Develop tools to test trading strategies on historical data
3) Research and Test trading strategies and collect data
4) Perform data analysis to model optimal trading strategies for stocks
5) Recconect pystock to Yahoo API
6) 


**Detailed Status**

*Build Historical Database*

Eddie: I downloaded SQL Server onto my desktop computer. Turns out $75 doesn't buy you a whole lot of processing power, and my desktop is pretty darn slow. So I've setup a PostgreSQL database on my ubuntu laptop for now, and I'm looking to upload the stock data into the database in a meaningful and manageable way. Python has several PostgreSQL modules, so connecting to the database should be okay once we learn the modules. If they're anything like MySQLdb, then we're already set because that's a walk in the park.

Couple of things to keep in mind when building the database:

1) I want to assign a primary key to each symbol to allow indexing. Then we can access and combine the data very quickly, as needed in our simulations. In order to do this, I need a list of all symbols. I can create this from pystock's data, with a few caveats, the biggest of which is the fact that symbols are recycled, and companies can change their symbols. I have a few thoughts about how to track this, but I'll need to do more research.

2) Once I get symbol-key mapping, I need to load the pricing data in and match that data to the key. This should be relatively straightforward and only has to happen once per day.

3) After that is setup, we'll build some stored procedures for quickly grabbing the data we want via the python interface.


*Develop tools to test trading strategies on histroical data*

Dan: I've been working on porting my old strategy simulator matlab code to python. Right now the organization is
testTradeStrategy.py runs the strategy simulator on historical data. 
dataDownloadFunctions.py contains useful functions for using yahoo's API. For a given symbol and range of dates, historical data (open, close, high, low, volume, etc.) can be obtained.
statisticsFunctions.py will have functions that calculate technical indicators and our custom indicators used by the simulation.
brokerageClasses.py contains classes for position lots (number of shares bought at the same time/price) and unsettled funds (funds that take ~3 days to be released to you after a sell).
Currently implemented is

1) Parsing inputs: parameters for the simulation and a file of symbols is read. For a given strategy, I think it is better to have a small finite list of (O(10) - O(100)) symbols which we are trading that strategy with.
2) Downloading data from yahoo: For given symbols, data is downloaded. Code gives an option to save data to avoid downloading data twice.
3) Initializing simulation

What's left to do includes:

1) Finish porting previous code. The simulation runs for each trading day and has the structure. The key difference between different strategies lies in the sell and buy functions. I will implement my version first to get a working code, but my vision for our work is to figure out the best analyses to run and come up with 'good' buy and sell functions.
     - Get date
     - If funds settle, release to bank
     - Run analysis to feed into buy/sell decisions
     - Determine to sell any positions or not
     - Determine to buy any stocks
     - Calculate account value
     - Print out days decisions
2) Integrate code with SQL to grab historical data from our databases. For optimizing a good trade strategy, we may not want to download data very frequently, therefore SQL can cut down on time and lessen the stress on yahoo servers. Once we know what symbols we want, we will want to download current data in our codes. The end goal is to write a (separate) code which reccommends real time trading decisions.

*Research and Test trading strategies and collect data*

-- No update --


*Perform data analysis to model optimal trading strategy for stocks*

-- No update --


*Reconnect pystock to Yahoo API*

-- No update --
