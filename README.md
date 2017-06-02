# tradeStratsAndStats

This repo is for researching statistics and trading strategies for stock exchanges. 

Primary goals include (TODO)
1) Build historical database -- Working --
2) Develop tools to test trading strategies on historical data -- Working --
3) Research and Test trading strategies and collect data -- Researching --
4) Perform data analysis to model optimal trading strategies for stocks
5) Recconect pystock to Yahoo API


## Detailed Status

**Build Historical Database**

*Eddie*: I got this working now. There are a few "levels" of tables.

(1) At the first level, we have 500 Stock Price tables. Each of these tables represents a date and are named like SP20150323. Here's an example of what they look like:

    + ---------- + ---------- + ---------- + ---------- + ------- + --------- + ---------- + ----------------- +
    | SPO_Symbol | SPO_Date   | SPO_Open   | SPO_High   | SPO_Low | SPO_Close | SPO_Volume | SPO_AdjustedClose |
    + ---------- + ---------- + ---------- + ---------- + ------- + --------- + ---------- + ----------------- +
    | FCO        | 2015-03-23 | 9.25       | 9.42       | 9.25    | 9.42      | 38100      | 9.42              |
    | FCO        | 2015-03-20 | 9.21       | 9.32       | 9.21    | 9.3       | 38400      | 9.3               |
    | FAX        | 2015-03-23 | 5.42       | 5.49       | 5.42    | 5.46      | 837000     | 5.46              |
    | FAX        | 2015-03-20 | 5.41       | 5.45       | 5.41    | 5.43      | 641800     | 5.43              |
    | ....
    + ---------- + ---------- + ---------- + ---------- + ------- + --------- + ---------- + ----------------- +
    
Most of these tables have two dates for each symbol: the day of and the day before. I think this is meant to be able to calculate splits and dividends, but I honestly don't know. The psytock repo talks about this briefly. For now, I'm just grabbing the data that is listed as the same date as the table.
 
(2) The second level is a union of all of the data stored in the table Prices. This produces ~ 3 million records (~7,000 x 500).

(3) The third level is a crosstab that looks something like this:

    + ---------- + ---------- + ---------- + ---------- + 
    | SPO_Symbol | SP20150323 | SP20150324 | SP20150325 | ....
    + ---------- + ---------- + ---------- + ---------- + 
    | A          | 42.2       | 41.09      | 40.81      |
    | AA         | 13.0       | 13.09      | 12.97      |
    | .....
    + ---------- + ---------- + ---------- + ---------- + 
    
Each row is a different Symbol and each column is a different date. I have generated crosstabs for all dates up to 03/31/17 for our different fields (i.e. one for Volume, one for AdjustedClose, etc.). These take a long time to generate, so ideally we would switch to using (4) below.

Right now, the server just sits on my computer. I'm not really sure how to make it so that remote users can also access it. One option that might work for now is to just have the main server on my system print updated tables to the repo, and then everyone can access them from there. I know this is crappy, but short of getting something online, I don't know what else we can do. Until we get that figured out, I'm going to refrain from posting the sql scripts becuase (1) they still contain my personal information (like my database password), and (2) it's pointless for anyone who doesn't have a database on their system, and I don't think it's a good idea to replicate the database.




Some imporovements that could be made:

1) Use indexing to speed up the queries.

2) Symbols are recycled, and this data model currently does not account for that. Companies can change their symbols. I have a few thoughts about how to track this, but we'll need to do more research.

3) Include triggers that fire at the end of each day to print pystock data and update the database, including all the derived tables.

4) Create a stored procedures to automate all maintainance and querying, such as quickly grabbing the data we want via the python interface or underlying algorithms.





**Develop tools to test trading strategies on histroical data**

*Dan*: 
testTradeStrategy.py runs the strategy simulator on historical data. 
dataDownloadFunctions.py contains useful functions for using yahoo's API. For a given symbol and range of dates, historical data (open, close, high, low, volume, etc.) can be obtained.
statisticsFunctions.py has functions that calculate technical indicators and our custom indicators used by the simulation.
brokerageClasses.py contains classes for position lots (number of shares bought at the same time/price) and unsettled funds (funds that take ~3 days to be released to you after a sell).

The organization for the simulator is as follows:
1) Parsing inputs: parameters for the simulation and a file of symbols is read. For a given strategy, I think it is better to have a small finite list of (O(10) - O(100)) symbols which we are trading that strategy with.
2) Downloading data from yahoo: For given symbols, data is downloaded. Code gives an option to save data to avoid downloading data twice.
3) Initializing simulation 
4) Enter a loop over each trading day. The key difference between different strategies lies in the sell and buy functions. Currently implemented simple buy/sell functions, my vision for our work is to figure out the best analyses to run and come up with 'good' buy and sell functions.
     - Get date
     - If funds settle, release to bank
     - Run analysis to feed into buy/sell decisions
     - Determine to sell any positions or not
     - Determine to buy any stocks
     - Calculate account value
     - Print out days decisions
5) Use trading data to evaluate performance. win/loss ratios, performance for each symbol, etc.

<br /><br />

Possible todo: Integrate code with SQL to grab historical data from our databases. For optimizing a good trade strategy, we may not want to download data very frequently, therefore SQL can cut down on time and lessen the stress on yahoo servers. Once we know what symbols we want, we will want to download current data in our codes. The end goal is to write a (separate) code which reccommends real time trading decisions.

<br /><br />

*Eddie*: Same as point (4) in **Build Historical Database**. I will work on writing a stored procedure that takes date and symbol input from python and generates crosstabs of the data.

**Research and Test trading strategies and collect data**

*Eddie*: Explored some time-series methods on a few of the symbols. I've put this on pause for now.

I've been diving into learning trading strategies, reading books about trading, and watching videos from professional traders. In addition, I'm researching some good charting software and found a commission free trader.

*Dan*: Researched two methods for predicting daily stock prices.

1) The first idea is to smooth the data, extrapolate in time, then unsmooth the extrapolated values. The first two steps seem to work very well while the third step doesn't. The first two steps may be interesting for long terms stategies.
2) The second idea is to perform a regression on the daily percent increase given historical values for the technical indicators. This is justified because we are looking at similar conditions in the past that could help us predict the future. This may be more promising than (1).

Todo: research DMD and RCA methods

**Perform data analysis to model optimal trading strategy for stocks**

-- No update --


**Reconnect pystock to Yahoo API**

-- No update --

**Mutual fund performance analysis**

*Dan*: in /dataAnalysis/matlab/, the code analyzeMFs.m analyzes performance data for mutual funds in differet market sectors. This code can easily be extended to long term ETFs by changing the input symbols.
