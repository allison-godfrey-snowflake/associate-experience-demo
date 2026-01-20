-- ============================================================================
-- ASSOCIATE EXPERIENCE PLATFORM - CORTEX SEARCH SERVICES
-- Creates semantic search capabilities over unstructured text fields
-- Run this after 02_load_data.sql
-- ============================================================================

USE DATABASE ASSOCIATE_EXPERIENCE;
USE SCHEMA PLATFORM;

-- ============================================================================
-- CORTEX SEARCH SERVICE 1: SUPPORT TICKETS
-- Enables semantic search over ticket descriptions and resolutions
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE TICKET_SEARCH
    ON TICKET_DESCRIPTION
    ATTRIBUTES CATEGORY, SUBCATEGORY, PRIORITY, STATUS, APPLICATION_NAME
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            TICKET_ID,
            TICKET_DESCRIPTION,
            RESOLUTION_NOTES,
            CONVERSATION_TRANSCRIPT,
            CATEGORY,
            SUBCATEGORY,
            PRIORITY,
            STATUS,
            CREATED_AT,
            RESOLVED_AT,
            ASSOCIATE_ID,
            CSAT_SCORE,
            -- Extract application name from subcategory for filtering
            SUBCATEGORY AS APPLICATION_NAME
        FROM SUPPORT_TICKETS
    );

-- Example queries for TICKET_SEARCH:
-- Find tickets about VPN issues:
--   SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--       'ASSOCIATE_EXPERIENCE.PLATFORM.TICKET_SEARCH',
--       'VPN connection problems certificate error',
--       10
--     )
--   );

-- ============================================================================
-- CORTEX SEARCH SERVICE 2: KNOWLEDGE BASE ARTICLES
-- Enables RAG over IT documentation
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE KNOWLEDGE_SEARCH
    ON CONTENT
    ATTRIBUTES CATEGORY, APPLICATION, ARTICLE_TYPE
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            ARTICLE_ID,
            TITLE,
            CONTENT,
            KEYWORDS,
            CATEGORY,
            APPLICATION,
            ARTICLE_TYPE,
            LAST_UPDATED,
            VIEW_COUNT,
            HELPFUL_VOTES,
            LINKED_TICKET_COUNT
        FROM KNOWLEDGE_BASE
    );

-- Example queries for KNOWLEDGE_SEARCH:
-- Find how to fix expense report timeouts:
--   SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--       'ASSOCIATE_EXPERIENCE.PLATFORM.KNOWLEDGE_SEARCH',
--       'expense report timeout slow attachment upload',
--       5
--     )
--   );

-- ============================================================================
-- CORTEX SEARCH SERVICE 3: INCIDENTS AND ROOT CAUSE ANALYSIS
-- Enables semantic search over incident narratives
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE INCIDENT_SEARCH
    ON DESCRIPTION
    ATTRIBUTES RECORD_TYPE, SEVERITY, STATUS, IS_REGULATORY_REPORTABLE
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            RECORD_ID,
            RECORD_TYPE,
            TITLE,
            DESCRIPTION,
            ROOT_CAUSE_ANALYSIS,
            REMEDIATION_STEPS,
            LESSONS_LEARNED,
            REGULATORY_NARRATIVE,
            SEVERITY,
            STATUS,
            TIMESTAMP,
            AFFECTED_ASSOCIATE_COUNT,
            DURATION_MINUTES,
            IS_REGULATORY_REPORTABLE,
            ARRAY_TO_STRING(AFFECTED_SYSTEMS, ', ') AS AFFECTED_SYSTEMS_STR
        FROM INCIDENTS_AND_CHANGES
    );

-- Example queries for INCIDENT_SEARCH:
-- Find incidents related to Workday:
--   SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--       'ASSOCIATE_EXPERIENCE.PLATFORM.INCIDENT_SEARCH',
--       'Workday expense attachment processing timeout',
--       5
--     )
--   );

-- ============================================================================
-- CORTEX SEARCH SERVICE 4: ASSOCIATE FEEDBACK
-- Enables semantic search over qualitative feedback
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE FEEDBACK_SEARCH
    ON FEEDBACK_TEXT
    ATTRIBUTES RELATED_APPLICATION, SENTIMENT, FEEDBACK_SOURCE, BUSINESS_UNIT
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            FEEDBACK_ID,
            FEEDBACK_TEXT,
            TOPICS_EXTRACTED,
            RELATED_APPLICATION,
            SENTIMENT,
            FEEDBACK_SOURCE,
            BUSINESS_UNIT,
            RATING,
            SUBMITTED_AT,
            ASSOCIATE_ID
        FROM ASSOCIATE_FEEDBACK
    );

-- Example queries for FEEDBACK_SEARCH:
-- Find feedback about communication and proactive alerting:
--   SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--       'ASSOCIATE_EXPERIENCE.PLATFORM.FEEDBACK_SEARCH',
--       'proactive communication status updates alerting',
--       10
--     )
--   );

-- ============================================================================
-- VERIFY CORTEX SEARCH SERVICES
-- ============================================================================

SHOW CORTEX SEARCH SERVICES IN SCHEMA PLATFORM;

-- ============================================================================
-- EXAMPLE: COMBINED SEARCH FUNCTION
-- Custom function to search across multiple sources
-- ============================================================================

CREATE OR REPLACE FUNCTION UNIFIED_EXPERIENCE_SEARCH(query_text VARCHAR, max_results INT)
RETURNS TABLE (
    SOURCE VARCHAR,
    ID VARCHAR,
    TITLE VARCHAR,
    CONTENT_SNIPPET VARCHAR,
    RELEVANCE_SCORE FLOAT
)
AS
$$
    -- Search tickets
    SELECT 
        'TICKET' AS SOURCE,
        TICKET_ID AS ID,
        CONCAT('Ticket: ', CATEGORY, ' - ', SUBCATEGORY) AS TITLE,
        LEFT(TICKET_DESCRIPTION, 500) AS CONTENT_SNIPPET,
        SCORE AS RELEVANCE_SCORE
    FROM TABLE(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'ASSOCIATE_EXPERIENCE.PLATFORM.TICKET_SEARCH',
            query_text,
            max_results
        )
    )
    
    UNION ALL
    
    -- Search knowledge base
    SELECT 
        'KNOWLEDGE' AS SOURCE,
        ARTICLE_ID AS ID,
        TITLE,
        LEFT(CONTENT, 500) AS CONTENT_SNIPPET,
        SCORE AS RELEVANCE_SCORE
    FROM TABLE(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'ASSOCIATE_EXPERIENCE.PLATFORM.KNOWLEDGE_SEARCH',
            query_text,
            max_results
        )
    )
    
    UNION ALL
    
    -- Search incidents
    SELECT 
        'INCIDENT' AS SOURCE,
        RECORD_ID AS ID,
        TITLE,
        LEFT(DESCRIPTION, 500) AS CONTENT_SNIPPET,
        SCORE AS RELEVANCE_SCORE
    FROM TABLE(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'ASSOCIATE_EXPERIENCE.PLATFORM.INCIDENT_SEARCH',
            query_text,
            max_results
        )
    )
    
    ORDER BY RELEVANCE_SCORE DESC
    LIMIT max_results * 3
$$;

-- Example usage:
-- SELECT * FROM TABLE(UNIFIED_EXPERIENCE_SEARCH('VPN certificate connection issues', 5));
