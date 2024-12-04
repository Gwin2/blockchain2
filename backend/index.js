#!/usr/bin/env node

const express = require('express');
const Web3 = require('web3');
const { abi, address } = require('./contracts/GradeManagement');

const app = express();
app.use(express.json());

const web3 = new Web3('http://localhost:8545');
const contract = new web3.eth.Contract(abi, address);

app.post('/recordGrade', async (req, res) => {
  const { courseId, student, grade } = req.body;
  try {
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];
    await contract.methods.recordGrade(courseId, student, grade).send({ from: sender });
    res.status(200).send(`Grade recorded for student ${student} in course ${courseId}.`);
  } catch (error) {
    res.status(500).send('Error recording grade');
  }
});

app.post('/markAttendance', async (req, res) => {
  const { courseId, student, attended } = req.body;
  try {
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];
    await contract.methods.markAttendance(courseId, student, attended).send({ from: sender });
    res.status(200).send(`Attendance marked for student ${student} in course ${courseId}.`);
  } catch (error) {
    res.status(500).send('Error marking attendance');
  }
});

app.get('/getGrades/:courseId', async (req, res) => {
  const { courseId } = req.params;
  try {
    const grades = await contract.methods.getGrades(courseId).call();
    res.status(200).json(grades);
  } catch (error) {
    res.status(500).send('Error retrieving grades');
  }
});

app.get('/getAttendance/:courseId', async (req, res) => {
  const { courseId } = req.params;
  try {
    const attendance = await contract.methods.getAttendance(courseId).call();
    res.status(200).json(attendance);
  } catch (error) {
    res.status(500).send('Error retrieving attendance');
  }
});

app.post('/createCourse', async (req, res) => {
  const { name, description, capacity } = req.body;
  try {
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];
    await contract.methods.createCourse(name, description, capacity).send({ from: sender });
    res.status(200).send(`Course created with name ${name}.`);
  } catch (error) {
    res.status(500).send('Error creating course');
  }
});

app.post('/enrollInCourse', async (req, res) => {
  const { courseId } = req.body;
  try {
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];
    await contract.methods.enrollInCourse(courseId).send({ from: sender });
    res.status(200).send(`Enrolled in course with ID ${courseId}.`);
  } catch (error) {
    res.status(500).send('Error enrolling in course');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
