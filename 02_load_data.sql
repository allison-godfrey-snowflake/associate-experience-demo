-- ============================================================================
-- ASSOCIATE EXPERIENCE PLATFORM - DATA LOADING SCRIPT
-- Run this after 01_create_tables.sql
-- ============================================================================

USE DATABASE ASSOCIATE_EXPERIENCE;
USE SCHEMA PLATFORM;

-- ============================================================================
-- CREATE STAGE FOR DATA FILES
-- Option 1: Internal Stage (upload files to Snowflake)
-- ============================================================================

CREATE OR REPLACE STAGE ASSOCIATE_EXP_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for Associate Experience demo data files';

-- Upload CSV files to stage (run from SnowSQL or Snowsight):
-- PUT file:///path/to/ASSOCIATE_EXPERIENCE_EVENTS.csv @ASSOCIATE_EXP_STAGE;
-- PUT file:///path/to/SUPPORT_TICKETS.csv @ASSOCIATE_EXP_STAGE;
-- PUT file:///path/to/INCIDENTS_AND_CHANGES.csv @ASSOCIATE_EXP_STAGE;
-- PUT file:///path/to/KNOWLEDGE_BASE.csv @ASSOCIATE_EXP_STAGE;
-- PUT file:///path/to/ASSOCIATE_FEEDBACK.csv @ASSOCIATE_EXP_STAGE;

-- ============================================================================
-- CREATE FILE FORMAT
-- ============================================================================

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    ESCAPE_UNENCLOSED_FIELD = NONE
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE;

-- ============================================================================
-- LOAD DATA FROM STAGE
-- ============================================================================

-- Load Associate Experience Events
COPY INTO ASSOCIATE_EXPERIENCE_EVENTS (
    EVENT_ID,
    EVENT_TIMESTAMP,
    ASSOCIATE_ID,
    DEVICE_ID,
    EVENT_TYPE,
    APPLICATION_NAME,
    SEVERITY,
    RESPONSE_TIME_MS,
    ERROR_CODE,
    BUSINESS_UNIT,
    LOCATION,
    WORK_TYPE,
    ERROR_MESSAGE,
    USER_ACTION_CONTEXT
)
FROM (
    SELECT 
        $1,                                     -- EVENT_ID
        TO_TIMESTAMP_NTZ($2),                   -- EVENT_TIMESTAMP
        $3,                                     -- ASSOCIATE_ID
        $4,                                     -- DEVICE_ID
        $5,                                     -- EVENT_TYPE
        $6,                                     -- APPLICATION_NAME
        $7,                                     -- SEVERITY
        TRY_CAST($8 AS INTEGER),               -- RESPONSE_TIME_MS
        $9,                                     -- ERROR_CODE
        $10,                                    -- BUSINESS_UNIT
        $11,                                    -- LOCATION
        $12,                                    -- WORK_TYPE
        $13,                                    -- ERROR_MESSAGE
        $14                                     -- USER_ACTION_CONTEXT
    FROM @ASSOCIATE_EXP_STAGE/ASSOCIATE_EXPERIENCE_EVENTS.csv
)
FILE_FORMAT = CSV_FORMAT
ON_ERROR = CONTINUE;

-- Load Support Tickets
COPY INTO SUPPORT_TICKETS (
    TICKET_ID,
    CREATED_AT,
    RESOLVED_AT,
    ASSOCIATE_ID,
    CATEGORY,
    SUBCATEGORY,
    PRIORITY,
    STATUS,
    RESOLUTION_HOURS,
    REOPEN_COUNT,
    CSAT_SCORE,
    RELATED_EVENT_IDS,
    TICKET_DESCRIPTION,
    RESOLUTION_NOTES,
    CONVERSATION_TRANSCRIPT
)
FROM (
    SELECT 
        $1,                                     -- TICKET_ID
        TO_TIMESTAMP_NTZ($2),                   -- CREATED_AT
        TRY_TO_TIMESTAMP_NTZ($3),              -- RESOLVED_AT
        $4,                                     -- ASSOCIATE_ID
        $5,                                     -- CATEGORY
        $6,                                     -- SUBCATEGORY
        $7,                                     -- PRIORITY
        $8,                                     -- STATUS
        TRY_CAST($9 AS FLOAT),                 -- RESOLUTION_HOURS
        TRY_CAST($10 AS INTEGER),              -- REOPEN_COUNT
        TRY_CAST($11 AS INTEGER),              -- CSAT_SCORE
        TRY_PARSE_JSON($12),                   -- RELATED_EVENT_IDS (array)
        $13,                                    -- TICKET_DESCRIPTION
        $14,                                    -- RESOLUTION_NOTES
        $15                                     -- CONVERSATION_TRANSCRIPT
    FROM @ASSOCIATE_EXP_STAGE/SUPPORT_TICKETS.csv
)
FILE_FORMAT = CSV_FORMAT
ON_ERROR = CONTINUE;

-- Load Incidents and Changes
COPY INTO INCIDENTS_AND_CHANGES (
    RECORD_ID,
    RECORD_TYPE,
    TIMESTAMP,
    AFFECTED_SYSTEMS,
    SEVERITY,
    STATUS,
    DURATION_MINUTES,
    AFFECTED_ASSOCIATE_COUNT,
    MTTR_MINUTES,
    IS_REGULATORY_REPORTABLE,
    TITLE,
    DESCRIPTION,
    ROOT_CAUSE_ANALYSIS,
    REMEDIATION_STEPS,
    LESSONS_LEARNED,
    REGULATORY_NARRATIVE
)
FROM (
    SELECT 
        $1,                                     -- RECORD_ID
        $2,                                     -- RECORD_TYPE
        TO_TIMESTAMP_NTZ($3),                   -- TIMESTAMP
        TRY_PARSE_JSON($4),                    -- AFFECTED_SYSTEMS (array)
        $5,                                     -- SEVERITY
        $6,                                     -- STATUS
        TRY_CAST($7 AS INTEGER),               -- DURATION_MINUTES
        TRY_CAST($8 AS INTEGER),               -- AFFECTED_ASSOCIATE_COUNT
        TRY_CAST($9 AS INTEGER),               -- MTTR_MINUTES
        TRY_CAST($10 AS BOOLEAN),              -- IS_REGULATORY_REPORTABLE
        $11,                                    -- TITLE
        $12,                                    -- DESCRIPTION
        $13,                                    -- ROOT_CAUSE_ANALYSIS
        $14,                                    -- REMEDIATION_STEPS
        $15,                                    -- LESSONS_LEARNED
        $16                                     -- REGULATORY_NARRATIVE
    FROM @ASSOCIATE_EXP_STAGE/INCIDENTS_AND_CHANGES.csv
)
FILE_FORMAT = CSV_FORMAT
ON_ERROR = CONTINUE;

-- Load Knowledge Base
COPY INTO KNOWLEDGE_BASE (
    ARTICLE_ID,
    TITLE,
    CATEGORY,
    APPLICATION,
    ARTICLE_TYPE,
    CREATED_DATE,
    LAST_UPDATED,
    VIEW_COUNT,
    HELPFUL_VOTES,
    LINKED_TICKET_COUNT,
    CONTENT,
    KEYWORDS
)
FROM (
    SELECT 
        $1,                                     -- ARTICLE_ID
        $2,                                     -- TITLE
        $3,                                     -- CATEGORY
        $4,                                     -- APPLICATION
        $5,                                     -- ARTICLE_TYPE
        TRY_TO_DATE($6),                       -- CREATED_DATE
        TRY_TO_DATE($7),                       -- LAST_UPDATED
        TRY_CAST($8 AS INTEGER),               -- VIEW_COUNT
        TRY_CAST($9 AS INTEGER),               -- HELPFUL_VOTES
        TRY_CAST($10 AS INTEGER),              -- LINKED_TICKET_COUNT
        $11,                                    -- CONTENT
        $12                                     -- KEYWORDS
    FROM @ASSOCIATE_EXP_STAGE/KNOWLEDGE_BASE.csv
)
FILE_FORMAT = CSV_FORMAT
ON_ERROR = CONTINUE;

-- Load Associate Feedback
COPY INTO ASSOCIATE_FEEDBACK (
    FEEDBACK_ID,
    SUBMITTED_AT,
    ASSOCIATE_ID,
    FEEDBACK_SOURCE,
    RELATED_APPLICATION,
    RATING,
    SENTIMENT,
    BUSINESS_UNIT,
    FEEDBACK_TEXT,
    TOPICS_EXTRACTED
)
FROM (
    SELECT 
        $1,                                     -- FEEDBACK_ID
        TO_TIMESTAMP_NTZ($2),                   -- SUBMITTED_AT
        $3,                                     -- ASSOCIATE_ID
        $4,                                     -- FEEDBACK_SOURCE
        $5,                                     -- RELATED_APPLICATION
        TRY_CAST($6 AS INTEGER),               -- RATING
        $7,                                     -- SENTIMENT
        $8,                                     -- BUSINESS_UNIT
        $9,                                     -- FEEDBACK_TEXT
        $10                                     -- TOPICS_EXTRACTED
    FROM @ASSOCIATE_EXP_STAGE/ASSOCIATE_FEEDBACK.csv
)
FILE_FORMAT = CSV_FORMAT
ON_ERROR = CONTINUE;

-- ============================================================================
-- VERIFY DATA LOAD
-- ============================================================================

SELECT 'ASSOCIATE_EXPERIENCE_EVENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM ASSOCIATE_EXPERIENCE_EVENTS
UNION ALL
SELECT 'SUPPORT_TICKETS', COUNT(*) FROM SUPPORT_TICKETS
UNION ALL
SELECT 'INCIDENTS_AND_CHANGES', COUNT(*) FROM INCIDENTS_AND_CHANGES
UNION ALL
SELECT 'KNOWLEDGE_BASE', COUNT(*) FROM KNOWLEDGE_BASE
UNION ALL
SELECT 'ASSOCIATE_FEEDBACK', COUNT(*) FROM ASSOCIATE_FEEDBACK;

-- ============================================================================
-- SAMPLE QUERIES TO VERIFY DATA
-- ============================================================================

-- Check experience events
SELECT * FROM ASSOCIATE_EXPERIENCE_EVENTS LIMIT 5;

-- Check tickets
SELECT * FROM SUPPORT_TICKETS LIMIT 5;

-- Check incidents
SELECT * FROM INCIDENTS_AND_CHANGES WHERE RECORD_TYPE = 'INCIDENT' LIMIT 3;

-- Check knowledge base articles
SELECT ARTICLE_ID, TITLE, CATEGORY FROM KNOWLEDGE_BASE LIMIT 5;

-- Check feedback
SELECT * FROM ASSOCIATE_FEEDBACK LIMIT 5;
