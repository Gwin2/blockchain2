from flask import Flask, request, jsonify
from contract_interaction import get_contract_instance, call_contract_function, send_transaction

app = Flask(__name__)

@app.route('/list-functions', methods=['POST'])
def list_functions():
    data = request.json
    contract_address = data['contract_address']
    abi = data['abi']
    
    contract = get_contract_instance(contract_address, abi)
    functions = contract.all_functions()
    function_names = [func.fn_name for func in functions]
    return jsonify(function_names)

@app.route('/call', methods=['POST'])
def call_function():
    data = request.json
    contract_address = data['contract_address']
    abi = data['abi']
    function_name = data['function_name']
    args = data.get('args', [])
    
    contract = get_contract_instance(contract_address, abi)
    result = call_contract_function(contract, function_name, *args)
    return jsonify({'result': result})

@app.route('/send', methods=['POST'])
def send_transaction_api():
    data = request.json
    contract_address = data['contract_address']
    abi = data['abi']
    function_name = data['function_name']
    args = data.get('args', [])
    
    contract = get_contract_instance(contract_address, abi)
    txn_hash = send_transaction(contract, function_name, *args)
    return jsonify({'transaction_hash': txn_hash})

if __name__ == '__main__':
    app.run(debug=True)
