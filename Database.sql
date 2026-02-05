-- FILE:        database.sql
-- PROJECT:     SET Capstone – StratPad
-- COURSE:      System Project
-- AUTHOR:      Kalina Cathcart
-- DATE:        2026-01-29
-- DESCRIPTION:
--              This PostgreSQL database schema defines the backend data model for the StratPad application.
--              The design uses a HYBRID APPROACH:
--                  • Relational tables for users,, permissions, and interactions (votes, subscriptions, reports).
--                  • JSONB document storage for dashboard layouts and modules



-- TABLE: Users
-- PRIMARY KEY: id
-- FOREIGN KEYS: None
-- PURPOSE: Stores user accounts, authentication data, and profile settings. 
CREATE TABLE Users (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each user

    -- Authentication 
    username VARCHAR(100) UNIQUE NOT NULL,                    -- Public-facing username, must be unique across all users
    first_name VARCHAR(100) NOT NULL,                         -- User's first name, required field
    last_name VARCHAR(100) NOT NULL,                          -- User's last name, required field
    email VARCHAR(250) UNIQUE NOT NULL,                       -- Login email address, must be unique, required for authentication
    password_hash VARCHAR(255) NOT NULL,                      -- Hashed password using bcrypt/argon2, never store plaintext
 

    -- Account Metadata
    is_active BOOLEAN DEFAULT TRUE,                           -- Account active status, false = soft delete/disabled account                        
    dashboard_limit INT DEFAULT 10,                           -- Maximum number of dashboards user can create
    dashboard_count INT DEFAULT 0,                             -- Current number of dashboards owned by user
    role VARCHAR(50) DEFAULT 'user',                          -- User role: user, moderator, admin
    

    -- Profile Data
    bio VARCHAR(1000),                                        -- Short user biography/description
    avatar_url VARCHAR(500),                                  -- URL to user's profile image/avatar
    location VARCHAR(150),                                    -- User's general location (city/region)
    timezone VARCHAR(50),                                     -- User's timezone 
    language_choice VARCHAR(10) DEFAULT 'en',                 -- Preferred UI language (ISO code), default = English

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when the account was created, auto-set on insert
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp of last profile update, should be updated on changes
    last_login TIMESTAMPTZ,                                   -- Timestamp of user's last successful login, allowed to be null initially
   
);



-- TABLE: Dashboards
-- PRIMARY KEY: id
-- FOREIGN KEYS: owner_id for Users(id), copied_from_id for Dashboards(id)
-- PURPOSE: Stores dashboards created by users. Stores dashboard details in JSON. 
CREATE TABLE Dashboards (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each dashboard

    -- foreign Keys 
    owner_id INT NOT NULL,                                    -- Foreign key to Users, identifies dashboard creator/owner
    copied_from_id INT,                                       -- Foreign key to Dashboards, references original if this is a copy

    -- Dashboard Overview
    title VARCHAR(250) NOT NULL,                              -- Dashboard name/title, required field
    description VARCHAR(2500),                                -- Dashboard description/purpose

    -- Community Features 
    visibility VARCHAR(20) DEFAULT 'private',                 -- Access level: private (owner only), campaign (members), or public for community board sharing 
    is_shared BOOLEAN DEFAULT FALSE,                          -- True if dashboard is shared publicly in community library
    vote_count INT DEFAULT 0,                                 -- Denormalized count of votes, updated via trigger/application logic
    subscription_count INT DEFAULT 0,                         -- Denormalized count of subscriptions, updated via trigger/application logic

    -- JSON structure for config and layout
    dashboard_structure JSONB NOT NULL,                       -- JSONB containing complete dashboard layout and configuration data

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when dashboard was created, auto-set on insert
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp of last dashboard modification, should update on changes
    published_at TIMESTAMPTZ,                                 -- Timestamp when dashboard was first shared publicly, null if not shared

    -- Constraints 
    CONSTRAINT fk_dashboards_owner                            -- Foreign key constraint to ensure valid owner reference
        FOREIGN KEY (owner_id)                                -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE,                                    -- Delete dashboard if owner is deleted

    CONSTRAINT fk_dashboards_copied_from                      -- Foreign key constraint to track dashboard lineage
        FOREIGN KEY (copied_from_id)                          -- Links to Dashboards table (self-reference)
        REFERENCES Dashboards(id)                             -- Must reference an existing dashboard
        ON DELETE SET NULL                                    -- Set to NULL if original dashboard is deleted
);





-- TABLE: Tags
-- PRIMARY KEY: id
-- FOREIGN KEYS: none
-- PURPOSE: Simple table for categorizing dashboards.
CREATE TABLE Tags (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each tag
    
    -- Tag Data 
    tag_name VARCHAR(100) UNIQUE NOT NULL,                    -- Tag name (e.g., "Warhammer", "D&D"), must be unique
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP          -- Timestamp when tag was created, auto-set on insert

);




-- TABLE: DashboardTags
-- PRIMARY KEY:  id
-- FOREIGN KEYS: dashboard_id for Dashboards(id), tag_id for Tags(id)
-- PURPOSE: Many-to-many relationship between Dashboards and Tags.

CREATE TABLE DashboardTags (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each tag assignment
   
   -- Foreign Keys 
   dashboard_id INT NOT NULL,                                -- Foreign key to Dashboards, identifies which dashboard
   tag_id INT NOT NULL,                                      -- Foreign key to Tags, identifies which tag is applied
   
   -- Timestamps
   created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when tag was applied to dashboard, auto-set on insert

    -- Constraints 
    CONSTRAINT fk_dashboard_tags_dashboard                    -- Foreign key constraint to ensure valid dashboard reference
        FOREIGN KEY (dashboard_id)                            -- Links to Dashboards table
        REFERENCES Dashboards(id)                             -- Must reference an existing dashboard
        ON DELETE CASCADE,                                    -- Delete tag assignment if dashboard is deleted

    CONSTRAINT fk_dashboard_tags_tag                          -- Foreign key constraint to ensure valid tag reference
        FOREIGN KEY (tag_id)                                  -- Links to Tags table
        REFERENCES Tags(id)                                   -- Must reference an existing tag
        ON DELETE CASCADE,                                    -- Delete tag assignment if tag is deleted

    CONSTRAINT uq_dashboard_tags UNIQUE (dashboard_id, tag_id) -- Composite unique constraint: same tag can't be applied twice to same dashboard
);



-- TABLE: Votes
-- PRIMARY KEY:  id
-- FOREIGN KEYS: user_id for Users(id), dashboard_id for Dashboards(id)
-- PURPOSE: Stores up/down votes on dashboards. 
CREATE TABLE Votes (

   
    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each vote

    -- Foreign Keys 
    user_id INT NOT NULL,                                     -- Foreign key to Users, identifies who cast the vote
    dashboard_id INT NOT NULL,                                -- Foreign key to Dashboards, identifies what was voted on

    -- Vote Data 
    vote_type VARCHAR(20) DEFAULT 'up',                       -- Type of vote: 'up' (like/upvote) or 'down' (dislike/downvote)
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when vote was cast, auto-set on insert


    -- Constraints
    CONSTRAINT fk_votes_user                                  -- Foreign key constraint to ensure valid user reference
        FOREIGN KEY (user_id)                                 -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE,                                    -- Delete vote if user is deleted

    CONSTRAINT fk_votes_dashboard                             -- Foreign key constraint to ensure valid dashboard reference
        FOREIGN KEY (dashboard_id)                            -- Links to Dashboards table
        REFERENCES Dashboards(id)                             -- Must reference an existing dashboard
        ON DELETE CASCADE,                                    -- Delete vote if dashboard is deleted


    CONSTRAINT uq_votes UNIQUE (user_id, dashboard_id)        -- User can only vote once per dashboard, Prevent multiple votes by same user
);



-- TABLE: Subscriptions
-- PRIMARY KEY: id
-- FOREIGN KEYS: user_id for Users(id), dashboard_id for Dashboards(id)
-- PURPOSE: Tracks which users follow which dashboards. 
CREATE TABLE Subscriptions (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each subscription
    
    --Foreign Keys 
    user_id INT NOT NULL,                                     -- Foreign key to Users, identifies who subscribed
    dashboard_id INT NOT NULL,                                -- Foreign key to Dashboards, identifies what was subscribed to
    
    -- Timestamps
    subscribed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,      -- Timestamp when user subscribed, auto-set on insert
    last_accessed TIMESTAMPTZ,                                -- Timestamp when user last viewed/accessed this dashboard, nullable


    -- Constraints 
    CONSTRAINT fk_subscriptions_user                          -- Foreign key constraint to ensure valid user reference
        FOREIGN KEY (user_id)                                 -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE,                                    -- Delete subscription if user is deleted

    CONSTRAINT fk_subscriptions_dashboard                     -- Foreign key constraint to ensure valid dashboard reference
        FOREIGN KEY (dashboard_id)                            -- Links to Dashboards table
        REFERENCES Dashboards(id)                             -- Must reference an existing dashboard
        ON DELETE CASCADE,                                    -- Delete subscription if dashboard is deleted

    CONSTRAINT uq_subscriptions UNIQUE (user_id, dashboard_id) -- Composite unique constraint: user can only subscribe once per dashboard
);




-- TABLE: Reports
-- PRIMARY KEY: id
-- FOREIGN KEYS: reporter_user_id → Users(id), dashboard_id → Dashboards(id), 
--               reviewed_by_user_id → Users(id)
-- PURPOSE: Tracks user reports of inappropriate/violating dashboards for moderation
CREATE TABLE Reports (
    
    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each report
    
    -- Foreign Keys
    reporter_user_id INT NOT NULL,                            -- Foreign key to Users, identifies who filed the report
    dashboard_id INT NOT NULL,                                -- Foreign key to Dashboards, identifies what was reported
    reviewed_by_user_id INT,                                  -- Foreign key to Users, identifies admin who reviewed (nullable)
    
    -- Report Details
    report_reason VARCHAR(50) NOT NULL,                       -- Category: spam, inappropriate, copyright, other
    report_description TEXT,                                  -- Detailed explanation from reporter
    
    -- Review Status
    status VARCHAR(20) DEFAULT 'pending',                     -- Status: pending, reviewing, resolved, dismissed
    admin_notes TEXT,                                         -- Internal notes from moderator/admin
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- When report was filed
    reviewed_at TIMESTAMPTZ,                                  -- When admin reviewed the report (nullable)
    resolved_at TIMESTAMPTZ,                                  -- When report was resolved/closed (nullable)
    
    -- Constraints
    CONSTRAINT fk_reports_reporter                          -- Delete report if reporter is deleted
        FOREIGN KEY (reporter_user_id)                      -- 
        REFERENCES Users(id)                                -- 
        ON DELETE CASCADE,                                  -- 
        
    CONSTRAINT fk_reports_dashboard                         -- Delete report if dashboard is deleted
        FOREIGN KEY (dashboard_id)                          -- 
        REFERENCES Dashboards(id)                           --
        ON DELETE CASCADE,                                  -- 
        
    CONSTRAINT fk_reports_reviewer                         -- Set to NULL if reviewer account deleted
        FOREIGN KEY (reviewed_by_user_id)                  -- 
        REFERENCES Users(id)                               -- 
        ON DELETE SET NULL                                 -- 
);





-- Indexes

-- Users table indexes
CREATE INDEX idx_users_username ON Users(username);              -- B-tree index on username
CREATE INDEX idx_users_email ON Users(email);                    -- Fast email lookups during login
CREATE INDEX idx_users_is_active ON Users(is_active);            -- Filter active/inactive users
CREATE INDEX idx_users_created_at ON Users(created_at);          -- Sort users by registration date

-- Dashboards table indexes
CREATE INDEX idx_dashboards_owner_id ON Dashboards(owner_id);                  -- Get user's dashboards
CREATE INDEX idx_dashboards_visibility ON Dashboards(visibility);              -- Filter by visibility
CREATE INDEX idx_dashboards_is_shared ON Dashboards(is_shared);                -- Find shared dashboards
CREATE INDEX idx_dashboards_created_at ON Dashboards(created_at);              -- Sort by date
CREATE INDEX idx_dashboards_vote_count ON Dashboards(vote_count DESC);         -- Sort by popularity


-- DashboardTags table indexes
CREATE INDEX idx_dashboard_tags_dashboard_id ON DashboardTags(dashboard_id);   -- Get tags for dashboard
CREATE INDEX idx_dashboard_tags_tag_id ON DashboardTags(tag_id);               -- Get dashboards with tag

-- Votes table indexes
CREATE INDEX idx_votes_user_id ON Votes(user_id);                              -- Get user's votes
CREATE INDEX idx_votes_dashboard_id ON Votes(dashboard_id);                    -- Get votes for dashboard

-- Subscriptions table indexes
CREATE INDEX idx_subscriptions_user_id ON Subscriptions(user_id);              -- Get user's subscriptions
CREATE INDEX idx_subscriptions_dashboard_id ON Subscriptions(dashboard_id);    -- Get subscribers of dashboard

-- Reports table indexes
CREATE INDEX idx_reports_status ON Reports(status);                      -- Filter by status
CREATE INDEX idx_reports_dashboard_id ON Reports(dashboard_id);          -- Get reports for dashboard
CREATE INDEX idx_reports_reporter_id ON Reports(reporter_user_id);       -- Get reports by user
CREATE INDEX idx_reports_created_at ON Reports(created_at DESC);         -- Sort by date


-- TRIGGERS AND FUNCTIONS

-- FUNCTION: update_updated_at_column
-- TABLE: Users, Dashboards
-- TRIGGER TIME: BEFORE UPDATE
-- TRIGGER EVENT: UPDATE
-- DESCRIPTION: Automatically updates the updated_at column to the current timestamp
--              whenever a row is modified in Users, or Dashboards tables.
--              This ensures accurate tracking of last modification time without
--              requiring manual updates in application code.
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- NAME: update_users_updated_at
-- TABLE: Users
-- TRIGGER TIME: BEFORE UPDATE
-- TRIGGER EVENT: UPDATE
-- DESCRIPTION: Triggers the update_updated_at_column function before any UPDATE on Users table.
--              Ensures updated_at timestamp is always current when user data is modified.
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON Users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();



-- NAME: update_dashboards_updated_at
-- TABLE: Dashboards
-- TRIGGER TIME: BEFORE UPDATE
-- TRIGGER EVENT: UPDATE
-- DESCRIPTION: Triggers the update_updated_at_column function before any UPDATE on Dashboards table.
--              Ensures updated_at timestamp is always current when dashboard data is modified.
CREATE TRIGGER update_dashboards_updated_at 
    BEFORE UPDATE ON Dashboards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();



-- VOTE COUNT FUNCTIONS

-- FUNCTION: increment_dashboard_vote_count
-- TABLE: Votes, Dashboards
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Increments the vote_count in Dashboards table when a new vote is added to Votes table.
--              This denormalized counter enables fast sorting/filtering by popularity without
--              requiring expensive COUNT(*) queries on every page load.
CREATE OR REPLACE FUNCTION increment_dashboard_vote_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Dashboards 
    SET vote_count = vote_count + 1 
    WHERE id = NEW.dashboard_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- FUNCTION: decrement_dashboard_vote_count
-- TABLE: Votes, Dashboards
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Decrements the vote_count in Dashboards table when a vote is removed from Votes table.
--              Maintains accurate vote count when users remove their votes or when votes are deleted.
CREATE OR REPLACE FUNCTION decrement_dashboard_vote_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Dashboards 
    SET vote_count = vote_count - 1 
    WHERE id = OLD.dashboard_id;
    RETURN OLD;
END;
$$ language 'plpgsql';

-- NAME: trigger_increment_vote_count
-- TABLE: Votes
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Triggers the increment_dashboard_vote_count function after a new vote is inserted.
--              Automatically updates the denormalized vote_count in Dashboards table.
CREATE TRIGGER trigger_increment_vote_count
    AFTER INSERT ON Votes
    FOR EACH ROW
    EXECUTE FUNCTION increment_dashboard_vote_count();

-- NAME: trigger_decrement_vote_count
-- TABLE: Votes
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Triggers the decrement_dashboard_vote_count function after a vote is deleted.
--              Automatically decreases the denormalized vote_count in Dashboards table.
CREATE TRIGGER trigger_decrement_vote_count
    AFTER DELETE ON Votes
    FOR EACH ROW
    EXECUTE FUNCTION decrement_dashboard_vote_count();


-- SUBSCRIPTION COUNT FUNCTIONS

-- FUNCTION: increment_dashboard_subscription_count
-- TABLE: Subscriptions, Dashboards
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Increments the subscription_count in Dashboards table when a new subscription is added.
--              This denormalized counter enables fast sorting/filtering by subscriber popularity
--              without requiring expensive COUNT(*) queries.
CREATE OR REPLACE FUNCTION increment_dashboard_subscription_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Dashboards 
    SET subscription_count = subscription_count + 1 
    WHERE id = NEW.dashboard_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- FUNCTION: decrement_dashboard_subscription_count
-- TABLE: Subscriptions, Dashboards
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Decrements the subscription_count in Dashboards table when a subscription is removed.
--              Maintains accurate subscription count when users unsubscribe or subscriptions are deleted.
CREATE OR REPLACE FUNCTION decrement_dashboard_subscription_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Dashboards 
    SET subscription_count = subscription_count - 1 
    WHERE id = OLD.dashboard_id;
    RETURN OLD;
END;
$$ language 'plpgsql';

-- NAME: trigger_increment_subscription_count
-- TABLE: Subscriptions
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Triggers the increment_dashboard_subscription_count function after a new subscription.
--              Automatically updates the denormalized subscription_count in Dashboards table.
CREATE TRIGGER trigger_increment_subscription_count
    AFTER INSERT ON Subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION increment_dashboard_subscription_count();

-- NAME: trigger_decrement_subscription_count
-- TABLE: Subscriptions
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Triggers the decrement_dashboard_subscription_count function after unsubscribe.
--              Automatically decreases the denormalized subscription_count in Dashboards table.
CREATE TRIGGER trigger_decrement_subscription_count
    AFTER DELETE ON Subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION decrement_dashboard_subscription_count();


-- USER DASHBOARD COUNT FUNCTIONS

-- FUNCTION: increment_user_dashboard_count
-- TABLE: Dashboards, Users
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Increments the dashboard_count in Users table when a new dashboard is created.
--              This denormalized counter tracks how many dashboards each user owns for
--              quota enforcement and analytics without expensive COUNT(*) queries.
CREATE OR REPLACE FUNCTION increment_user_dashboard_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Users 
    SET dashboard_count = dashboard_count + 1 
    WHERE id = NEW.owner_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- FUNCTION: decrement_user_dashboard_count
-- TABLE: Dashboards, Users
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Decrements the dashboard_count in Users table when a dashboard is deleted.
--              Maintains accurate count when users delete their dashboards.
CREATE OR REPLACE FUNCTION decrement_user_dashboard_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Users 
    SET dashboard_count = dashboard_count - 1 
    WHERE id = OLD.owner_id;
    RETURN OLD;
END;
$$ language 'plpgsql';

-- NAME: trigger_increment_dashboard_count
-- TABLE: Dashboards
-- TRIGGER TIME: AFTER INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Triggers the increment_user_dashboard_count function after a dashboard is created.
--              Automatically updates the denormalized dashboard_count in Users table.
CREATE TRIGGER trigger_increment_dashboard_count
    AFTER INSERT ON Dashboards
    FOR EACH ROW
    EXECUTE FUNCTION increment_user_dashboard_count();

-- NAME: trigger_decrement_dashboard_count
-- TABLE: Dashboards
-- TRIGGER TIME: AFTER DELETE
-- TRIGGER EVENT: DELETE
-- DESCRIPTION: Triggers the decrement_user_dashboard_count function after a dashboard is deleted.
--              Automatically decreases the denormalized dashboard_count in Users table.
CREATE TRIGGER trigger_decrement_dashboard_count
    AFTER DELETE ON Dashboards
    FOR EACH ROW
    EXECUTE FUNCTION decrement_user_dashboard_count();



-- DASHBOARD LIMIT ENFORCEMENT

-- FUNCTION: check_dashboard_limit
-- TABLE: Dashboards, Users
-- TRIGGER TIME: BEFORE INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Validates that user has not exceeded their dashboard_limit before allowing creation.
--              Queries the Users table to get user's current dashboard_count and dashboard_limit,
--              then raises an exception if the limit has been reached. This prevents users from
--              creating more dashboards than their plan allows.
CREATE OR REPLACE FUNCTION check_dashboard_limit()
RETURNS TRIGGER AS $$
DECLARE
    user_limit INT;
    user_count INT;
BEGIN
    -- Get user's limit and current count
    SELECT dashboard_limit, dashboard_count 
    INTO user_limit, user_count
    FROM Users 
    WHERE id = NEW.owner_id;
    
    -- Check if user has reached limit
    IF user_count >= user_limit THEN
        RAISE EXCEPTION 'Dashboard limit reached. Maximum allowed: %', user_limit;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- NAME: trigger_check_dashboard_limit
-- TABLE: Dashboards
-- TRIGGER TIME: BEFORE INSERT
-- TRIGGER EVENT: INSERT
-- DESCRIPTION: Triggers the check_dashboard_limit function before inserting a new dashboard.
--              Prevents users from creating more dashboards than allowed by their plan/settings
--              by checking dashboard_count against dashboard_limit in Users table.
--              Raises an exception and aborts the INSERT if limit is reached.
CREATE TRIGGER trigger_check_dashboard_limit
    BEFORE INSERT ON Dashboards
    FOR EACH ROW
    EXECUTE FUNCTION check_dashboard_limit();
