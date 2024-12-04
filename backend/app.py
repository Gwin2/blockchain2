from flask import Flask, render_template, request, redirect, url_for, flash
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import DataRequired
from contract_interaction import get_contract_instance, call_contract_function, send_transaction

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

class ContractForm(FlaskForm):
    contract_address = StringField('Contract Address', validators=[DataRequired()])
    abi = TextAreaField('ABI', validators=[DataRequired()])
    function_name = StringField('Function Name', validators=[DataRequired()])
    args = StringField('Arguments (comma-separated)')
    submit_call = SubmitField('Call Function')
    submit_send = SubmitField('Send Transaction')

@app.route('/', methods=['GET', 'POST'])
def index():
    form = ContractForm()
    if form.validate_on_submit():
        contract_address = form.contract_address.data
        abi = form.abi.data
        function_name = form.function_name.data
        args = form.args.data.split(',')

        contract = get_contract_instance(contract_address, abi)
        if form.submit_call.data:
            try:
                result = call_contract_function(contract, function_name, *args)
                flash(f'Result: {result}', 'success')
            except Exception as e:
                flash(f'Error calling function: {e}', 'danger')
        elif form.submit_send.data:
            try:
                txn_hash = send_transaction(contract, function_name, *args)
                flash(f'Transaction sent with hash: {txn_hash}', 'success')
            except Exception as e:
                flash(f'Error sending transaction: {e}', 'danger')

        return redirect(url_for('index'))

    return render_template('index.html', form=form)

if __name__ == '__main__':
    app.run(debug=True)
