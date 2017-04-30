import math


def CalculateNStdDev(AllData,N,Ns,col):
    # calculate the mean (mu), standard deviation (sigma),
    # and number of std deviations from the mean (kappa)
    # based on N days for all Ns symbols
    # col is the column of yahoo finance data
    
    # 2D arrays
    # row: symbol, col: day
    Mu = []
    Sigma = []
    Kappa = []
    ### loop over all symbols
    for k in range(0,Ns):
        ### get the number of days of data
        N_days = len(AllData[k])

        # 1D arrays
        mu = []
        sigma = []
        kappa = []

        ### loop over all days
        for i_d in range(0,N_days):

            ### before i_d reaches N, put 0 in element
            if i_d < N:
                mu.append(0)
                sigma.append(0)
                kappa.append(0)
                continue
            
            ### get sum of prices and squares to calculate mean
            ### and std deviation
            sumOfPrices = 0
            sumOfSquares = 0

            ### loop to obtain sum of prices
            for n in range(0,N):
                sumOfPrices += AllData[k][i_d-n][col]

            ### calculate mean
            mu_ = sumOfPrices/N
            mu.append(mu_)

            ### loop to obtain sum of squares
            for n in range(0,N):
                sumOfSquares += (AllData[k][i_d-n][col] - mu_)**2

            ### calculate std dev
            sigma_ = math.sqrt(sumOfSquares/N)
            sigma.append(sigma_)

            ### calculate 
            kappa_ = (AllData[k][i_d][col]-mu_)/sigma_
            Kappa.append(kappa_)

        ### append to list
        Mu.append(mu)
        Sigma.append(sigma)
        Kappa.append(kappa)
            
    return (Mu,Sigma,Kappa)

