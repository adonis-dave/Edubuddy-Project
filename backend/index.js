// server.js - Node.js with Express backend for EduBuddy

const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

db.connect(err => {
    if (err) {
        console.error('Database connection failed: ' + err.stack);
        return;
    }
    console.log('Connected to database.');
});

// Register User
app.post('/api/register', (req, res) => {
    const { username, password, grade } = req.body;
    const query = 'INSERT INTO users (username, password, grade) VALUES (?, ?, ?)';
    db.query(query, [username, password, grade], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.json({ success: false, message: 'Username already exists.' });
            }
            return res.json({ success: false, message: 'Registration failed.' });
        }
        res.json({ success: true });
    });
});

// Login User
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    const query = 'SELECT id, username, grade FROM users WHERE username = ? AND password = ?';
    db.query(query, [username, password], (err, results) => {
        if (err || results.length === 0) {
            return res.json({ success: false, message: 'Invalid credentials.' });
        }
        res.json({ success: true, userId: results[0].id, grade: results[0].grade });
    });
});

// Get Topic Content and Record Download
app.get('/api/topics/:topic', (req, res) => {
    const { topic } = req.params;
    const { userId } = req.query;
    const queryTopic = 'SELECT id, content FROM topics WHERE name = ?';
    db.query(queryTopic, [topic], (err, results) => {
        if (err || results.length === 0) {
            return res.json({ content: null });
        }
        const topicId = results[0].id;
        const content = results[0].content;

        // Record download
        const queryDownload = 'INSERT INTO user_downloads (user_id, topic_id) VALUES (?, ?)';
        db.query(queryDownload, [userId, topicId], (err) => {
            if (err) console.error('Download record failed.');
        });

        res.json({ content });
    });
});

// Clear Downloads for User
app.post('/api/clear-downloads', (req, res) => {
    const { userId } = req.body;
    const query = 'DELETE FROM user_downloads WHERE user_id = ?';
    db.query(query, [userId], (err) => {
        if (err) {
            return res.json({ success: false });
        }
        res.json({ success: true });
    });
});

// Get Quiz Questions
app.get('/api/quizzes/:subject', (req, res) => {
    const { subject } = req.params;
    const querySubject = 'SELECT id FROM subjects WHERE name = ?';
    db.query(querySubject, [subject], (err, subjectResults) => {
        if (err || subjectResults.length === 0) {
            return res.json({ questions: [] });
        }
        const subjectId = subjectResults[0].id;
        const queryQuiz = 'SELECT id, title FROM quizzes WHERE subject_id = ?';
        db.query(queryQuiz, [subjectId], (err, quizResults) => {
            if (err || quizResults.length === 0) {
                return res.json({ questions: [] });
            }
            const quizId = quizResults[0].id; // Assuming one quiz per subject for simplicity
            const queryQuestions = 'SELECT question, options, correct_answer AS answer FROM quiz_questions WHERE quiz_id = ?';
            db.query(queryQuestions, [quizId], (err, questions) => {
                if (err) {
                    return res.json({ questions: [] });
                }
                res.json({ questions: questions.map(q => ({ ...q, options: JSON.parse(q.options) })) });
            });
        });
    });
});

// Save Quiz Result
app.post('/api/quiz-results', (req, res) => {
    const { userId, quizTitle, score, total } = req.body;
    // For simplicity, assuming a user_quiz_results table (add it to schema if needed)
    const query = 'INSERT INTO user_quiz_results (user_id, quiz_title, score, total_questions) VALUES (?, ?, ?, ?)';
    db.query(query, [userId, quizTitle, score, total], (err) => {
        if (err) {
            return res.json({ success: false });
        }
        res.json({ success: true });
    });
});

// Sync Data
app.get('/api/sync', (req, res) => {
    const { userId } = req.query;
    // Fetch user's downloads
    const queryDownloads = `
        SELECT t.name 
        FROM user_downloads ud 
        JOIN topics t ON ud.topic_id = t.id 
        WHERE ud.user_id = ?
    `;
    db.query(queryDownloads, [userId], (err, downloadResults) => {
        if (err) {
            return res.json({ downloads: [], lessons: {}, quizzes: {} });
        }
        const userDownloads = downloadResults.map(row => row.name);

        // Fetch all lessons
        const queryLessons = 'SELECT name, content FROM topics';
        db.query(queryLessons, (err, lessonResults) => {
            if (err) {
                return res.json({ downloads: [], lessons: {}, quizzes: {} });
            }
            const lessonsObj = {};
            lessonResults.forEach(row => {
                if (userDownloads.includes(row.name)) {
                    lessonsObj[row.name] = row.content;
                }
            });

            // Fetch all quizzes (simplified for Biology and Geography)
            const queryQuizzes = `
                SELECT s.name AS subject, qq.question, qq.options, qq.correct_answer AS answer
                FROM subjects s
                JOIN quizzes q ON s.id = q.subject_id
                JOIN quiz_questions qq ON q.id = qq.quiz_id
            `;
            db.query(queryQuizzes, (err, quizResults) => {
                if (err) {
                    return res.json({ downloads: [], lessons: {}, quizzes: {} });
                }
                const quizzesObj = {};
                quizResults.forEach(row => {
                    if (!quizzesObj[row.subject]) quizzesObj[row.subject] = [];
                    quizzesObj[row.subject].push({
                        question: row.question,
                        options: JSON.parse(row.options),
                        answer: row.answer
                    });
                });

                res.json({ downloads: userDownloads, lessons: lessonsObj, quizzes: quizzesObj });
            });
        });
    });
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});