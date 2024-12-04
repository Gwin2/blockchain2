const Web3 = require('web3');
const { abi, address } = require('../contracts/GradeManagement');

async function recordGrade(courseId, student, grade) {
  const web3 = new Web3('http://localhost:8545');
  const contract = new web3.eth.Contract(abi, address);

  const accounts = await web3.eth.getAccounts();
  const sender = accounts[0];

  await contract.methods.recordGrade(courseId, student, grade).send({ from: sender });
  console.log(`Grade recorded for student ${student} in course ${courseId}.`);
}

module.exports = recordGrade;
