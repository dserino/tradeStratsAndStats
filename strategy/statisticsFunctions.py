import math
import sys

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
            kappa.append(kappa_)

        ### append to list
        Mu.append(mu)
        Sigma.append(sigma)
        Kappa.append(kappa)
            
    return (Mu,Sigma,Kappa)


def checkDates(AllData,Symbols,Ns):
    print ">> checking symbols trade every day"
    N = len(AllData[0])
    for n_date in range(0,N):
        dateCheck = AllData[0][n_date][0]
        for k in range(1,Ns):
            try:
                if AllData[k][n_date][0] != dateCheck:
                    print ">> Dates do not match..."
                    print ">> symbol: "+Symbols[k]
                    print ">> date:   "+dateCheck
            except:
                print ">> error checking dates"
                sys.exit()

    print ">> dates agree for each symbol"
        
    pass




def GetScores(Kappa,n,minBuyScore,Nbuy,Ns):

    # score calculated from kappa
    # lower kappa is a higher score

    # make a list of all kappas
    kappa_ = []
    for k in range(0,Ns):
        kappa_.append(Kappa[k][n])
    
    K_min = min(kappa_)
    K_max = max(kappa_)

    s_K = []
    for k in range(0,Ns):
        if K_min == K_max:
            s_K.append( 0.0 )
        else:
            s_K.append( (Kappa[k][n]-K_max)/(K_min-K_max) )

    # sort scores
    perm = sorted(range(len(s_K)), key=lambda k: s_K[k])

    # if kappa is lower than minimum, than we can buy
    Nbuy_true = 0
    for k in range(0,Nbuy):
        if Kappa[perm[k]] < minBuyScore:
            Nbuy_true += 1
        
    
    return (s_K,perm,Nbuy_true)
