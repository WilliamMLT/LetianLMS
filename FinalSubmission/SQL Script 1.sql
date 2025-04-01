CREATE DATABASE lms_db;
USE lms_db;

# create a categories table to organize books into categories for filtering
CREATE TABLE tbl_book_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

INSERT INTO tbl_book_categories VALUES(1, 'Fantasy', 'Fantasy Genre'), (2, 'Self-Help', 'Non-Fiction Self-Help Genre'), (3, 'Tragedy', 'Fiction Tragedy Genre');
SELECT * FROM tbl_book_categories;

# create a books table
CREATE TABLE tbl_books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    book_title VARCHAR(100) NOT NULL,
    book_author VARCHAR(100) NOT NULL,
    book_isbn VARCHAR(15) UNIQUE,
    book_category_id INT,
    book_publication_year INT CHECK (book_publication_year > 0),
    FOREIGN KEY (book_category_id) REFERENCES tbl_book_categories(category_id) ON DELETE SET NULL
);

insert into tbl_books values(1, "Alice's Adventures in Wonderland", 'Lewis Carroll' , '978-1503222687', 1, 2020), (2, 'How to Win Friends and Influence People', 'Dale Carnegie', '978-0671027032', 2, 1998), (3, 'The Great Gatsby', 'F. Scott Fitzgerald', '979-8351145013', 3, 2022);
SELECT * FROM tbl_books;

# Create a users table
CREATE TABLE tbl_users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    user_address VARCHAR(200),
    user_contact_number VARCHAR(20),
    user_roles ENUM('librarian', 'member') NOT NULL, # roles are restricted to librarians and members
    user_password VARCHAR(255) NOT NULL, # password are hashed
    # user_created_date DATE DEFAULT CURRENT_TIMESTAMP, # user created date
    outstanding_fines DECIMAL(10,2) NULL
);

INSERT INTO tbl_users VALUES(1, 'John Admin', 'johnadmin@gmail.com' , '491H Tampines Street 45 #01-242, Singapore, 522491', 67839211, 'librarian', 'password123', 0), (2, 'Member Doe', 'memberdoe@outlook.com', '27 Jalan Buroh, Singapore, 619483', 62685813, 'member', 'idonthavepassword', 0), (3, 'William', 'william@gmail.com', 'BLK', 12345678, 'member', '12345678', 0);
SELECT * FROM tbl_users;
# userPassword": "securepassword" for John Doe
# DELETE FROM tbl_users WHERE user_id = 1;
#ALTER TABLE tbl_users DROP COLUMN user_created_date;
#ALTER TABLE tbl_users ADD COLUMN user_created_date DATE DEFAULT CURRENT_TIMESTAMP;
#DESCRIBE tbl_users;
#ALTER TABLE tbl_users MODIFY user_id INT AUTO_INCREMENT;


# Create a loans table
CREATE TABLE tbl_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrowed_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('BORROWED', 'RETURNED', 'OVERDUE') DEFAULT 'BORROWED', # status of book, default set to borrowed
    renewal_count INT,
    FOREIGN KEY (user_id) REFERENCES tbl_users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES tbl_books(book_id) ON DELETE CASCADE,
    CHECK (due_date > borrowed_date)
);

INSERT INTO tbl_loans (user_id, book_id, borrowed_date, due_date, return_date, status, renewal_count) 
VALUES 
(2, 3, '2025-03-15', '2025-03-28', NULL, 'BORROWED', 0), 
(3, 2, '2025-03-15', '2025-03-28', NULL, 'BORROWED', 0);
SELECT * FROM tbl_loans;
SELECT DISTINCT status FROM tbl_loans;



# create a transaction table to track fines
CREATE TABLE tbl_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    transaction_amount DECIMAL(10,2),
    transaction_type ENUM('FINE', 'PAYMENT', 'REFUND'),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES tbl_users(user_id) ON DELETE CASCADE
);
INSERT INTO tbl_transactions (user_id, transaction_amount, transaction_type, transaction_date)
VALUES (2, 10.50, 'FINE', '2025-03-15 10:00:00');
SELECT * FROM tbl_transactions;

# create a book copies table to track multiple copies of the same book
CREATE TABLE tbl_book_copies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    copy_number INT,
    status ENUM('AVAILABLE', 'BORROWED', 'RESERVED', 'LOST', 'DAMAGED') DEFAULT 'AVAILABLE',
    FOREIGN KEY (book_id) REFERENCES tbl_books(book_id) ON DELETE CASCADE
);

-- Insert book copies
INSERT INTO tbl_book_copies (book_id, copy_number, status)
VALUES (1, 1, 'AVAILABLE'), (1, 2, 'AVAILABLE'), (1, 3, 'BORROWED');
SELECT * FROM tbl_book_copies;

# create a reservations table to allow members to reserve books
CREATE TABLE tbl_reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    book_id INT,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ACTIVE', 'CANCELLED', 'FULFILLED'),
    FOREIGN KEY (user_id) REFERENCES tbl_users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES tbl_books(book_id) ON DELETE CASCADE
);
INSERT INTO tbl_reservations (user_id, book_id, reservation_date, status)
VALUES (2, 3, '2025-03-15 10:00:00', 'ACTIVE');
SELECT * FROM tbl_reservations;

# create a fines table to store user fines for overdue books
CREATE TABLE tbl_fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    loan_id INT,
    fine_amount DECIMAL(10,2),
    due_date DATE,
    status ENUM('UNPAID', 'PAID'),
    FOREIGN KEY (user_id) REFERENCES tbl_users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (loan_id) REFERENCES tbl_loans(loan_id) ON DELETE CASCADE
);
INSERT INTO tbl_fines (user_id, loan_id, fine_amount, due_date, status) 
VALUES(2, 1, 1.50, '2025-03-25', 'UNPAID');
SELECT * FROM tbl_fines;
SHOW COLUMNS FROM tbl_loans;
