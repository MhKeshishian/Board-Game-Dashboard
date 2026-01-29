-- FILE: database.sql
-- PROJECT: SET Capstone: Stratpad
-- COURSE: System Project
-- AUTHOR: Kalina Cathcart
-- DATE CREATED: 2026-01-29
-- DESCRIPTION: Database schema for Stratpad application.




-- TABLE NAME: Users 
-- PRIMARY KEY: id
-- FOREIGN KEYS: None
-- UNIQUE CONSTRAINTS: username, email
-- DESCRIPTION: Stores user account information and profile settings.

CREATE TABLE Users (

    -- Identification and Authentication
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key        
    username VARCHAR(100) UNIQUE NOT NULL,                  -- Unique username
    first_name VARCHAR(100) NOT NULL,                       -- User's first name
    last_name VARCHAR(100) NOT NULL,                        -- User's last name
    email VARCHAR(250) UNIQUE NOT NULL,                     -- Unique email address
    password_hash VARCHAR(255) NOT NULL,                    -- Hashed password

    -- Profile Status
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,                             -- Timestamp of creation
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp of last update
    last_login DATETIME NULL,                                                           -- Timestamp of last login
    is_active TINYINT(1) NOT NULL DEFAULT 1,                                            -- Active status flag (0=false, 1=true)
    bio VARCHAR(1000) NULL,                                                             -- Public bio
    avatar_url VARCHAR(500) NULL,                                                       -- Profile image
    location VARCHAR(150) NULL,                                                         -- Region/city (non-precise)
    timezone VARCHAR(50) NULL,                                                          -- User timezone
    language_choice VARCHAR(10) NOT NULL DEFAULT 'en',                                  -- Preferred language (default: English)

    -- User Settings
    gm_flag TINYINT(1) NOT NULL DEFAULT 0,                  -- Game Master flag (0=false, 1=true)
    dashboard_limit INT NOT NULL DEFAULT 10,                -- Maximum number of dashboards a user can create
    dashboard_count INT NOT NULL DEFAULT 0,                 -- Current number of dashboards created by the user
    dashboard_ids TEXT NULL                                -- Comma-separated list of dashboard IDs owned by the user
    

);


-- TABLE NAME: Campaigns
-- PRIMARY KEY: id
-- FOREIGN KEYS: gm_user_id (references Users.id)
-- UNIQUE CONSTRAINTS: invite_code
-- DESCRIPTION: Stores information about gaming campaigns created by users.
CREATE TABLE Campaigns (

    -- Campaign Identification
    id INT PRIMARY KEY AUTO_INCREMENT,          -- Auto-incrementing primary key
    title VARCHAR(250) NOT NULL,                -- Campaign title
    description VARCHAR(2500),                  -- Campaign description
    gm_user_id INT NOT NULL,                    -- Owner / GM
    game_system VARCHAR(100),                   -- DnD, Pathfinder, Warhammer, etc
    visibility VARCHAR(20) DEFAULT 'private',   -- private | invite | public
    invite_code VARCHAR(100) UNIQUE,            -- Join by code
    is_active TINYINT(1) DEFAULT 1,             -- Campaign active status

    -- World-building metadata
    world_name VARCHAR(250),                -- Name of the game world
    setting VARCHAR(250),                   -- Fantasy, sci-fi, post-apocalyptic, etc
    tone VARCHAR(100),                      -- dark, heroic, political, etc
    difficulty_level VARCHAR(50),           -- easy, medium, hard

    -- Lifecycle
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of creation
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of last update
    archived_at DATETIME NULL,                       -- Timestamp of archival

    -- Constraints
    CONSTRAINT FK_Campaigns_GM FOREIGN KEY (gm_user_id)     -- Foreign key constraint: GM/owner of the campaign
        REFERENCES Users(id) ON DELETE CASCADE                    -- Cascade delete on user deletion    


);


-- TABLE NAME: CampaignMembers
-- PRIMARY KEY: id
-- FOREIGN KEYS: campaign_id (references Campaigns.id), user_id (references Users.id)
-- UNIQUE CONSTRAINTS: campaign_id, user_id
-- DESCRIPTION: Stores membership information for users participating in campaigns.
CREATE TABLE CampaignMembers (

    id INT PRIMARY KEY AUTO_INCREMENT,          -- Auto-incrementing primary key
    campaign_id INT NOT NULL,                   -- Foreign key to Campaigns table
    user_id INT NOT NULL,                       -- Foreign key to Users table
    role VARCHAR(50) DEFAULT 'player',          -- player | co_gm | observer
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Join timestamp
    is_active TINYINT(1) DEFAULT 1,             -- Membership active flag

    -- Constraints
    CONSTRAINT FK_CampaignMembers_Campaigns FOREIGN KEY (campaign_id)
        REFERENCES Campaigns(id) ON DELETE CASCADE,
    CONSTRAINT FK_CampaignMembers_Users FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT UQ_CampaignMembers UNIQUE (campaign_id, user_id)

);




-- TABLE NAME: Sessions
-- PRIMARY KEY: id
-- FOREIGN KEYS: user_id (references Users.id), campaign_id (references Campaigns.id)
-- UNIQUE CONSTRAINTS: session_token
-- DESCRIPTION: Stores information about gaming sessions within campaigns.
CREATE TABLE Sessions (

    -- Session Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    user_id INT NOT NULL,                                   -- Foreign key to Users table
    session_token VARCHAR(255) UNIQUE NOT NULL,             -- Unique session token
    campaign_id INT NOT NULL,                               -- Foreign key to Campaigns table
 
    -- Session Details
    session_number INT NOT NULL,                            -- Session number within the campaign
    session_title VARCHAR(250) NULL,                        -- Optional session title
    session_notes TEXT NULL,                                -- Optional session notes

    -- Timestamps
    scheduled_at DATETIME NULL,                             -- Scheduled date and time for the session
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp of session creation
    is_valid TINYINT(1) NOT NULL DEFAULT 1,                 -- Session validity flag (0=false, 1=true)

    -- Constraints
    CONSTRAINT FK_Sessions_Users FOREIGN KEY (user_id)      -- Foreign key constraint: user who owns the session
        REFERENCES Users(id) ON DELETE CASCADE              -- Cascade delete on user deletion
    CONSTRAINT FK_Sessions_Campaigns FOREIGN KEY (campaign_id) -- Foreign key constraint: campaign to which session belongs
        REFERENCES Campaigns(id) ON DELETE CASCADE                   -- Cascade delete on campaign deletion

);


-- TABLE NAME: Dashboards
-- PRIMARY KEY: id
-- FOREIGN KEYS: owner_id (references Users.id), campaign_id (references Campaigns.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores information about user-created dashboards within campaigns.
CREATE TABLE Dashboards (

    -- Dashboard Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                                  -- Auto-incrementing primary key
    owner_id INT NOT NULL,                                              -- Foreign key to Users table
    campaign_id INT NOT NULL,                                          -- Foreign key to Campaigns table
    title VARCHAR(250) NOT NULL,                                        -- Dashboard title    
    description VARCHAR(2500) NULL,                                     -- Dashboard description  

    -- Dashboard Metadata       
    is_shared TINYINT(1) NOT NULL DEFAULT 0,                             -- Shared status flag (0=false, 1=true)
    visibility VARCHAR(20) DEFAULT 'private',                            -- private | campaign | public
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,             -- Timestamp of creation
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp of last update
    published_at DATETIME NULL,                                         -- Timestamp of publication
    vote_count INT NOT NULL DEFAULT 0,                                  -- Number of votes
    subscription_count INT NOT NULL DEFAULT 0,                          -- Number of subscriptions
    copied_from_id INT NULL,                                            -- Foreign key to original dashboard if copied 

    -- Dashboard Configuration
    layout_config JSON NULL,                                            -- JSON for layout configuration   

    -- Constraints
    CONSTRAINT FK_Dashboards_Users FOREIGN KEY (owner_id)               -- Foreign key constraint: owner of dashboard                                                                    
        REFERENCES Users(id) ON DELETE CASCADE,                         -- Cascade delete on user deletion
    CONSTRAINT FK_Dashboards_CopiedFrom FOREIGN KEY (copied_from_id)    -- Foreign key constraint: original dashboard if copied
        REFERENCES Dashboards(id) ON DELETE SET NULL                    -- Set NULL on original dashboard deletion
    CONSTRAINT FK_Dashboards_Campaigns FOREIGN KEY (campaign_id)    -- Foreign key constraint: campaign to which dashboard belongs
        REFERENCES Campaigns(id) ON DELETE CASCADE                  -- Cascade delete on campaign deletion

);



-- TABLE NAME: Tags
-- PRIMARY KEY: id
-- FOREIGN KEYS: None
-- UNIQUE CONSTRAINTS: tag_name
-- DESCRIPTION: Stores tags used for categorizing dashboards.
CREATE TABLE Modules (

    -- Module Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                                 -- Auto-incrementing primary key
    dashboard_id INT NOT NULL,                                         -- Foreign key to Dashboards table
    module_name VARCHAR(150) NULL,                                     -- User-defined name
    description VARCHAR(1000) NULL,                                    -- Module description
    icon VARCHAR(100) NULL,                                            -- UI icon reference

    -- Module Configuration
    module_type VARCHAR(100) NOT NULL,                                 -- Type of module (e.g., counter, timer, dice_roller)
    module_config JSON NULL,                                           -- JSON for module configuration
    position_config JSON NULL,                                         -- JSON for position configuration
    display_order INT NULL,                                            -- Order of display within the dashboard

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,            -- Timestamp of creation
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp of last update

    -- Constraints
    CONSTRAINT FK_Modules_Dashboards FOREIGN KEY (dashboard_id)        -- Foreign key constraint: dashboard to which module belongs                        
        REFERENCES Dashboards(id) ON DELETE CASCADE                    -- Cascade delete on dashboard deletion

);

-- TABLE NAME: ModuleBasicCounter
-- PRIMARY KEY: id
-- FOREIGN KEYS: module_id (references Modules.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores basic counter configurations for counting modules.

CREATE TABLE ModuleBasicCounter (

    -- Counter Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    module_id INT NOT NULL,                                 -- Foreign key to Modules table

    -- Counter Configuration
    initial_value INT NOT NULL DEFAULT 0,                   -- Initial counter value
    step_value INT NOT NULL DEFAULT 1,                      -- Step value for increment/decrement
    min_value INT NULL,                                     -- Minimum counter value
    max_value INT NULL,                                     -- Maximum counter value

    -- Constraints
    CONSTRAINT FK_ModuleBasicCounter_Modules FOREIGN KEY (module_id)  -- Foreign key constraint: module to which counter belongs
        REFERENCES Modules(id) ON DELETE CASCADE                     -- Cascade delete on module deletion

);




-- TABLE NAME: ModuleBasicTimer
-- PRIMARY KEY: id
-- FOREIGN KEYS: module_id (references Modules.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores basic timer configurations for timer modules.
CREATE TABLE ModuleBasicTimer (

    -- Timer Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    module_id INT NOT NULL,                                 -- Foreign key to Modules table

    -- Timer Configuration
    initial_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Initial timer value
    timer_duration INT NOT NULL DEFAULT 0,                  -- Duration of the timer in seconds

    -- Constraints
    CONSTRAINT FK_ModuleBasicTimer_Modules FOREIGN KEY (module_id)  -- Foreign key constraint: module to which timer belongs
        REFERENCES Modules(id) ON DELETE CASCADE                     -- Cascade delete on module deletion

);



-- TABLE NAME: ModuleDiceRoller
-- PRIMARY KEY: id
-- FOREIGN KEYS: module_id (references Modules.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores dice roller configurations for dice rolling modules.
CREATE TABLE ModuleDiceRoller (
    -- Dice Roller Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    module_id INT NOT NULL,                                 -- Foreign key to Modules table

    -- Dice Roller Configuration
    dice_notation VARCHAR(50) NOT NULL,                    -- Dice notation (e.g., "2d6+3")
    last_roll_result VARCHAR(100) NULL,                     -- Result of the last roll

    -- Constraints
    CONSTRAINT FK_ModuleDiceRoller_Modules FOREIGN KEY (module_id)  -- Foreign key constraint: module to which dice roller belongs
        REFERENCES Modules(id) ON DELETE CASCADE                     -- Cascade delete on module deletion

);


-- TABLE NAME: ModuleTableCreator
-- PRIMARY KEY: id
-- FOREIGN KEYS: module_id (references Modules.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores table creator configurations for table modules.
CREATE TABLE ModuleTableCreator (

    -- Table Creator Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    module_id INT NOT NULL,                                 -- Foreign key to Modules table

    -- Table Creator Configuration
    table_data JSON NULL,                                   -- JSON representation of the table data

    -- Constraints
    CONSTRAINT FK_ModuleTableCreator_Modules FOREIGN KEY (module_id)  -- Foreign key constraint: module to which table creator belongs
        REFERENCES Modules(id) ON DELETE CASCADE                     -- Cascade delete on module deletion

);


-- TABLE NAME: ModuleTextNote
-- PRIMARY KEY: id
-- FOREIGN KEYS: module_id (references Modules.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores text note configurations for text note modules.
CREATE TABLE ModuleTextNote (

    -- Text Note Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    module_id INT NOT NULL,                                 -- Foreign key to Modules table

    -- Text Note Configuration
    content TEXT NULL,                                      -- Content of the text note

    -- Constraints
    CONSTRAINT FK_ModuleTextNote_Modules FOREIGN KEY (module_id)  -- Foreign key constraint: module to which text note belongs
        REFERENCES Modules(id) ON DELETE CASCADE                     -- Cascade delete on module deletion

);



-- TABLE NAME: Tags
-- PRIMARY KEY: id
-- FOREIGN KEYS: None
-- UNIQUE CONSTRAINTS: tag_name
-- DESCRIPTION: Stores tags used for categorizing dashboards.
CREATE TABLE Tags (

    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    tag_name VARCHAR(100) UNIQUE NOT NULL,                  -- Unique tag name
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP  -- Timestamp of creation

);



-- TABLE NAME: DashboardTags
-- PRIMARY KEY: id
-- FOREIGN KEYS: dashboard_id (references Dashboards.id), tag_id (references Tags.id)
-- UNIQUE CONSTRAINTS: (dashboard_id, tag_id)
-- DESCRIPTION: Junction table linking dashboards and tags.
CREATE TABLE DashboardTags (

    -- Dashboard-Tag Association Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                                         -- Auto-incrementing primary key
    dashboard_id INT NOT NULL,                                                 -- Foreign key to Dashboards table
    tag_id INT NOT NULL,                                                       -- Foreign key to Tags table
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,                    -- Timestamp of creation

    -- Constraints
    CONSTRAINT FK_DashboardTags_Dashboards FOREIGN KEY (dashboard_id)          -- Foreign key constraint: dashboard to which tag belongs
        REFERENCES Dashboards(id) ON DELETE CASCADE,                           -- Cascade delete on dashboard deletion
    CONSTRAINT FK_DashboardTags_Tags FOREIGN KEY (tag_id)                      -- Foreign key constraint: tag
        REFERENCES Tags(id) ON DELETE CASCADE,                                 -- Cascade delete on tag deletion
    CONSTRAINT UQ_DashboardTags UNIQUE (dashboard_id, tag_id)                  -- Unique constraint to prevent duplicate tags for the same dashboard

);




-- TABLE NAME: Votes
-- PRIMARY KEY: id
-- FOREIGN KEYS: user_id (references Users.id), dashboard_id (references Dashboards.id)
-- UNIQUE CONSTRAINTS: (user_id, dashboard_id)
-- DESCRIPTION: Stores user votes for dashboards.
CREATE TABLE Votes (

    -- Vote Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                               -- Auto-incrementing primary key
    user_id INT NOT NULL,                                            -- Foreign key to Users table
    dashboard_id INT NOT NULL,                                       -- Foreign key to Dashboards table
    vote_type VARCHAR(20) DEFAULT 'up',                              -- was the vote up | down
    
    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,          -- Timestamp of vote creation

    -- Constraints
    CONSTRAINT FK_Votes_Users FOREIGN KEY (user_id)                  -- Foreign key constraint: user who voted                     
        REFERENCES Users(id) ON DELETE CASCADE,                      -- Cascade delete on user deletion
    CONSTRAINT FK_Votes_Dashboards FOREIGN KEY (dashboard_id)        -- Foreign key constraint: dashboard that was voted on
        REFERENCES Dashboards(id) ON DELETE CASCADE,                 -- Cascade delete on dashboard deletion
    CONSTRAINT UQ_Votes UNIQUE (user_id, dashboard_id)               -- Unique constraint to prevent multiple votes by the same user on the same dashboard

);



-- TABLE NAME: Subscriptions
-- PRIMARY KEY: id
-- FOREIGN KEYS: user_id (references Users.id), dashboard_id (references Dashboards.id)
-- UNIQUE CONSTRAINTS: (user_id, dashboard_id)
-- DESCRIPTION: Stores user subscriptions to dashboards.
CREATE TABLE Subscriptions (

    -- Subscription Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                                     -- Auto-incrementing primary key
    user_id INT NOT NULL,                                                  -- Foreign key to Users table
    dashboard_id INT NOT NULL,                                             -- Foreign key to Dashboards table
    subscribed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,             -- Timestamp of subscription    
    last_accessed DATETIME NULL,                                           -- Timestamp of last access

    -- Constraints
    CONSTRAINT FK_Subscriptions_Users FOREIGN KEY (user_id)                -- Foreign key constraint: user who subscribed
        REFERENCES Users(id) ON DELETE CASCADE,                            -- Cascade delete on user deletion
    CONSTRAINT FK_Subscriptions_Dashboards FOREIGN KEY (dashboard_id)      -- Foreign key constraint: dashboard that was subscribed to
        REFERENCES Dashboards(id) ON DELETE CASCADE,                       -- Cascade delete on dashboard deletion
    CONSTRAINT UQ_Subscriptions UNIQUE (user_id, dashboard_id)             -- Unique constraint to prevent multiple subscriptions by the same user to the same dashboard

);



-- TABLE NAME: Reports
-- PRIMARY KEY: id
-- FOREIGN KEYS: reporter_id (references Users.id), target_dashboard_id (references Dashboards.id), target_user_id (references Users.id)
-- UNIQUE CONSTRAINTS: None
-- DESCRIPTION: Stores reports submitted by users.
CREATE TABLE Reports (

    -- Report Identification
    id INT PRIMARY KEY AUTO_INCREMENT,                      -- Auto-incrementing primary key
    reporter_id INT NOT NULL,                               -- Foreign key to Users table (reporter)
    target_dashboard_id INT NULL,                           -- Foreign key to Dashboards table (reported dashboard)
    target_user_id INT NULL,                                -- Foreign key to Users table (reported user)

    -- Report Details
    reason VARCHAR(500),                                    -- Reason for the report
    status VARCHAR(50) DEFAULT 'open',                      -- Status of the report (e.g., open, in_review, resolved)

    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP           -- Timestamp of report creation

);





-- Indexes --

-- Users Indexes
CREATE INDEX IX_Users_Username ON Users(username);                                  -- Index on username for faster lookups

-- Sessions Indexes
CREATE INDEX IX_Sessions_UserId ON Sessions(user_id);                               -- Index on user_id for faster lookups   
CREATE INDEX IX_Sessions_Token ON Sessions(session_token);                          -- Index on session_token for faster lookups

-- Dashboards Indexes
CREATE INDEX IX_Dashboards_OwnerId ON Dashboards(owner_id);                         -- Index on owner_id for faster lookups 
CREATE INDEX IX_Dashboards_IsShared ON Dashboards(is_shared);                       -- Index on is_shared for filtering shared dashboards
CREATE INDEX IX_Dashboards_CopiedFromId ON Dashboards(copied_from_id);              -- Index on copied_from_id for lookups of copied dashboards

-- Modules Indexes
CREATE INDEX IX_Modules_DashboardId ON Modules(dashboard_id);                       -- Index on dashboard_id for faster lookups
CREATE INDEX IX_Modules_DashboardId_Order ON Modules(dashboard_id, display_order);  -- Composite index for ordering modules within a dashboard

-- Tags Indexes
CREATE INDEX IX_DashboardTags_DashboardId ON DashboardTags(dashboard_id);           -- Index on dashboard_id for faster lookups
CREATE INDEX IX_DashboardTags_TagId ON DashboardTags(tag_id);                       -- Index on tag_id for faster lookups

-- Votes Indexes
CREATE INDEX IX_Votes_DashboardId ON Votes(dashboard_id);                           -- Index on dashboard_id for faster lookups

-- Subscriptions Indexes
CREATE INDEX IX_Subscriptions_UserId ON Subscriptions(user_id);                     -- Index on user_id for faster lookups
CREATE INDEX IX_Subscriptions_DashboardId ON Subscriptions(dashboard_id);           -- Index on dashboard_id for faster lookups

-- Reports Indexes
CREATE INDEX IX_Reports_ReporterId ON Reports(reporter_id);                        -- Index on reporter_id for faster lookups
CREATE INDEX IX_Reports_TargetDashboardId ON Reports(target_dashboard_id);         -- Index on target_dashboard_id for faster lookups
CREATE INDEX IX_Reports_TargetUserId ON Reports(target_user_id);                   -- Index on target_user_id for faster lookups

-- Campaigns Indexes
CREATE INDEX IX_Campaigns_GmUserId ON Campaigns(gm_user_id);                        -- Index on gm_user_id for faster lookups
CREATE INDEX IX_Campaigns_Visibility ON Campaigns(visibility);                      -- Index on visibility
CREATE INDEX IX_Campaigns_IsActive ON Campaigns(is_active);                         -- Index on is_active
CREATE INDEX IX_Campaigns_Title ON Campaigns(title);                                -- Index on title for faster lookups
CREATE INDEX IX_Campaigns_Setting ON Campaigns(setting);                            -- Index on setting for faster lookups
CREATE INDEX IX_Campaigns_DifficultyLevel ON Campaigns(difficulty_level);           -- Index on difficulty_level for faster lookups

-- Campaign Relation Indexes
CREATE INDEX IX_Campaigns_GM ON Campaigns(gm_user_id);                              -- Index on gm_user_id for faster lookups
CREATE INDEX IX_Sessions_CampaignId ON Sessions(campaign_id);                       -- Index on campaign_id for faster lookups
CREATE INDEX IX_Dashboards_CampaignId ON Dashboards(campaign_id);                   -- Index on campaign_id for faster lookups


-- CampaignMembers Indexes
CREATE INDEX IX_CampaignMembers_CampaignId ON CampaignMembers(campaign_id);          -- Index on campaign_id for faster lookups
CREATE INDEX IX_CampaignMembers_UserId ON CampaignMembers(user_id);                  -- Index on user_id for faster lookups
CREATE INDEX IX_CampaignMembers_Role ON CampaignMembers(role);                       -- Index on role for filtering members by role
CREATE INDEX IX_CampaignMembers_IsActive ON CampaignMembers(is_active);              -- Index on is_active for filtering active members

-- ModuleBasicCounter Indexes
CREATE INDEX IX_ModuleBasicCounter_ModuleId ON ModuleBasicCounter(module_id);        -- Index on module_id for faster lookups





-- End of StratPad Database Schema
