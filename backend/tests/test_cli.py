import pytest
from click.testing import CliRunner
from cli import cli
from unittest.mock import patch, MagicMock

@pytest.fixture
def runner():
    return CliRunner()

@patch('contract_interaction.get_contract_instance')
def test_list_functions(mock_get_contract_instance, runner):
    mock_contract = MagicMock()
    mock_contract.all_functions.return_value = [MagicMock(fn_name='myFunction')]
    mock_get_contract_instance.return_value = mock_contract

    result = runner.invoke(cli, ['list-functions', '0x123', '[]'])
    assert result.exit_code == 0
    assert 'myFunction' in result.output

@patch('contract_interaction.call_contract_function')
def test_call_function(mock_call_contract_function, runner):
    mock_call_contract_function.return_value = 42

    result = runner.invoke(cli, ['call', '0x123', '[]', 'myFunction'])
    assert result.exit_code == 0
    assert 'Результат: 42' in result.output

@patch('contract_interaction.send_transaction')
def test_send_transaction(mock_send_transaction, runner):
    mock_send_transaction.return_value = 'tx_hash'

    result = runner.invoke(cli, ['send', '0x123', '[]', 'myFunction'])
    assert result.exit_code == 0
    assert 'Транзакция отправлена с хэшем: tx_hash' in result.output
