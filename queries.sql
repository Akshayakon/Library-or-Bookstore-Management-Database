-- Library Management Database : analysis queries
-- Run:  python run.py   (executes everything and prints each result)

-- Q1. Which books are overdue?
SELECT l.loan_id, b.title,
       m.first_name || ' ' || m.last_name AS member,
       l.due_date,
       CAST(julianday(date('now')) - julianday(l.due_date) AS INTEGER) AS days_overdue
FROM loans l
JOIN books b   ON b.book_id = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL AND l.due_date < date('now')
ORDER BY days_overdue DESC;

-- Q2. Who borrowed the most?
SELECT m.member_id, m.first_name || ' ' || m.last_name AS member, COUNT(*) AS total_loans
FROM members m
JOIN loans l ON l.member_id = m.member_id
GROUP BY m.member_id
ORDER BY total_loans DESC, member
LIMIT 5;

-- Q3. Most borrowed books
SELECT b.title, COUNT(*) AS times_borrowed
FROM books b JOIN loans l ON l.book_id = b.book_id
GROUP BY b.book_id
ORDER BY times_borrowed DESC, b.title
LIMIT 5;

-- Q4. Books with their authors (many-to-many join)
SELECT b.title, GROUP_CONCAT(a.first_name || ' ' || a.last_name, ', ') AS authors
FROM books b
JOIN book_authors ba ON ba.book_id = b.book_id
JOIN authors a       ON a.author_id = ba.author_id
GROUP BY b.book_id
ORDER BY b.title;

-- Q5. Books currently checked out, and by whom
SELECT b.title, m.first_name || ' ' || m.last_name AS borrower, l.loan_date, l.due_date
FROM loans l
JOIN books b   ON b.book_id = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL
ORDER BY l.due_date;

-- Q6. Late fees owed on overdue loans at $0.25/day
SELECT m.first_name || ' ' || m.last_name AS member,
       SUM(CAST(julianday(date('now')) - julianday(l.due_date) AS INTEGER)) AS total_days_overdue,
       printf('$%.2f', 0.25 * SUM(CAST(julianday(date('now')) - julianday(l.due_date) AS INTEGER))) AS fee
FROM loans l JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL AND l.due_date < date('now')
GROUP BY m.member_id
ORDER BY total_days_overdue DESC;

-- Q7. Members who have never borrowed (LEFT JOIN + NULL check)
SELECT m.first_name || ' ' || m.last_name AS member, m.status
FROM members m
LEFT JOIN loans l ON l.member_id = m.member_id
WHERE l.loan_id IS NULL;

-- Q8. Authors whose books are borrowed most
SELECT a.first_name || ' ' || a.last_name AS author, COUNT(l.loan_id) AS loans
FROM authors a
JOIN book_authors ba ON ba.author_id = a.author_id
JOIN loans l         ON l.book_id = ba.book_id
GROUP BY a.author_id
ORDER BY loans DESC, author
LIMIT 5;

-- Q9. Loans per genre
SELECT b.genre, COUNT(*) AS loans
FROM loans l JOIN books b ON b.book_id = l.book_id
GROUP BY b.genre
ORDER BY loans DESC;

-- Q10. Books that were returned late, with days late
SELECT b.title, m.last_name AS member, l.due_date, l.return_date,
       CAST(julianday(l.return_date) - julianday(l.due_date) AS INTEGER) AS days_late
FROM loans l
JOIN books b   ON b.book_id = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE l.return_date > l.due_date
ORDER BY days_late DESC;

-- Q11. Members with more than one overdue book (HAVING)
SELECT m.first_name || ' ' || m.last_name AS member, COUNT(*) AS overdue_books
FROM loans l JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL AND l.due_date < date('now')
GROUP BY m.member_id
HAVING COUNT(*) > 1;

-- Q12. Inventory check: books with no copies available
SELECT title, copies_total, copies_available FROM books WHERE copies_available = 0;
-- (Animal Farm shows here: both copies are on loan.)

-- Q13. Monthly loan volume
SELECT strftime('%Y-%m', loan_date) AS month, COUNT(*) AS loans
FROM loans GROUP BY month ORDER BY month;

-- Q14. Using the view
SELECT * FROM v_overdue_loans ORDER BY days_overdue DESC;
