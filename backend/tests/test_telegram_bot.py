import pytest
from unittest.mock import patch, MagicMock
from telegram import Update
from telegram.ext import CallbackContext
from telegram_bot import start, call_function, send_transaction_command

@pytest.fixture
def update():
    return MagicMock(spec=Update)

@pytest.fixture
def context():
    return MagicMock(spec=CallbackContext)

def test_start(update, context):
    start(update, context)
    update.message.reply_text.assert_called_with('Привет! Я ваш бот для взаимодействия с Ethereum контрактами.')

@patch('telegram_bot.get_contract_instance')
@patch('telegram_bot.call_contract_function')
def test_call_function(mock_call_contract_function, mock_get_contract_instance, update, context):
    mock_get_contract_instance.return_value = MagicMock()
    mock_call_contract_function.return_value = 42
    context.args = ['0x123', '[]', 'myFunction']

    call_function(update, context)
    update.message.reply_text.assert_called_with('Результат: 42')

@patch('telegram_bot.get_contract_instance')
@patch('telegram_bot.send_transaction')
def test_send_transaction_command(mock_send_transaction, mock_get_contract_instance, update, context):
    mock_get_contract_instance.return_value = MagicMock()
    mock_send_transaction.return_value = 'tx_hash'
    context.args = ['0x123', '[]', 'myFunction']

    send_transaction_command(update, context)
    update.message.reply_text.assert_called_with('Транзакция отправлена с хэшем: tx_hash')
