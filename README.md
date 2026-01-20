# Associate Experience Platform Demo
## Snowflake Intelligence for Capital One

This demo showcases Snowflake Intelligence capabilities for the **Associate Experience Team** at Capital One, demonstrating how to combine structured analytics with semantic search over unstructured data to improve the digital experience for associates.

---

## 📁 Project Structure

```
demo - associate exp/
├── README.md                           # This file
├── DEMO_PROMPTS.md                     # 25+ curated demo prompts organized by category
├── data/
│   ├── ASSOCIATE_EXPERIENCE_EVENTS.csv # 50 experience events (errors, timeouts, crashes)
│   ├── SUPPORT_TICKETS.csv             # 20 IT support tickets with conversations
│   ├── INCIDENTS_AND_CHANGES.csv       # 13 incidents + changes with narratives
│   ├── KNOWLEDGE_BASE.csv              # 10 IT knowledge base articles
│   └── ASSOCIATE_FEEDBACK.csv          # 30 qualitative feedback entries
└── scripts/
    ├── 01_create_tables.sql            # DDL for all tables and views
    ├── 02_load_data.sql                # Data loading from stage
    └── 03_create_cortex_search.sql     # Cortex Search service definitions
```

---

## 🚀 Quick Start

### Step 1: Create Database and Tables

Run the DDL script to create the database, schema, and tables:

```sql
-- In Snowsight or SnowSQL
!source scripts/01_create_tables.sql
```

Or copy/paste the contents of `01_create_tables.sql` into a Snowsight worksheet and run.

### Step 2: Upload Data Files

Upload the CSV files to a Snowflake stage:

```sql
-- Using SnowSQL CLI
PUT file://data/ASSOCIATE_EXPERIENCE_EVENTS.csv @ASSOCIATE_EXPERIENCE.PLATFORM.ASSOCIATE_EXP_STAGE;
PUT file://data/SUPPORT_TICKETS.csv @ASSOCIATE_EXPERIENCE.PLATFORM.ASSOCIATE_EXP_STAGE;
PUT file://data/INCIDENTS_AND_CHANGES.csv @ASSOCIATE_EXPERIENCE.PLATFORM.ASSOCIATE_EXP_STAGE;
PUT file://data/KNOWLEDGE_BASE.csv @ASSOCIATE_EXPERIENCE.PLATFORM.ASSOCIATE_EXP_STAGE;
PUT file://data/ASSOCIATE_FEEDBACK.csv @ASSOCIATE_EXPERIENCE.PLATFORM.ASSOCIATE_EXP_STAGE;
```

Or upload via Snowsight UI: **Data → Add Data → Load files into a Stage**

### Step 3: Load Data

Run the data loading script:

```sql
!source scripts/02_load_data.sql
```

### Step 4: Create Cortex Search Services

Run the Cortex Search setup script:

```sql
!source scripts/03_create_cortex_search.sql
```

**Note:** Update `WAREHOUSE = COMPUTE_WH` to match your warehouse name.

### Step 5: Run the Demo

Open `DEMO_PROMPTS.md` and try the prompts in Snowflake Intelligence!

---

## 📊 Data Model

### Core Tables

| Table | Records | Description |
|-------|---------|-------------|
| `ASSOCIATE_EXPERIENCE_EVENTS` | 50 | Digital experience signals (errors, timeouts, crashes) |
| `SUPPORT_TICKETS` | 20 | IT help desk tickets with full conversations |
| `INCIDENTS_AND_CHANGES` | 13 | System incidents and change records |
| `KNOWLEDGE_BASE` | 10 | IT documentation and troubleshooting guides |
| `ASSOCIATE_FEEDBACK` | 30 | Qualitative feedback with sentiment |

### Key Relationships

- **Events → Tickets**: Tickets reference related event IDs
- **Incidents ↔ Changes**: Temporal correlation (incidents often follow changes)
- **Tickets → Knowledge Base**: Resolution notes reference KB articles
- **All → Feedback**: Feedback relates to applications across all sources

### Structured vs. Unstructured Fields

Each table contains both:

| Data Type | Purpose | Example Fields |
|-----------|---------|----------------|
| **Structured** | Filtering, aggregation, metrics | `SEVERITY`, `RESPONSE_TIME_MS`, `CSAT_SCORE` |
| **Unstructured** | Semantic search, context | `ERROR_MESSAGE`, `ROOT_CAUSE_ANALYSIS`, `FEEDBACK_TEXT` |

---

## 🔍 Cortex Search Services

| Service | Source | Search Over | Filters Available |
|---------|--------|-------------|-------------------|
| `TICKET_SEARCH` | Support Tickets | Ticket descriptions, resolutions | Category, Priority, Status |
| `KNOWLEDGE_SEARCH` | Knowledge Base | Article content | Category, Application, Type |
| `INCIDENT_SEARCH` | Incidents/Changes | Descriptions, RCA | Severity, Type, Regulatory |
| `FEEDBACK_SEARCH` | Feedback | Feedback text | Sentiment, Application, Source |

---

## 🎭 Demo Scenario: "The Monday Morning Incident"

The data tells a cohesive story:

1. **Friday Night**: Security patch CHG-2024-0341 deployed to Workday (enhanced attachment scanning)
2. **Monday 8:45 AM**: Associates start reporting expense report timeouts
3. **Monday 9:00 AM**: Tickets flood in; IT scrambles to find the cause
4. **Monday 10:15 AM**: Engineering scales attachment processing; partial relief
5. **Monday 11:30 AM**: Full resolution; workaround communicated
6. **Monday Afternoon**: Associates provide feedback - frustrated about communication gaps

This scenario enables realistic demo conversations about:
- Root cause investigation
- Change impact analysis
- Associate sentiment
- Proactive communication improvements

---

## 💡 Demo Tips

### For Maximum Impact

1. **Start with a problem**: "Are there any issues affecting associates right now?"
2. **Drill into root cause**: "What happened with Workday on Monday?"
3. **Show the human element**: "What are associates saying about it?"
4. **Demonstrate resolution**: "How do we fix expense timeouts?"
5. **End with insights**: "What should we do to prevent this?"

### Key Differentiators to Highlight

- **Unified data**: Structured metrics + unstructured narratives in one query
- **Semantic understanding**: Natural language questions, not SQL
- **Cross-source correlation**: Connects events, tickets, incidents, changes, feedback
- **Regulatory awareness**: Identifies compliance implications automatically

---

## 🔧 Customization

### Adding Your Own Data

To extend the demo with additional data:

1. Add rows to the CSV files following the existing format
2. Re-run the `02_load_data.sql` script (uses `COPY INTO` with `ON_ERROR = CONTINUE`)
3. Cortex Search services will auto-refresh based on `TARGET_LAG`

### Adjusting for Your Environment

Update these values in the SQL scripts:
- `WAREHOUSE = COMPUTE_WH` → Your warehouse name
- `DATABASE` and `SCHEMA` names if different
- File paths in PUT commands

---

## 📞 Support

For questions about this demo, contact the Snowflake team.

---

*Built for Capital One Associate Experience Team - January 2024*
