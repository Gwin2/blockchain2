from web3 import Web3
import os

# Connect to Ethereum node
w3 = Web3(Web3.HTTPProvider(os.getenv('INFURA_URL')))

# Load private key from environment variable
private_key = os.getenv('PRIVATE_KEY')

# Function to get contract instance
def get_contract_instance(contract_address, abi):
    return w3.eth.contract(address=contract_address, abi=abi)

# Function to call a contract function (read-only)
def call_contract_function(contract, function_name, *args):
    func = getattr(contract.functions, function_name)(*args)
    return func.call()

# Function to send a transaction to a contract function
def send_transaction(contract, function_name, *args):
    nonce = w3.eth.getTransactionCount(w3.eth.defaultAccount)
    func = getattr(contract.functions, function_name)(*args)
    transaction = func.buildTransaction({
        'chainId': 1,  # Mainnet
        'gas': 2000000,
        'gasPrice': w3.toWei('50', 'gwei'),
        'nonce': nonce
    })
    signed_txn = w3.eth.account.signTransaction(transaction, private_key=private_key)
    txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    return txn_hash.hex()
