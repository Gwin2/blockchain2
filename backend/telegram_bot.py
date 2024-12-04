import os
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext
from contract_interaction import get_contract_instance, call_contract_function, send_transaction

# Получите токен вашего бота из переменной окружения
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')

def start(update: Update, context: CallbackContext) -> None:
    update.message.reply_text('Привет! Я ваш бот для взаимодействия с Ethereum контрактами.')

def call_function(update: Update, context: CallbackContext) -> None:
    try:
        contract_address = context.args[0]
        abi = context.args[1]
        function_name = context.args[2]
        args = context.args[3:]

        contract = get_contract_instance(contract_address, abi)
        result = call_contract_function(contract, function_name, *args)
        update.message.reply_text(f'Результат: {result}')
    except Exception as e:
        update.message.reply_text(f'Ошибка: {e}')

def send_transaction_command(update: Update, context: CallbackContext) -> None:
    try:
        contract_address = context.args[0]
        abi = context.args[1]
        function_name = context.args[2]
        args = context.args[3:]

        contract = get_contract_instance(contract_address, abi)
        txn_hash = send_transaction(contract, function_name, *args)
        update.message.reply_text(f'Транзакция отправлена с хэшем: {txn_hash}')
    except Exception as e:
        update.message.reply_text(f'Ошибка: {e}')

def main():
    updater = Updater(TELEGRAM_TOKEN)
    dispatcher = updater.dispatcher

    dispatcher.add_handler(CommandHandler("start", start))
    dispatcher.add_handler(CommandHandler("call", call_function))
    dispatcher.add_handler(CommandHandler("send", send_transaction_command))

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
