const request = require('supertest');
const express = require('express');
const app = require('../index');

// Mock the web3 and contract interactions
jest.mock('web3', () => {
  const mWeb3 = {
    eth: {
      getAccounts: jest.fn().mockResolvedValue(['0x123']),
      Contract: jest.fn(() => ({
        methods: {
          recordGrade: jest.fn(() => ({ send: jest.fn() })),
          markAttendance: jest.fn(() => ({ send: jest.fn() })),
          getGrades: jest.fn(() => ({ call: jest.fn().mockResolvedValue([]) })),
          getAttendance: jest.fn(() => ({ call: jest.fn().mockResolvedValue([]) })),
          createCourse: jest.fn(() => ({ send: jest.fn() })),
          enrollInCourse: jest.fn(() => ({ send: jest.fn() }))
        }
      }))
    }
  };
  return jest.fn(() => mWeb3);
});

app.use(express.json());

// Basic test for recordGrade endpoint
it('should record a grade', async () => {
  const response = await request(app)
    .post('/recordGrade')
    .send({ courseId: 1, student: '0x456', grade: 90 });
  expect(response.statusCode).toBe(200);
  expect(response.text).toBe('Grade recorded for student 0x456 in course 1.');
});

// Basic test for markAttendance endpoint
it('should mark attendance', async () => {
  const response = await request(app)
    .post('/markAttendance')
    .send({ courseId: 1, student: '0x456', attended: true });
  expect(response.statusCode).toBe(200);
  expect(response.text).toBe('Attendance marked for student 0x456 in course 1.');
});

// Basic test for getGrades endpoint
it('should get grades', async () => {
  const response = await request(app)
    .get('/getGrades/1');
  expect(response.statusCode).toBe(200);
  expect(response.body).toEqual([]);
});

// Basic test for getAttendance endpoint
it('should get attendance', async () => {
  const response = await request(app)
    .get('/getAttendance/1');
  expect(response.statusCode).toBe(200);
  expect(response.body).toEqual([]);
});

// Basic test for createCourse endpoint
it('should create a course', async () => {
  const response = await request(app)
    .post('/createCourse')
    .send({ name: 'Math 101', description: 'Basic Math', capacity: 30 });
  expect(response.statusCode).toBe(200);
  expect(response.text).toBe('Course created with name Math 101.');
});

// Basic test for enrollInCourse endpoint
it('should enroll in a course', async () => {
  const response = await request(app)
    .post('/enrollInCourse')
    .send({ courseId: 1 });
  expect(response.statusCode).toBe(200);
  expect(response.text).toBe('Enrolled in course with ID 1.');
});
