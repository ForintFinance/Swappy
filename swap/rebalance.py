# -*- coding: utf-8 -*-

from web3 import Web3
import MySQLdb
import time
import json

#DB CONFIG
dbuser              = "---"
dbpass              = ""---""

rifill_array        = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
amount_array        = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

#   Error List:
#       DB000000001 -> MySQL connection aborted
#       DB000000001 -> MySQL select aborted
    
try:
    db = MySQLdb.connect(""---"", dbuser, dbpass, ""---"")
    cursore = db.cursor()
    try:
        select_chains = "SELECT "---", "---", "---" FROM "---" ORDER BY "---" ASC"
        cursore.execute(select_chains)
        rifill_array        = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        amount_array        = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        nr_row              = 0
        amount_extra        = 0
        for row in cursore.fetchall():
            if row is not None:
                reading = row
                chain_id               = int(reading[0])
                rpc                    = str(reading[1])
                availability           = float(reading[2])
                
                print("Chain Id: " + str(chain_id) + " Amount : $" + str(availability))
                
                if(availability < 800):
                    print("Chain Id: " + str(chain_id) + " <- Rebalance In needed")
                    amount_extra = availability - 1000
                    print("Extra amount: $" + str(amount_extra))
                
                elif(availability > 1200):
                    print("Chain Id: " + str(chain_id) + " -> Rebalance Out needed")
                    amount_extra = availability - 1000
                    print("Extra amount: $" + str(amount_extra))
                    
                rifill_array[nr_row] = chain_id
                amount_array[nr_row] = amount_extra
                
                nr_row = nr_row + 1 
                
                print(rifill_array)
                print(amount_array)
                    
                print()
    except:
        print("DB000000002")
        pass
except:
    print("DB000000001")
    pass
