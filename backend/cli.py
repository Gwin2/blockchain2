import click
from contract_interaction import get_contract_instance, call_contract_function, send_transaction

@click.group()
def cli():
    """CLI для взаимодействия с Ethereum смарт-контрактами."""
    pass

@click.command()
@click.argument('contract_address')
@click.argument('abi')
def list_functions(contract_address, abi):
    """Перечислить все функции контракта."""
    contract = get_contract_instance(contract_address, abi)
    functions = contract.all_functions()
    for func in functions:
        click.echo(func.fn_name)

@click.command()
@click.argument('contract_address')
@click.argument('abi')
@click.argument('function_name')
@click.argument('args', nargs=-1)
def call(contract_address, abi, function_name, args):
    """Вызвать функцию контракта (только чтение)."""
    contract = get_contract_instance(contract_address, abi)
    result = call_contract_function(contract, function_name, *args)
    click.echo(f"Результат: {result}")

@click.command()
@click.argument('contract_address')
@click.argument('abi')
@click.argument('function_name')
@click.argument('args', nargs=-1)
def send(contract_address, abi, function_name, args):
    """Отправить транзакцию для изменения состояния контракта."""
    contract = get_contract_instance(contract_address, abi)
    txn_hash = send_transaction(contract, function_name, *args)
    click.echo(f"Транзакция отправлена с хэшем: {txn_hash}")

cli.add_command(list_functions)
cli.add_command(call)
cli.add_command(send)

if __name__ == '__main__':
    cli()
