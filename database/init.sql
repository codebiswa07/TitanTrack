CREATE DATABASE IF NOT EXISTS ai_workout_db;
USE ai_workout_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    security_answer VARCHAR(255) NOT NULL,
    profile_image VARCHAR(255),
    total_points FLOAT DEFAULT 0.0,
    calories_burned FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store every exercise session
CREATE TABLE IF NOT EXISTS workout_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exercise VARCHAR(50) NOT NULL,      -- e.g., 'Pushups', 'Squats', 'Plank'
    difficulty VARCHAR(20) NOT NULL,    -- 'Easy', 'Medium', 'Hard'
    reps INT NOT NULL,                 -- Counts or Seconds (for Plank)
    points_earned FLOAT NOT NULL,       -- Calculated based on difficulty
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert a default user for testing
INSERT INTO users (username, total_points, current_streak) 
VALUES ('chiku', 0.0, 0);