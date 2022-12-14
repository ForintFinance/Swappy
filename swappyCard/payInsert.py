#!/usr/bin/env python3

import stripe
import datetime 
import requests
import MySQLdb

#  $$$$$$\ $$$$$$$$\ $$$$$$$\  $$$$$$\ $$$$$$$\  $$$$$$$$\       $$$$$$$\   $$$$$$\ $$\     $$\       $$$$$$\ $$\   $$\  $$$$$$\  $$$$$$$$\ $$$$$$$\ $$$$$$$$\ 
# $$  __$$\\__$$  __|$$  __$$\ \_$$  _|$$  __$$\ $$  _____|      $$  __$$\ $$  __$$\\$$\   $$  |      \_$$  _|$$$\  $$ |$$  __$$\ $$  _____|$$  __$$\\__$$  __|
# $$ /  \__|  $$ |   $$ |  $$ |  $$ |  $$ |  $$ |$$ |            $$ |  $$ |$$ /  $$ |\$$\ $$  /         $$ |  $$$$\ $$ |$$ /  \__|$$ |      $$ |  $$ |  $$ |   
# \$$$$$$\    $$ |   $$$$$$$  |  $$ |  $$$$$$$  |$$$$$\          $$$$$$$  |$$$$$$$$ | \$$$$  /          $$ |  $$ $$\$$ |\$$$$$$\  $$$$$\    $$$$$$$  |  $$ |   
#  \____$$\   $$ |   $$  __$$<   $$ |  $$  ____/ $$  __|         $$  ____/ $$  __$$ |  \$$  /           $$ |  $$ \$$$$ | \____$$\ $$  __|   $$  __$$<   $$ |   
# $$\   $$ |  $$ |   $$ |  $$ |  $$ |  $$ |      $$ |            $$ |      $$ |  $$ |   $$ |            $$ |  $$ |\$$$ |$$\   $$ |$$ |      $$ |  $$ |  $$ |   
# \$$$$$$  |  $$ |   $$ |  $$ |$$$$$$\ $$ |      $$$$$$$$\       $$ |      $$ |  $$ |   $$ |          $$$$$$\ $$ | \$$ |\$$$$$$  |$$$$$$$$\ $$ |  $$ |  $$ |   
#  \______/   \__|   \__|  \__|\______|\__|      \________|      \__|      \__|  \__|   \__|          \______|\__|  \__| \______/ \________|\__|  \__|  \__|   

dbuser              = "---"
dbpass              = "---'
stripe.api_key      = "---"


#   Error List:
#       S000000001 -> Stripe connection aborted
#       S000000002 -> MySQL connection aborted
#       S000000003 -> Fail to catch GBP conversion rate
#       S000000004 -> Check idPayment on DB fail
#       S000000005 -> Fail to insert Tx on DB
#       S000000006 -> Check Account on DB fail
#       S000000007 -> Fail to insert Account on DB

#   TX Status List:
#       1 -> Tx inserted
#       2 -> Tx Blocked
#       3 -> Tx Refunded
#       4 -> Key generated

#   Account Status List:
#       0 -> Free move
#       1 -> KYC request
#       2 -> KYC approved
#       3 -> KYC Refused
#       4 -> AML request
#       5 -> AML approved
#       6 -> AML refused
#       7 -> Max Amount reached


while True:
    
    try:
        payments                                                = stripe.PaymentIntent.list()
        
        if(len(payments.data) > 0):
            print("Found " + str(len(payments.data)) + "payments")
            
            try:
                db = MySQLdb.connect("localhost", dbuser, dbpass, "---")
                cursore = db.cursor()
                
                try:
                    gbpPrice                                    = requests.get("https://api.binance.com/api/v1/ticker/price?symbol=GBPUSDT")
                    gbpPrice                                    = gbpPrice.json()
                    gbpPrice                                    = float(gbpPrice['price'])
                    
                    for i in range(len((payments.data))):
                        idPayment                               = str(payments.data[i].id)
                        #check if id payment is present in DB
                        
                        try:
                            checkPayment = "SELECT email, country, totalSwapped, state FROM --- WHERE idPayment = '%s'"
                            cursore.execute(checkPayment % (idPayment))
                            row = cursore.fetchone()
                            
                            if row is None:
                                
                                print("Payment not present")
                                paymentStatus                   = payments.data[i].status
                                email                           = payments.data[i].customer
                                email                           = stripe.Customer.retrieve(email).email
                                
                                try:
                                    country                     = payments.data[i].charges.data[0].billing_details.address.country
                                    riskScore                   = payments.data[i].charges.data[0].outcome.risk_score
                                    refunded                    = payments.data[i].charges.data[0].refunded
                                    
                                except:
                                    country                     = "none"
                                    riskScore                   = "none"
                                    refunded                    = "none"
                                
                                if(country != "none"):    
                                    
                                    if(payments.data[i].status == "succeeded"):
                                        
                                        amount                  = round(payments.data[i].amount/100,2)
                                        fee                     = round(amount * 0.05,2              )
                                        
                                        amountUsd               = round(amount * gbpPrice,2)
                                        feeUsd                  = round(amountUsd * 0.05,2)
                                        giftCardAmount          = round(amountUsd-(amountUsd * 0.05),2)
                                        
                                        currency                = str(payments.data[i].currency)
                                        dateTime                = str(datetime.datetime.fromtimestamp(payments.data[i].created))
                                        
                                        print("Amount: " + currency + " " + str(amount) + " Fee: " + currency + " " + str(fee))
                                        print("Amount: usd " + str(amountUsd) + " Fee: usd " + str(feeUsd))
                                        print("Gift Card Amount: usdt " + str(giftCardAmount))
                                        print("Date: " + dateTime)
                                        
                                        try:
                                            checkPayment = "SELECT * FROM --- WHERE email = '%s'"
                                            cursore.execute(checkPayment % (email))
                                            row = cursore.fetchone()
                                            
                                            if row is None:
                                                try:
                                                    insertQuery = """INSERT INTO --- (email, country) VALUES (%s, %s)"""
                                                    cursore.execute(insertQuery % (email, country))
                                                    cursore.commit()
                                                    print("Insert Account")
                                                    
                                                except:
                                                    cursore.rollback()
                                                    print("Error S000000007")
                                                    pass  
                                                
                                        except:
                                            print("Error S000000006")
                                            pass   

                                        try:
                                            insertQuery = """INSERT INTO --- (email, country, amount, state) VALUES (%s, %s, %s, %s)"""
                                            cursore.execute(insertQuery % (email, country, giftCardAmount, 0))
                                            cursore.commit()
                                            print("Insert TX")
                                            
                                        except:
                                            cursore.rollback()
                                            print("Error S000000005")
                                            pass  
                                        
                        except:
                            print("Error S000000004")
                            pass    
                        
                except:
                    print("Error S000000003")
                    pass
                
            except:
                print("Error S000000002")
                pass
            
    except:
        print("Error S000000001")
        pass
        

