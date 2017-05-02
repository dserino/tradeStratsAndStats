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

Update from Dan?


*Research and Test trading strategies and collect data*

-- No update --


*Perform data analysis to model optimal trading strategy for stocks*

-- No update --


*Reconnect pystock to Yahoo API*

-- No update --
