import pandas as pd
import numpy as np
import matplotlib.pylab as plt
from statsmodels.tsa.stattools import adfuller


def test_stationarity(timeseries):

	# Determine rolling statistics

	rolmean = pd.rolling_mean(timeseries, window = 12) # Take a rolling stat over the last twelve time-units (in our case, it is months)
	rolstd = pd.rolling_std(timeseries, window = 12)

	# Plot rolling stat
	orig = plt.plot(timeseries, color = 'blue', label = 'Original')
	mean = plt.plot(rolmean, color = 'red', label = 'Rolling Mean')
	std = plt.plot(rolstd, color = 'black', label = 'Rolling STD')
	plt.legend(loc = 'best')
	plt.title ('Rolling Mean & Standard Deviation')
	plt.show(block = True)


	# Dickey-Fuller Test
	print 'Results of Dickey-Fuller Tests:\n'
	dftest = adfuller(timeseries, autolag = 'AIC')
	dfoutput = pd.Series(dftest[0:4], index = ['Test Statistic','p-value','#Lags Used','Number of Observations Used'])
	for key, value in dftest[4].items():
		dfoutput['Critical Value (%s)' % key] = value
	print dfoutput