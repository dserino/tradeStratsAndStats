

class positionLot:
    """
    keeps track of a lot of positions
    """
    
    def __init__(self, \
                 cost,nShares,symbol, \
                 pProfit,pLoss,index):
        # cost:    total cost to buy for all shares
        # nShares: number of shares buying
        # symbol:  name of symbol
        # pProfit: sell shares if profit is more than pProfit times cost basis
        # pLoss:   sell shares if profit is less than pLoss times cost basis
        # index:   location in original symbols list

        # cost basis for lot, used to calculate capital gains
        self.cost_basis = cost

        # number of days position is held for
        self.days_held = 0

        # current value 1 share in lot
        self.current_value = cost/(nShares*1.0)

        # exit prices for selling stock
        self.exit_low = self.current_value*(1-pLoss)
        self.exit_high = self.current_value*(1+pProfit)

        # number of shares
        self.n_shares = nShares

        # symbol name 
        self.symbol = symbol

        # location in original list
        self.index = index
    
class unsettledFunds:
    """
    keeps tracks of funds before they are settled
    """

    def __init__(self,amount,days_left):
        # amount of funds
        self.amount = amount

        # days left before funds are released to bank
        self.days_left = days_left
