import pytest
from unittest.mock import patch, MagicMock
from contract_interaction import get_contract_instance, call_contract_function, send_transaction

@pytest.fixture
def mock_web3(mocker):
    mock_web3 = mocker.patch('contract_interaction.w3')
    return mock_web3

def test_get_contract_instance(mock_web3):
    mock_contract = MagicMock()
    mock_web3.eth.contract.return_value = mock_contract
    contract = get_contract_instance('0x123', '[]')
    assert contract == mock_contract

def test_call_contract_function(mock_web3):
    mock_function = MagicMock()
    mock_contract = MagicMock()
    mock_contract.functions.myFunction.return_value = mock_function
    mock_function.call.return_value = 42

    result = call_contract_function(mock_contract, 'myFunction')
    assert result == 42
    mock_function.call.assert_called_once()

def test_send_transaction(mock_web3):
    mock_function = MagicMock()
    mock_contract = MagicMock()
    mock_contract.functions.myFunction.return_value = mock_function
    mock_function.buildTransaction.return_value = {'nonce': 0}

    mock_web3.eth.getTransactionCount.return_value = 0
    mock_web3.eth.account.signTransaction.return_value = MagicMock(rawTransaction=b'raw_tx')
    mock_web3.eth.sendRawTransaction.return_value = b'tx_hash'

    txn_hash = send_transaction(mock_contract, 'myFunction')
    assert txn_hash == '74785f68617368'  # hex representation of 'tx_hash'
