try:
    db = MySQLdb.connect(""---"", dbuser, dbpass, ""---"")
    cursore = db.cursor()
    try:
        select_chains = "SELECT "---", "---", "---" FROM "---" ORDER BY "---" ASC"
        cursore.execute(select_chains)
        
        rifill_array        = []
        amount_array        = []
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
                    
                rifill_array.append(chain_id)
                amount_array.append(amount_extra)
                
                print(rifill_array)
                print(amount_array)
                    
                print()
    except:
        print("DB000000002")
        pass
except:
    print("DB000000001")
    pass
