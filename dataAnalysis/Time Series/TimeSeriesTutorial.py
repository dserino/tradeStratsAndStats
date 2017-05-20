#!/usr/bin/python

# This file follows the tutorial found here:
# https://www.analyticsvidhya.com/blog/2016/02/time-series-forecasting-codes-python/

import pandas as pd
import numpy as np
import matplotlib.pylab as plt

# This syntax:
# 		%matplotlib inline
# in only supported by the IPython Command line. It cannot be used in scripts.
# Instead, we will use the following:
# from IPython import get_ipython as ipy
# ipy().run_line_magic('matplotlib','inline')
# Unfortunately, attempting to install ipython on my system gives me the dreaded
# 'x86_64-linux-gnu-gcc' failed with exit status 1 error

from matplotlib.pylab import rcParams
rcParams['figure.figsize'] = 15, 6

from TutorialHelperFunctions import *



## ------------- ##
## Getting Setup ##
## ------------- ##

## Read the data into pandas

data = pd.read_csv('AirPassengers.csv')
print data.head()
print '\nData Types:'
print data.dtypes

#      Month  #Passengers
# 0  1949-01          112
# 1  1949-02          118
# 2  1949-03          132
# 3  1949-04          129
# 4  1949-05          121

# Data Types:
# Month          object
# #Passengers     int64
# dtype: object

# This is not a TS object yet, so we have to parse them



# Parse the data as a time series object
dateparse = lambda dates: pd.datetime.strptime(dates, '%Y-%m') # Build date parser instructions
data = pd.read_csv('AirPassengers.csv', # read AirPassengers csv
	parse_dates = ['Month'], # specifies which column the date information is in
	index_col = 'Month', # key idea behind TS is to index on date/time variable
	date_parser = dateparse) # defines the format the dates are in. Default is 'YYYY-MM-DD HH:MM:SS'
print data.index

# DatetimeIndex(['1949-01-01', '1949-02-01', '1949-03-01', '1949-04-01',
#                '1949-05-01', '1949-06-01', '1949-07-01', '1949-08-01',
#                '1949-09-01', '1949-10-01',
#                ...
#                '1960-03-01', '1960-04-01', '1960-05-01', '1960-06-01',
#                '1960-07-01', '1960-08-01', '1960-09-01', '1960-10-01',
#                '1960-11-01', '1960-12-01'],
#               dtype='datetime64[ns]', name=u'Month', length=144, freq=None)
# [ns] next to datetime64 indicates that it is the datetime index for this TS object


# Personal preference: convert column to a Series object 

ts = data['#Passengers']
print ts.head(5)
print "\n\n"



## ------------------------ ##
## Some Indexing Techniques ##
## ------------------------ ##

print ts['1949-01-01'] # Select a value in the series object by date string
print ts['1949-01-01':'1949-05-01'] # Select all values in an interval
# note that the end index is included (unlike Python, which uses C's < idea)
print ts['1949'] # select all values in this year





## ---------------------- ##
## Analyzing Stationarity ##
## ---------------------- ##

# A TS is Stationary if:
# (1) Constant Mean over time
# (2) Constant Variance over time
# (3) Autocovariance does not depend on time

# If TS is nonstationary, then we can try to remove the trend first (like Meershaert does in his book).
# Though stationarity is assumed in many TS models, this is impractical.
# See https://www.analyticsvidhya.com/blog/2015/12/complete-tutorial-time-series-modeling/ for more details

plt.plot(ts)
# plt.show(block = True) # Needed for noninteractive python mode

# From the plot, we can easily see that the mean and variance are nonconstant.
# This is not always immediately obvious, so we can plot rolling statistics
# (moving average and variance), which will help reveal if the TS is stationary.

# We can also use the Dickey-Fuller Test.
# Nul hypothesis is that TS is non-stationary. 
# The test results comprise of a Test Statistic and some Critical Values for
# different confidence levels. If the Test Statistic is less than the Critical
# Value, we can reject the null hypothesis and say that the TS is stationary. 
# More details here: https://www.analyticsvidhya.com/blog/2015/12/complete-tutorial-time-series-modeling/
# We'll do this a lot, so we define a function

# test_stationarity(ts)

# Results of Dickey-Fuller Tests:

# Test Statistic                   0.815369
# p-value                          0.991880
# #Lags Used                      13.000000
# Number of Observations Used    130.000000
# Critical Value (5%)             -2.884042
# Critical Value (1%)             -3.481682
# Critical Value (10%)            -2.578770
# dtype: float64

# Test Statistict is way above the Critical Value (signed values should be compared, not absolute values)

# Therefore, from the graphs and the Dickey-Fuller test, we conclude that the
# TS is not stationary



## ------------------------------- ##
## Making a Time Series Stationary ##
## ------------------------------- ##

# Two things make a TS nonstationary.
# (1) Trend: Varying mean over time
# (2) Seasonality: Variations over specific time frames
# Underlying principal is to model these two and remove them from the TS,
# then reapply them after the TS is modeled


## --- Estimating and Eliminating Trend --- ##

# We can use transformation to reduce a trend

ts_log = np.log(ts)
plt.plot(ts_log)
# plt.show()

# We can model the trend with
# Aggregation: Bin up the data into a coarser set over month/weeks
# Smoothing: Take a rolling average
# Polyfitting: Fit a regression model.
# We will only look at smoothing here, although see Meershaert's book for line fitting

moving_avg = pd.rolling_mean(ts_log,12)
plt.plot(ts_log)
plt.plot(moving_avg, color = 'red')
# plt.show()

# Since we take an average over the last twelve values, the first eleven are not defined

ts_log_moving_avg_diff = ts_log - moving_avg
print "\n\n"
print ts_log_moving_avg_diff.head(12)

# Let's drop the null values and test stationarity

ts_log_moving_avg_diff.dropna(inplace = True)
# test_stationarity(ts_log_moving_avg_diff)

# According the results of the Dickey-Fuller test, we are 95% confident that this
# TS is stationary.

# Downside: we lose some data and we are forced to strictly define a time-period,
# which is not easy to do in complex situatins like forecasting stocks.

# We can take a weighted moving average where recent values are given a higher weight.
# Let's try it with exponentially weighted moving average.
# Here are more details: http://pandas.pydata.org/pandas-docs/stable/computation.html#exponentially-weighted-moment-functions

expweighted_avg = pd.ewma(ts_log, halflife = 12) # Halflife defines the amount of exponential decay.
plt.plot(ts_log)
plt.plot(expweighted_avg, color = 'red')
# plt.show()

ts_log_ewma_diff = ts_log - expweighted_avg
# test_stationarity(ts_log_ewma_diff)

# Results are even better and by Dickey-Fuller test, we are 99% confident
# that the new TS is stationary. Also, note that we didn't have to throw
# away any values





## --- Eliminating Trend and Seasonality --- ##

# Sometimes the above techniques do not work well, especially with seasonally
# varying data. Two ways to take care of that:

# (1) Differencing: take the difference with a particular time lag so that
# 		parts of the "wave" difference equally. Assumes constant period throughout
# (2) Decomposition: Modeling trend and seasonality and removing them from model.
# 		So basically a black box 

# Let's start with differencing

ts_log_diff = ts_log - ts_log.shift() # First order difference
ts_log_diff.dropna(inplace = True)
# test_stationarity(ts_log_diff)

# 90% confident that there is no stationarity. Higher order differencing
# might return higher levels of confidence.


# Now on to decomposing

from statsmodels.tsa.seasonal import seasonal_decompose

decomposition = seasonal_decompose(ts_log)
trend = decomposition.trend
seasonal = decomposition.seasonal
residual = decomposition.resid

plt.subplot(411)
plt.plot(ts_log, label='Original')
plt.legend(loc='best')
plt.subplot(412)
plt.plot(trend, label='Trend')
plt.legend(loc='best')
plt.subplot(413)
plt.plot(seasonal,label='Seasonality')
plt.legend(loc='best')
plt.subplot(414)
plt.plot(residual, label='Residuals')
plt.legend(loc='best')
plt.tight_layout()
# plt.show()

# The residual is what's left over from the original after taking out the seasonality and trend

ls_log_decompse = residual
ls_log_decompse.dropna(inplace = True)
# test_stationarity(ls_log_decompse)

# According to Dickey-Fuller, we are well above 99% confident that the series is stationary.





## ------------------------- ##
## Forecasting a Time Series ##
## ------------------------- ##

# Differencing is a very popular and easy to use technique, so we'll model the
# TS with that.

# After removing the trend and seasonality, we are left with two cases:
# (1) Strictly stationary series, in which all that is left can be modeled
# 		as white noise, so the actualy model is the trend and seasonality.
#		This is very rare.
# (2) Series with significant dependence among the values. This requries us
# 		to use statistical models like ARIMA to forecast the data.

# ARIMA is Auto-Regressive Integrated Moving Averages. This is a linear equation;
# that is, each point is modeled as linear combination of the other points.
# The predictors depend on the parameters p, d, and q.

# p: Number of AR (Auto-regressive) terms. If p is 5, the predictors for x(t)
# 		will be x(t-1),...,x(t-5).
# q: Number of MA (Moving Averages) terms. Lagged forecast erros in prediction
#		equation (not really sure what this means). If q = 5, then the predictors
# 		for x(t) will be e(t-1),...,e(t-5).
# d; Number of Differences. Order of differencing. In our example, we can do
#		the differencing ourselves as above and pass that new variable with
#		d = 0, or we can pass the original with d = 1.


# How do we determine the values of p and q?
# (1) Autocorrelation Function (ACF): Measure of correlation between TS
#		and a lagged version of itself. Meershaert does this in his book
#		to conclude that p and q should be 1.
# (2) Partial Autocorrelation Function (PACF): Same as above but after removing
#		the variations already explained by the above comparison. Ex: for lag 5,
#		it will check correlation but remove the effects already explained
#		by lags 1 to 4.

from statsmodels.tsa.stattools import acf, pacf

lag_acf = acf(ts_log_diff, nlags = 20)
lag_pacf = pacf(ts_log_diff, nlags = 20, method = 'ols')

# Plot the ACF:
plt.subplot(121) 
plt.plot(lag_acf)
plt.axhline(y=0,linestyle='--',color='gray')
plt.axhline(y=-1.96/np.sqrt(len(ts_log_diff)),linestyle='--',color='gray')
plt.axhline(y=1.96/np.sqrt(len(ts_log_diff)),linestyle='--',color='gray')
plt.title('Autocorrelation Function')

#Plot PACF:
plt.subplot(122)
plt.plot(lag_pacf)
plt.axhline(y=0,linestyle='--',color='gray')
plt.axhline(y=-1.96/np.sqrt(len(ts_log_diff)),linestyle='--',color='gray')
plt.axhline(y=1.96/np.sqrt(len(ts_log_diff)),linestyle='--',color='gray')
plt.title('Partial Autocorrelation Function')
plt.tight_layout()

plt.show()


# dotted lines are zero and the confidence intervals.
# p: the lag value where the pacf chart crosses the upper interval for the first
# time. Here it is p = 2.
# q: the lag value where the acf chart crosses the upper interval for the first
# time. Here it is q = 2.


# Now we use this information in ARIMA to get models

from statsmodels.tsa.arima_model import ARIMA

# AR
model = ARIMA(ts_log, order=(2, 1, 0))  
results_AR = model.fit(disp=-1)  
plt.plot(ts_log_diff)
plt.plot(results_AR.fittedvalues, color='red')
plt.title('RSS: %.4f'% sum((results_AR.fittedvalues-ts_log_diff)**2))
# plt.show()

# The code above doesn't seem to work, but the RSS value is 1.5023
# and the fit is quite poor.

# MA
model = ARIMA(ts_log, order=(0, 1, 2))  
results_MA = model.fit(disp=-1)  
plt.plot(ts_log_diff)
plt.plot(results_MA.fittedvalues, color='red')
plt.title('RSS: %.4f'% sum((results_MA.fittedvalues-ts_log_diff)**2))
# plt.show()

# same problem as above. Teh RSS is 1.4721 and the fit is poor

# Combined
model = ARIMA(ts_log, order=(2, 1, 2))  
results_ARIMA = model.fit(disp=-1)  
plt.plot(ts_log_diff)
plt.plot(results_ARIMA.fittedvalues, color='red')
plt.title('RSS: %.4f'% sum((results_ARIMA.fittedvalues-ts_log_diff)**2))
# plt.show()

# RSS is 1.0292. Fit just looks like its a smoothing of the data.



# Now we want to go back to the orginal series.
# Store predicted results as a separate series
predictions_ARIMA_diff = pd.Series(results_ARIMA.fittedvalues, copy = True)
print predictions_ARIMA_diff.head()

# Month
# 1949-02-01    0.009580
# 1949-03-01    0.017491
# 1949-04-01    0.027670
# 1949-05-01   -0.004521
# 1949-06-01   -0.023889
# dtype: float64

# start fomr 1949-02-01 because of the lag by 1.

# covnert this to log scale:

# (1) Take cumulative sums

predictions_ARIMA_diff_cumsum = predictions_ARIMA_diff.cumsum()
print predictions_ARIMA_diff_cumsum.head()

# Month
# 1949-02-01    0.009580
# 1949-03-01    0.027071
# 1949-04-01    0.054742
# 1949-05-01    0.050221
# 1949-06-01    0.026331
# dtype: float64

# (2) Add to the base numbers

predictions_ARIMA_log = pd.Series(ts_log.ix[0], index = ts_log.index)
predictions_ARIMA_log = predictions_ARIMA_log.add(predictions_ARIMA_diff_cumsum, fill_value = 0)
print predictions_ARIMA_log.head()

# Month
# 1949-01-01    4.718499
# 1949-02-01    4.728079
# 1949-03-01    4.745570
# 1949-04-01    4.773240
# 1949-05-01    4.768720
# dtype: float64

# Take the exponent of this series and compare with the original series

predictions_ARIMA = np.exp(predictions_ARIMA_log)
plt.plot(ts)
plt.plot(predictions_ARIMA)
plt.title('RMSE: %.4f' % np.sqrt(sum((predictions_ARIMA - ts)**2)/len(ts)))
plt.show()


# This is a really shitty forecast. The RMSE is 90.1047.









