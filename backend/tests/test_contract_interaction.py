import pytest
from unittest.mock import patch, MagicMock
from pathlib import Path
from contract_interaction import ContractInteraction, get_contract_instance, call_contract_function, send_transaction

@pytest.fixture
def mock_web3(mocker):
    mock_web3 = mocker.patch('contract_interaction.w3')
    return mock_web3

@pytest.fixture
def mock_contract_addresses():
    return {
        'UniversityAccessControlProxy': '0x1',
        'CourseManagementProxy': '0x2',
        'GradeManagementProxy': '0x3',
        'ScheduleManagementProxy': '0x4',
        'StatisticsTrackerProxy': '0x5'
    }

@pytest.fixture
def mock_contract_abis():
    return {
        'UniversityAccessControl': [],
        'CourseManagement': [],
        'GradeManagement': [],
        'ScheduleManagement': [],
        'StatisticsTracker': []
    }

@pytest.fixture
def contract_interaction(mocker):
    # Mock environment variables
    mocker.patch.dict('os.environ', {
        'INFURA_URL': 'https://mock.infura.io',
        'PRIVATE_KEY': '0x' + '1' * 64
    })

    # Mock Web3 provider
    mock_w3 = MagicMock()
    mock_w3.eth.chain_id = 1
    mock_w3.eth.gas_price = 20000000000
    mocker.patch('web3.Web3.HTTPProvider', return_value=MagicMock())
    mocker.patch('web3.Web3', return_value=mock_w3)

    # Mock contract loading
    interaction = ContractInteraction()
    interaction._load_contract_addresses = MagicMock(return_value=mock_contract_addresses())
    interaction._load_contract_abis = MagicMock(return_value=mock_contract_abis())
    
    return interaction

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

@pytest.mark.asyncio
async def test_assign_role(contract_interaction):
    mock_tx_receipt = {'transactionHash': '0x123', 'status': 1}
    contract_interaction.contracts['access_control'].functions.assignRole().buildTransaction = MagicMock(
        return_value={'nonce': 0, 'chainId': 1, 'gas': 2000000, 'gasPrice': 20000000000}
    )
    contract_interaction.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt

    result = contract_interaction.assign_role('0xabc', 2)  # 2 for teacher role
    assert result == mock_tx_receipt

@pytest.mark.asyncio
async def test_create_course(contract_interaction):
    mock_tx_receipt = {'transactionHash': '0x123', 'status': 1}
    contract_interaction.contracts['course_management'].functions.createCourse().buildTransaction = MagicMock(
        return_value={'nonce': 0, 'chainId': 1, 'gas': 2000000, 'gasPrice': 20000000000}
    )
    contract_interaction.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt

    result = contract_interaction.create_course('Math 101', 'Introduction to Mathematics', 30)
    assert result == mock_tx_receipt

@pytest.mark.asyncio
async def test_record_grade(contract_interaction):
    mock_tx_receipt = {'transactionHash': '0x123', 'status': 1}
    contract_interaction.contracts['grade_management'].functions.recordGrade().buildTransaction = MagicMock(
        return_value={'nonce': 0, 'chainId': 1, 'gas': 2000000, 'gasPrice': 20000000000}
    )
    contract_interaction.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt

    result = contract_interaction.record_grade(1, '0xabc', 85)
    assert result == mock_tx_receipt

def test_get_course_details(contract_interaction):
    mock_course = {
        'id': 1,
        'name': 'Math 101',
        'description': 'Introduction to Mathematics',
        'instructor': '0x123',
        'capacity': 30,
        'enrolledStudents': 15
    }
    contract_interaction.contracts['course_management'].functions.getCourseDetails().call.return_value = mock_course

    result = contract_interaction.get_course_details(1)
    assert result == mock_course

def test_get_average_grade(contract_interaction):
    contract_interaction.contracts['statistics_tracker'].functions.getAverageGrade().call.return_value = 85

    result = contract_interaction.get_average_grade(1)
    assert result == 85

def test_get_attendance_rate(contract_interaction):
    contract_interaction.contracts['statistics_tracker'].functions.getAttendanceRate().call.return_value = 90

    result = contract_interaction.get_attendance_rate(1)
    assert result == 90

@pytest.mark.asyncio
async def test_create_schedule(contract_interaction):
    mock_tx_receipt = {'transactionHash': '0x123', 'status': 1}
    contract_interaction.contracts['schedule_management'].functions.createSchedule().buildTransaction = MagicMock(
        return_value={'nonce': 0, 'chainId': 1, 'gas': 2000000, 'gasPrice': 20000000000}
    )
    contract_interaction.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt

    result = contract_interaction.create_schedule(1, '2024-01-01', '10:00')
    assert result == mock_tx_receipt

def test_error_handling(contract_interaction):
    # Test contract call error
    contract_interaction.contracts['course_management'].functions.getCourseDetails().call.side_effect = Exception('Contract call failed')
    
    with pytest.raises(Exception) as exc_info:
        contract_interaction.get_course_details(1)
    assert str(exc_info.value) == 'Contract call failed'

    # Test transaction error
    contract_interaction.contracts['course_management'].functions.createCourse().buildTransaction.side_effect = Exception('Transaction failed')
    
    with pytest.raises(Exception) as exc_info:
        contract_interaction.create_course('Math 101', 'Introduction to Mathematics', 30)
    assert str(exc_info.value) == 'Transaction failed'
