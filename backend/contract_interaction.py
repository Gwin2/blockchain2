import json
from web3 import Web3
import os
from pathlib import Path

class ContractInteraction:
    def __init__(self):
        # Connect to Ethereum node
        self.w3 = Web3(Web3.HTTPProvider(os.getenv('INFURA_URL')))
        
        # Load private key from environment variable
        self.private_key = os.getenv('PRIVATE_KEY')
        self.account = self.w3.eth.account.from_key(self.private_key)
        self.w3.eth.default_account = self.account.address

        # Load contract addresses
        self.addresses = self._load_contract_addresses()
        
        # Load contract ABIs
        self.abis = self._load_contract_abis()
        
        # Initialize contract instances
        self.contracts = self._initialize_contracts()

    def _load_contract_addresses(self):
        deployment_file = Path(__file__).parent.parent / '.deployed' / 'addresses.json'
        with open(deployment_file) as f:
            return json.load(f)

    def _load_contract_abis(self):
        artifacts_dir = Path(__file__).parent.parent / 'artifacts' / 'contracts'
        abis = {}
        
        contract_files = {
            'UniversityAccessControl': 'upgradeable/UniversityAccessControlUpgradeable.sol/UniversityAccessControlUpgradeable.json',
            'CourseManagement': 'upgradeable/CourseManagementUpgradeable.sol/CourseManagementUpgradeable.json',
            'GradeManagement': 'upgradeable/GradeManagementUpgradeable.sol/GradeManagementUpgradeable.json',
            'ScheduleManagement': 'upgradeable/ScheduleManagementUpgradeable.sol/ScheduleManagementUpgradeable.json',
            'StatisticsTracker': 'upgradeable/StatisticsTrackerUpgradeable.sol/StatisticsTrackerUpgradeable.json'
        }

        for contract_name, file_path in contract_files.items():
            with open(artifacts_dir / file_path) as f:
                contract_json = json.load(f)
                abis[contract_name] = contract_json['abi']
        
        return abis

    def _initialize_contracts(self):
        return {
            'access_control': self.w3.eth.contract(
                address=self.addresses['UniversityAccessControlProxy'],
                abi=self.abis['UniversityAccessControl']
            ),
            'course_management': self.w3.eth.contract(
                address=self.addresses['CourseManagementProxy'],
                abi=self.abis['CourseManagement']
            ),
            'grade_management': self.w3.eth.contract(
                address=self.addresses['GradeManagementProxy'],
                abi=self.abis['GradeManagement']
            ),
            'schedule_management': self.w3.eth.contract(
                address=self.addresses['ScheduleManagementProxy'],
                abi=self.abis['ScheduleManagement']
            ),
            'statistics_tracker': self.w3.eth.contract(
                address=self.addresses['StatisticsTrackerProxy'],
                abi=self.abis['StatisticsTracker']
            )
        }

    def _send_transaction(self, contract, function_name, *args):
        nonce = self.w3.eth.get_transaction_count(self.account.address)
        
        # Get the contract function
        contract_function = getattr(contract.functions, function_name)
        
        # Build the transaction
        transaction = contract_function(*args).build_transaction({
            'chainId': self.w3.eth.chain_id,
            'gas': 2000000,
            'gasPrice': self.w3.eth.gas_price,
            'nonce': nonce,
        })
        
        # Sign and send the transaction
        signed_txn = self.w3.eth.account.sign_transaction(transaction, self.private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        
        # Wait for transaction receipt
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        return tx_receipt

    # Access Control Functions
    def assign_role(self, address, role):
        return self._send_transaction(self.contracts['access_control'], 'assignRole', address, role)

    def has_role(self, role_hash, address):
        return self.contracts['access_control'].functions.hasRole(role_hash, address).call()

    # Course Management Functions
    def create_course(self, name, description, capacity):
        return self._send_transaction(
            self.contracts['course_management'],
            'createCourse',
            name,
            description,
            capacity
        )

    def enroll_in_course(self, course_id):
        return self._send_transaction(
            self.contracts['course_management'],
            'enrollInCourse',
            course_id
        )

    def get_course_details(self, course_id):
        return self.contracts['course_management'].functions.getCourseDetails(course_id).call()

    # Grade Management Functions
    def record_grade(self, course_id, student, grade):
        return self._send_transaction(
            self.contracts['grade_management'],
            'recordGrade',
            course_id,
            student,
            grade
        )

    def get_grades(self, course_id):
        return self.contracts['grade_management'].functions.getGrades(course_id).call()

    # Schedule Management Functions
    def create_schedule(self, course_id, date, time):
        return self._send_transaction(
            self.contracts['schedule_management'],
            'createSchedule',
            course_id,
            date,
            time
        )

    def get_schedule(self, course_id):
        return self.contracts['schedule_management'].functions.getSchedule(course_id).call()

    # Statistics Functions
    def get_average_grade(self, course_id):
        return self.contracts['statistics_tracker'].functions.getAverageGrade(course_id).call()

    def get_attendance_rate(self, course_id):
        return self.contracts['statistics_tracker'].functions.getAttendanceRate(course_id).call()

    def get_student_average_grade(self, course_id, student):
        return self.contracts['statistics_tracker'].functions.getAverageGradeByStudent(course_id, student).call()

    def get_student_attendance_rate(self, course_id, student):
        return self.contracts['statistics_tracker'].functions.getAttendanceRateByStudent(course_id, student).call()
