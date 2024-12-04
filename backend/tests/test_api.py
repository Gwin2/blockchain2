import pytest
from flask import Flask
from flask.testing import FlaskClient
from unittest.mock import patch, MagicMock
from api import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@patch('contract_interaction.get_contract_instance')
def test_list_functions(mock_get_contract_instance, client: FlaskClient):
    mock_contract = MagicMock()
    mock_contract.all_functions.return_value = [MagicMock(fn_name='myFunction')]
    mock_get_contract_instance.return_value = mock_contract

    response = client.post('/list-functions', json={'contract_address': '0x123', 'abi': '[]'})
    assert response.status_code == 200
    assert response.json == ['myFunction']

@patch('contract_interaction.call_contract_function')
def test_call_function(mock_call_contract_function, client: FlaskClient):
    mock_call_contract_function.return_value = 42

    response = client.post('/call', json={'contract_address': '0x123', 'abi': '[]', 'function_name': 'myFunction'})
    assert response.status_code == 200
    assert response.json == {'result': 42}

@patch('contract_interaction.send_transaction')
def test_send_transaction(mock_send_transaction, client: FlaskClient):
    mock_send_transaction.return_value = 'tx_hash'

    response = client.post('/send', json={'contract_address': '0x123', 'abi': '[]', 'function_name': 'myFunction'})
    assert response.status_code == 200
    assert response.json == {'transaction_hash': 'tx_hash'}
