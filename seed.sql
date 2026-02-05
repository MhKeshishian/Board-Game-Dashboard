-- FILE:        seed.sql
-- PROJECT:     SET Capstone – StratPad
-- COURSE:      System Project
-- AUTHOR:      Kalina Cathcart
-- DATE:        2026-02-05
-- DESCRIPTION:
--              This PostgreSQL database schema creates demponstration data for the StratPad application.


BEGIN;


-- CLEAN UP EXISTING DATA 
DELETE FROM Reports;
DELETE FROM Subscriptions;
DELETE FROM Votes;
DELETE FROM DashboardTags;
DELETE FROM Dashboards;
DELETE FROM Tags;
DELETE FROM Users;

-- RESET SEQUENCES TO START AT 1
ALTER SEQUENCE Users_id_seq RESTART WITH 1;
ALTER SEQUENCE Dashboards_id_seq RESTART WITH 1;
ALTER SEQUENCE Tags_id_seq RESTART WITH 1;
ALTER SEQUENCE DashboardTags_id_seq RESTART WITH 1;
ALTER SEQUENCE Votes_id_seq RESTART WITH 1;
ALTER SEQUENCE Subscriptions_id_seq RESTART WITH 1;
ALTER SEQUENCE Reports_id_seq RESTART WITH 1;



-- USERS
INSERT INTO Users (username, first_name, last_name, email, password_hash, role, bio)
VALUES
('kali', 'Kalina', 'Cathcart', 'kali@stratpad.dev', 'HASHED_PASSWORD_1', 'admin', 'Creator of StratPad'),
('Josh', 'Joshua Brian', 'Horsley', 'jbh@stratpad.dev', 'HASHED_PASSWORD_2', 'user', 'Strategy gamer and GM'),
('Randy', 'Joshua', 'Rice', 'randynoodles@stratpad.dev', 'HASHED_PASSWORD_3', 'user', 'Board game enthusiast'),
('chris', 'Christopher', 'Tan', 'chris@stratpad.dev', 'HASHED_PASSWORD_4', 'moderator', 'Community moderator');


-- DASHBOARDS
INSERT INTO Dashboards (owner_id, title, description, visibility, is_shared, dashboard_structure)
VALUES
(1, 'D&D Campaign Master Board', 'Full campaign control panel for Dungeon Masters', 'public', TRUE,
 '{
     "layout": "grid",
     "widgets": [
         {"type": "initiative_tracker", "position": [0,0]},
         {"type": "notes", "position": [1,0]},
         {"type": "map", "position": [0,1]},
         {"type": "npc_manager", "position": [1,1]}
     ]
 }'::jsonb),
(2, 'Warhammer Army Tracker', 'Track units, CP, turns, and objectives', 'public', TRUE,
 '{
     "layout": "grid",
     "widgets": [
         {"type": "turn_order", "position": [0,0]},
         {"type": "command_points", "position": [1,0]},
         {"type": "score_tracker", "position": [0,1]}
     ]
 }'::jsonb),
(3, 'Private Strategy Notes', 'Personal planning dashboard', 'private', FALSE,
 '{
     "layout": "single",
     "widgets": [
         {"type": "notes", "position": [0,0]}
     ]
 }'::jsonb);



-- TAGS
INSERT INTO Tags (tag_name) VALUES
('D&D'),
('Warhammer'),
('Campaign'),
('Strategy'),
('GM Tools'),
('Private');


-- DASHBOARD TAGS (Many-to-Many)
INSERT INTO DashboardTags (dashboard_id, tag_id)
VALUES
(1, 1), -- D&D
(1, 3), -- Campaign
(1, 5), -- GM Tools
(2, 2), -- Warhammer
(2, 4), -- Strategy
(3, 6); -- Private


-- VOTES
INSERT INTO Votes (user_id, dashboard_id, vote_type)
VALUES
(2, 1, 'up'),
(3, 1, 'up'),
(4, 1, 'up'),
(1, 2, 'up'),
(3, 2, 'up'),
(2, 3, 'down');


-- SUBSCRIPTIONS
INSERT INTO Subscriptions (user_id, dashboard_id)
VALUES
(2, 1),
(3, 1),
(4, 1),
(1, 2),
(3, 2),
(2, 3);


-- REPORTS
INSERT INTO Reports (reporter_user_id, dashboard_id, report_reason, report_description)
VALUES
(3, 3, 'inappropriate', 'Contains offensive content in notes widget'),
(2, 1, 'copyright', 'Uses copyrighted map assets');

COMMIT;