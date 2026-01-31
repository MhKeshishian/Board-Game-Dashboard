-- FILE:        database.sql
-- PROJECT:     SET Capstone – StratPad
-- COURSE:      System Project
-- AUTHOR:      Kalina Cathcart
-- DATE:        2026-01-29
-- DESCRIPTION:
--              This database schema defines the backend data model for the StratPad application.
--              The design uses a HYBRID APPROACH:
--                  • Relational tables for users, campaigns, permissions, and interactions (votes, subscriptions, reports).
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
    gm_flag BOOLEAN DEFAULT FALSE,                            -- True if user can create/run campaigns as Game Master
    dashboard_limit INT DEFAULT 10,                           -- Maximum number of dashboards user can create
    dashboard_count INT DEFAULT 0                             -- Current number of dashboards owned by user

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



-- TABLE: Campaigns
-- PRIMARY KEY: id
-- FOREIGN KEYS: gm_user_id for Users(id)
-- PURPOSE: Represents a single game for which many sessions will be played under. 
-- A campaign is owned by a single Game Master (GM) user. Players join campaigns via invite codes or public access.
-- Campaigns store metadata about the game world, setting, tone, and difficulty. Campaigns can be active or archived/completed. 
-- Campaigns have many members (users) via CampaignMembers junction table. Campaigns have many sessions (play sessions) via Sessions table.
-- Campaigns can have many dashboards created within them by members. Dashboards created in a campaign are owned by individual users.
CREATE TABLE Campaigns (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each campaign

    -- Core campaign info
    title VARCHAR(250) NOT NULL,                              -- Campaign name/title, required field
    description VARCHAR(2500),                                -- Campaign summary/description

    -- Ownership
    gm_user_id INT NOT NULL,                                  -- Foreign key to Users, identifies the Game Master who owns this campaign

    -- Campaign Metadata
    game_system VARCHAR(100),                                 -- RPG system being used (e.g., D&D 5e, Pathfinder, Scrabble, etc) 
    visibility VARCHAR(20) DEFAULT 'private',                 -- Access level: private (owner only), invite (with code), or public
    invite_code VARCHAR(100) UNIQUE,                          -- Unique code players use to join invite-only campaigns
    is_active BOOLEAN DEFAULT TRUE,                           -- True if campaign is ongoing, false if archived/completed

    -- Campaign Data  
    world_name VARCHAR(250),                                  -- Name of the campaign's world/setting
    setting VARCHAR(250),                                     -- Genre/theme (e.g., medieval fantasy, sci-fi)
    tone VARCHAR(100),                                        -- Campaign tone (e.g., dark, comedic, serious)
    difficulty_level VARCHAR(50),                             -- Difficulty setting (e.g., easy, hard, deadly)

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when campaign was created, auto-set on insert
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp of last campaign update, should update on changes
    archived_at TIMESTAMPTZ,                                  -- Timestamp when campaign was archived, null if active

    -- Constraints
    CONSTRAINT fk_campaigns_gm                                -- Foreign key constraint to ensure valid GM reference
        FOREIGN KEY (gm_user_id)                              -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE                                     -- Delete campaign if GM user is deleted
);







-- TABLE: CampaignMembers
-- PRIMARY KEY: id
-- FOREIGN KEYS: campaign_id for Campaigns(id), user_id for Users(id)
-- PURPOSE: Junction table linking Users ↔ Campaigns.
-- A user can be in many campaigns, and a campaign can have many users.
CREATE TABLE CampaignMembers (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each membership

    -- foreign Keys 
    campaign_id INT NOT NULL,                                 -- Foreign key to Campaigns, identifies which campaign
    user_id INT NOT NULL,                                     -- Foreign key to Users, identifies which user is a member

    -- Campaign Member details 
    role VARCHAR(50) DEFAULT 'player',                        -- Member's role: player (default), co_gm (assistant GM), or observer
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,          -- Timestamp when user joined the campaign, auto-set on insert
    is_active BOOLEAN DEFAULT TRUE,                           -- True if membership is active, false if user left/removed

    -- Constraints
    CONSTRAINT fk_campaign_members_campaign                   -- Foreign key constraint to ensure valid campaign reference
        FOREIGN KEY (campaign_id)                             -- Links to Campaigns table
        REFERENCES Campaigns(id)                              -- Must reference an existing campaign
        ON DELETE CASCADE,                                    -- Delete membership if campaign is deleted

    CONSTRAINT fk_campaign_members_user                       -- Foreign key constraint to ensure valid user reference
        FOREIGN KEY (user_id)                                 -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE,                                    -- Delete membership if user is deleted

    CONSTRAINT uq_campaign_members UNIQUE (campaign_id, user_id) -- Composite unique constraint: user can only join campaign once to prevent duplicate memberships
);




-- TABLE: Sessions
-- PRIMARY KEY: id
-- FOREIGN KEYS: user_id for Users(id), campaign_id for Campaigns(id)
-- PURPOSE: Represents individual play sessions within a campaign.
CREATE TABLE Sessions (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each session

    -- Foreign Keys
    user_id INT NOT NULL,                                     -- Foreign key to Users, identifies session creator/owner
    campaign_id INT NOT NULL,                                 -- Foreign key to Campaigns, identifies parent campaign
    session_token VARCHAR(255) UNIQUE NOT NULL,               -- Unique secure token for joining/authenticating to session

    session_number INT NOT NULL,                              -- Sequential number of session within campaign (1, 2, 3...)
    session_title VARCHAR(250),                               -- descriptive title for the session
    session_notes TEXT,                                       -- GM notes, session recap, or summary

    scheduled_at TIMESTAMPTZ,                                 -- Timestamp when session is scheduled to occur
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when session record was created, auto-set on insert
    is_valid BOOLEAN DEFAULT TRUE,                            -- True if session is valid/active, false if cancelled/invalidated

    -- Constraints
    CONSTRAINT fk_sessions_user                               -- Foreign key constraint to ensure valid user reference
        FOREIGN KEY (user_id)                                 -- Links to Users table
        REFERENCES Users(id)                                  -- Must reference an existing user
        ON DELETE CASCADE,                                    -- Delete session if user is deleted

    CONSTRAINT fk_sessions_campaign                           -- Foreign key constraint to ensure valid campaign reference
        FOREIGN KEY (campaign_id)                             -- Links to Campaigns table
        REFERENCES Campaigns(id)                              -- Must reference an existing campaign
        ON DELETE CASCADE                                     -- Delete session if parent campaign is deleted
);





-- TABLE: Dashboards
-- PRIMARY KEY: id
-- FOREIGN KEYS: owner_id for Users(id), campaign_id for Campaigns(id), copied_from_id for Dashboards(id)
-- PURPOSE: Stores dashboards created by users inside campaigns. Stores dashboard details in JSON. 
CREATE TABLE Dashboards (

    id SERIAL PRIMARY KEY,                                    -- Auto-incrementing integer, uniquely identifies each dashboard

    -- foreign Keys 
    owner_id INT NOT NULL,                                    -- Foreign key to Users, identifies dashboard creator/owner
    campaign_id INT NOT NULL,                                 -- Foreign key to Campaigns, identifies campaign context
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

    CONSTRAINT fk_dashboards_campaign                         -- Foreign key constraint to ensure valid campaign reference
        FOREIGN KEY (campaign_id)                             -- Links to Campaigns table
        REFERENCES Campaigns(id)                              -- Must reference an existing campaign
        ON DELETE CASCADE,                                    -- Delete dashboard if campaign is deleted

    CONSTRAINT fk_dashboards_copied_from                      -- Foreign key constraint to track dashboard lineage
        FOREIGN KEY (copied_from_id)                          -- Links to Dashboards table (self-reference)
        REFERENCES Dashboards(id)                             -- Must reference an existing dashboard
        ON DELETE SET NULL                                    -- Set to NULL if original dashboard is deleted
);







-- TABLE: Tags
-- PRIMARY KEY: id
-- FOREIGN KEYS: none
-- PURPOSE: Simple lookup table for categorizing dashboards.
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






