import pytest
from flask import Flask
from flask.testing import FlaskClient
from unittest.mock import patch, MagicMock
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@patch('contract_interaction.get_contract_instance')
@patch('contract_interaction.call_contract_function')
def test_call_function(mock_call_contract_function, mock_get_contract_instance, client: FlaskClient):
    mock_contract = MagicMock()
    mock_get_contract_instance.return_value = mock_contract
    mock_call_contract_function.return_value = 42

    response = client.post('/', data={
        'contract_address': '0x123',
        'abi': '[]',
        'function_name': 'myFunction',
        'args': '',
        'submit_call': True
    })

    assert response.status_code == 302  # Redirect after POST
    assert b'Result: 42' in response.data

@patch('contract_interaction.get_contract_instance')
@patch('contract_interaction.send_transaction')
def test_send_transaction(mock_send_transaction, mock_get_contract_instance, client: FlaskClient):
    mock_contract = MagicMock()
    mock_get_contract_instance.return_value = mock_contract
    mock_send_transaction.return_value = 'tx_hash'

    response = client.post('/', data={
        'contract_address': '0x123',
        'abi': '[]',
        'function_name': 'myFunction',
        'args': '',
        'submit_send': True
    })

    assert response.status_code == 302  # Redirect after POST
    assert b'Transaction sent with hash: tx_hash' in response.data
