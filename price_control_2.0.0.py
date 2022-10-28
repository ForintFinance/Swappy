#!/usr/bin/env python3

# $$$$$$$\            $$\                            $$$$$$\                       $$\                         $$\ 
# $$  __$$\           \__|                          $$  __$$\                      $$ |                        $$ |
# $$ |  $$ | $$$$$$\  $$\  $$$$$$$\  $$$$$$\        $$ /  \__| $$$$$$\  $$$$$$$\ $$$$$$\    $$$$$$\   $$$$$$\  $$ |
# $$$$$$$  |$$  __$$\ $$ |$$  _____|$$  __$$\       $$ |      $$  __$$\ $$  __$$\\_$$  _|  $$  __$$\ $$  __$$\ $$ |
# $$  ____/ $$ |  \__|$$ |$$ /      $$$$$$$$ |      $$ |      $$ /  $$ |$$ |  $$ | $$ |    $$ |  \__|$$ /  $$ |$$ |
# $$ |      $$ |      $$ |$$ |      $$   ____|      $$ |  $$\ $$ |  $$ |$$ |  $$ | $$ |$$\ $$ |      $$ |  $$ |$$ |
# $$ |      $$ |      $$ |\$$$$$$$\ \$$$$$$$\       \$$$$$$  |\$$$$$$  |$$ |  $$ | \$$$$  |$$ |      \$$$$$$  |$$ |
# \__|      \__|      \__| \_______| \_______|       \______/  \______/ \__|  \__|  \____/ \__|       \______/ \__|
                                                                                                                 

def convert(token_1, decimal_1, token_2, decimal_2, amount, router, router_abi):
    token_1 = web3.toChecksumAddress(token_1)
    token_2 = web3.toChecksumAddress(token_2)
    dex_router_contract = web3.eth.contract(address=router, abi=dex_router_abi)
    val = dex_router_contract.functions.getAmountsOut(int(amount*(10**decimal_1)), [token_1,token_2]).call()
    price = 1/(1*(10**decimal_1))*(val[1]/(10**decimal_2))*(10**decimal_1)
    return price

def convert_dyst(token_1, decimal_1, token_2, decimal_2, amount, router, router_abi):
    token_1 = web3.toChecksumAddress(token_1)
    token_2 = web3.toChecksumAddress(token_2)
    dex_router_contract = web3.eth.contract(address=router, abi=dex_router_abi)
    stable_flag = False
    try:
        reserves_true = dex_router_contract.functions.getReserves(token_1, token_2, True).call()
        reserves_false = dex_router_contract.functions.getReserves(token_1, token_2, False).call()
    except:
        reserves_true = [0,0]
        reserves_false = dex_router_contract.functions.getReserves(token_1, token_2, False).call()
    #print('Riserva 1: ' + str(reserves_false[0]) + ' | ' + 'Riserva 2: ' + str(reserves_true[0]))
    if(reserves_false[0] >= reserves_true[0]):
        stable_flag_int = 0
        stable_flag = False
    else:
        stable_flag_int = 1
        stable_flag = True
        
    val = dex_router_contract.functions.getAmountsOut(int(amount*(10**decimal_1)), [(token_1,token_2,stable_flag)]).call()
    price = 1/(1*(10**decimal_1))*(val[1]/(10**decimal_2))*(10**decimal_1)
    return price, stable_flag_int

