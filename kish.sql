use ytdatabase;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL
);

INSERT INTO users (username, password, email) 
VALUES 
('kishore', 'kishro0518', 'rokish@example.com'),
('lokesh', 'loki2721', 'loki@example.com'),
('tharun', 'tharun4ks', 'tharunks@example.com');