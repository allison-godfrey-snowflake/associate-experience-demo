-- ============================================================================
-- ASSOCIATE EXPERIENCE PLATFORM - SNOWFLAKE TABLE DEFINITIONS
-- Capital One Associate Experience Team Demo
-- ============================================================================

-- Create database and schema
CREATE DATABASE IF NOT EXISTS ASSOCIATE_EXPERIENCE;
USE DATABASE ASSOCIATE_EXPERIENCE;

CREATE SCHEMA IF NOT EXISTS PLATFORM;
USE SCHEMA PLATFORM;

-- ============================================================================
-- TABLE 1: ASSOCIATE_EXPERIENCE_EVENTS
-- Core fact table capturing every digital experience signal
-- ============================================================================

CREATE OR REPLACE TABLE ASSOCIATE_EXPERIENCE_EVENTS (
    EVENT_ID VARCHAR(50) PRIMARY KEY,
    EVENT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    ASSOCIATE_ID VARCHAR(20) NOT NULL,
    DEVICE_ID VARCHAR(20),
    EVENT_TYPE VARCHAR(50) NOT NULL,           -- 'APP_ERROR', 'SLOW_RESPONSE', 'LOGIN_FAILURE', 'CRASH', 'TIMEOUT'
    APPLICATION_NAME VARCHAR(100) NOT NULL,
    SEVERITY VARCHAR(20),                       -- 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
    RESPONSE_TIME_MS INTEGER,
    ERROR_CODE VARCHAR(50),
    BUSINESS_UNIT VARCHAR(100),
    LOCATION VARCHAR(100),
    WORK_TYPE VARCHAR(20),                      -- 'REMOTE', 'HYBRID', 'ONSITE'
    ERROR_MESSAGE TEXT,                         -- UNSTRUCTURED: Full error text/stack trace
    USER_ACTION_CONTEXT TEXT                    -- UNSTRUCTURED: What user was doing when error occurred
)
COMMENT = 'Digital experience events capturing application errors, performance issues, and user experience signals';

-- ============================================================================
-- TABLE 2: SUPPORT_TICKETS
-- Help desk interactions with full conversation context
-- ============================================================================

CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    TICKET_ID VARCHAR(50) PRIMARY KEY,
    CREATED_AT TIMESTAMP_NTZ NOT NULL,
    RESOLVED_AT TIMESTAMP_NTZ,
    ASSOCIATE_ID VARCHAR(20) NOT NULL,
    CATEGORY VARCHAR(50) NOT NULL,              -- 'Hardware', 'Software', 'Access', 'Network'
    SUBCATEGORY VARCHAR(100),
    PRIORITY VARCHAR(10) NOT NULL,              -- 'P1', 'P2', 'P3', 'P4'
    STATUS VARCHAR(20) NOT NULL,                -- 'Open', 'In Progress', 'Resolved', 'Closed'
    RESOLUTION_HOURS FLOAT,
    REOPEN_COUNT INTEGER DEFAULT 0,
    CSAT_SCORE INTEGER,                         -- 1-5 satisfaction score
    RELATED_EVENT_IDS ARRAY,                    -- FK array to ASSOCIATE_EXPERIENCE_EVENTS
    TICKET_DESCRIPTION TEXT NOT NULL,           -- UNSTRUCTURED: Initial problem report
    RESOLUTION_NOTES TEXT,                      -- UNSTRUCTURED: What fixed the issue
    CONVERSATION_TRANSCRIPT TEXT                -- UNSTRUCTURED: Full support conversation
)
COMMENT = 'IT support tickets with structured metadata and unstructured conversation/resolution details';

-- ============================================================================
-- TABLE 3: INCIDENTS_AND_CHANGES
-- System-level incidents and change records for correlation analysis
-- ============================================================================

CREATE OR REPLACE TABLE INCIDENTS_AND_CHANGES (
    RECORD_ID VARCHAR(50) PRIMARY KEY,
    RECORD_TYPE VARCHAR(20) NOT NULL,           -- 'INCIDENT' or 'CHANGE'
    TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    AFFECTED_SYSTEMS ARRAY,                     -- Array of affected applications/systems
    SEVERITY VARCHAR(20),                       -- 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW' (for incidents)
    STATUS VARCHAR(30),                         -- 'Investigating', 'Resolved', 'Completed', 'Rolled Back'
    DURATION_MINUTES INTEGER,
    AFFECTED_ASSOCIATE_COUNT INTEGER,
    MTTR_MINUTES INTEGER,                       -- Mean Time To Resolve
    IS_REGULATORY_REPORTABLE BOOLEAN DEFAULT FALSE,
    TITLE VARCHAR(500) NOT NULL,
    DESCRIPTION TEXT NOT NULL,                  -- UNSTRUCTURED: What happened
    ROOT_CAUSE_ANALYSIS TEXT,                   -- UNSTRUCTURED: Why it happened (incidents)
    REMEDIATION_STEPS TEXT,                     -- UNSTRUCTURED: How it was fixed
    LESSONS_LEARNED TEXT,                       -- UNSTRUCTURED: Prevention measures
    REGULATORY_NARRATIVE TEXT                   -- UNSTRUCTURED: Board/compliance summary
)
COMMENT = 'Incidents and change records with detailed narratives for root cause analysis and compliance reporting';

-- ============================================================================
-- TABLE 4: KNOWLEDGE_BASE
-- Searchable IT documentation for self-service and support
-- ============================================================================

CREATE OR REPLACE TABLE KNOWLEDGE_BASE (
    ARTICLE_ID VARCHAR(50) PRIMARY KEY,
    TITLE VARCHAR(500) NOT NULL,
    CATEGORY VARCHAR(50) NOT NULL,
    APPLICATION VARCHAR(100),
    ARTICLE_TYPE VARCHAR(30),                   -- 'HOW_TO', 'TROUBLESHOOTING', 'POLICY', 'FAQ'
    CREATED_DATE DATE,
    LAST_UPDATED DATE,
    VIEW_COUNT INTEGER DEFAULT 0,
    HELPFUL_VOTES INTEGER DEFAULT 0,
    LINKED_TICKET_COUNT INTEGER DEFAULT 0,      -- How often this article is used in resolutions
    CONTENT TEXT NOT NULL,                      -- UNSTRUCTURED: Full article body (markdown)
    KEYWORDS TEXT                               -- UNSTRUCTURED: Search terms
)
COMMENT = 'IT knowledge base articles for self-service troubleshooting and support reference';

-- ============================================================================
-- TABLE 5: ASSOCIATE_FEEDBACK
-- Qualitative feedback and sentiment data
-- ============================================================================

CREATE OR REPLACE TABLE ASSOCIATE_FEEDBACK (
    FEEDBACK_ID VARCHAR(50) PRIMARY KEY,
    SUBMITTED_AT TIMESTAMP_NTZ NOT NULL,
    ASSOCIATE_ID VARCHAR(20),                   -- Optional for anonymous feedback
    FEEDBACK_SOURCE VARCHAR(30),                -- 'SURVEY', 'IN_APP', 'SLACK_BOT', 'EMAIL'
    RELATED_APPLICATION VARCHAR(100),
    RATING INTEGER,                             -- 1-5 scale
    SENTIMENT VARCHAR(20),                      -- 'POSITIVE', 'NEUTRAL', 'NEGATIVE'
    BUSINESS_UNIT VARCHAR(100),
    FEEDBACK_TEXT TEXT NOT NULL,                -- UNSTRUCTURED: What they said
    TOPICS_EXTRACTED TEXT                       -- UNSTRUCTURED: AI-extracted themes
)
COMMENT = 'Associate feedback with qualitative comments and sentiment for experience analysis';

-- ============================================================================
-- CREATE VIEWS FOR COMMON ANALYSES
-- ============================================================================

-- View: Experience Events with Application Summary
CREATE OR REPLACE VIEW V_APPLICATION_HEALTH AS
SELECT 
    APPLICATION_NAME,
    DATE(EVENT_TIMESTAMP) AS EVENT_DATE,
    COUNT(*) AS TOTAL_EVENTS,
    COUNT(CASE WHEN SEVERITY = 'CRITICAL' THEN 1 END) AS CRITICAL_COUNT,
    COUNT(CASE WHEN SEVERITY = 'HIGH' THEN 1 END) AS HIGH_COUNT,
    COUNT(CASE WHEN SEVERITY = 'MEDIUM' THEN 1 END) AS MEDIUM_COUNT,
    COUNT(CASE WHEN SEVERITY = 'LOW' THEN 1 END) AS LOW_COUNT,
    AVG(RESPONSE_TIME_MS) AS AVG_RESPONSE_TIME_MS,
    COUNT(DISTINCT ASSOCIATE_ID) AS AFFECTED_ASSOCIATES
FROM ASSOCIATE_EXPERIENCE_EVENTS
GROUP BY APPLICATION_NAME, DATE(EVENT_TIMESTAMP);

-- View: Support Ticket Metrics
CREATE OR REPLACE VIEW V_TICKET_METRICS AS
SELECT
    CATEGORY,
    SUBCATEGORY,
    DATE(CREATED_AT) AS TICKET_DATE,
    COUNT(*) AS TICKET_COUNT,
    AVG(RESOLUTION_HOURS) AS AVG_RESOLUTION_HOURS,
    AVG(CSAT_SCORE) AS AVG_CSAT,
    SUM(REOPEN_COUNT) AS TOTAL_REOPENS,
    COUNT(CASE WHEN PRIORITY = 'P1' THEN 1 END) AS P1_COUNT,
    COUNT(CASE WHEN PRIORITY = 'P2' THEN 1 END) AS P2_COUNT
FROM SUPPORT_TICKETS
GROUP BY CATEGORY, SUBCATEGORY, DATE(CREATED_AT);

-- View: Feedback Sentiment Trends
CREATE OR REPLACE VIEW V_SENTIMENT_TRENDS AS
SELECT
    RELATED_APPLICATION,
    DATE(SUBMITTED_AT) AS FEEDBACK_DATE,
    COUNT(*) AS FEEDBACK_COUNT,
    AVG(RATING) AS AVG_RATING,
    COUNT(CASE WHEN SENTIMENT = 'POSITIVE' THEN 1 END) AS POSITIVE_COUNT,
    COUNT(CASE WHEN SENTIMENT = 'NEUTRAL' THEN 1 END) AS NEUTRAL_COUNT,
    COUNT(CASE WHEN SENTIMENT = 'NEGATIVE' THEN 1 END) AS NEGATIVE_COUNT
FROM ASSOCIATE_FEEDBACK
GROUP BY RELATED_APPLICATION, DATE(SUBMITTED_AT);

-- ============================================================================
-- GRANTS (adjust role names as needed)
-- ============================================================================

-- Example grants - adjust to your role structure
-- GRANT USAGE ON DATABASE ASSOCIATE_EXPERIENCE TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON SCHEMA PLATFORM TO ROLE ANALYST_ROLE;
-- GRANT SELECT ON ALL TABLES IN SCHEMA PLATFORM TO ROLE ANALYST_ROLE;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA PLATFORM TO ROLE ANALYST_ROLE;

-- ============================================================================
-- SHOW CREATED OBJECTS
-- ============================================================================

SHOW TABLES IN SCHEMA PLATFORM;
SHOW VIEWS IN SCHEMA PLATFORM;
