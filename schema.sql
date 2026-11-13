-- Library Management Database : schema (SQLite)
PRAGMA foreign_keys = ON;

DROP VIEW  IF EXISTS v_overdue_loans;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
    author_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    country     TEXT,
    birth_year  INTEGER CHECK (birth_year BETWEEN 1000 AND 2100)
);

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    isbn             TEXT NOT NULL UNIQUE,
    title            TEXT NOT NULL,
    genre            TEXT,
    published_year   INTEGER,
    copies_total     INTEGER NOT NULL DEFAULT 1 CHECK (copies_total >= 0),
    copies_available INTEGER NOT NULL DEFAULT 1 CHECK (copies_available >= 0),
    CHECK (copies_available <= copies_total)
);

-- Many-to-many: a book can have several authors, an author several books.
CREATE TABLE book_authors (
    book_id   INTEGER NOT NULL REFERENCES books(book_id)     ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES authors(author_id) ON DELETE RESTRICT,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE members (
    member_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT,
    join_date   TEXT NOT NULL DEFAULT (date('now')),
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','expired'))
);

CREATE TABLE loans (
    loan_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id       INTEGER NOT NULL REFERENCES books(book_id)     ON DELETE RESTRICT,
    member_id     INTEGER NOT NULL REFERENCES members(member_id) ON DELETE RESTRICT,
    loan_date     TEXT NOT NULL,
    due_date      TEXT NOT NULL,
    return_date   TEXT,                       -- NULL = still checked out
    CHECK (due_date >= loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);

CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_book   ON loans(book_id);
CREATE INDEX idx_loans_open   ON loans(due_date) WHERE return_date IS NULL;

-- Keep copies_available in sync automatically.
CREATE TRIGGER trg_loan_checkout AFTER INSERT ON loans
WHEN NEW.return_date IS NULL
BEGIN
    UPDATE books SET copies_available = copies_available - 1 WHERE book_id = NEW.book_id;
END;

CREATE TRIGGER trg_loan_return AFTER UPDATE OF return_date ON loans
WHEN OLD.return_date IS NULL AND NEW.return_date IS NOT NULL
BEGIN
    UPDATE books SET copies_available = copies_available + 1 WHERE book_id = NEW.book_id;
END;

-- Reusable view: currently overdue loans (relative to today).
CREATE VIEW v_overdue_loans AS
SELECT l.loan_id, b.title,
       m.first_name || ' ' || m.last_name AS member,
       m.email, l.loan_date, l.due_date,
       CAST(julianday(date('now')) - julianday(l.due_date) AS INTEGER) AS days_overdue
FROM loans l
JOIN books   b ON b.book_id   = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL AND l.due_date < date('now');
