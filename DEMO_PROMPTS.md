# Snowflake Intelligence Demo Prompts
## Associate Experience Platform - Capital One

This document contains curated prompts for demonstrating Snowflake Intelligence capabilities against the Associate Experience Platform data. Each prompt showcases the power of combining **structured data analytics** with **unstructured semantic search**.

---

## 🎯 Demo Setup Checklist

Before running the demo:
1. ✅ Tables created and data loaded (run `01_create_tables.sql`, `02_load_data.sql`)
2. ✅ Cortex Search services created (run `03_create_cortex_search.sql`)
3. ✅ Verify data counts: 50 events, 20 tickets, 13 incidents/changes, 10 KB articles, 30 feedback records
4. ✅ Snowflake Intelligence enabled on your account

---

## 📊 Category 1: Real-Time Detection & Monitoring

### Prompt 1.1: Application Health Overview
> **"What applications are experiencing the most issues this week? Show me the breakdown by severity."**

**What it demonstrates:**
- Aggregation of experience events by application
- Severity distribution analysis
- Structured data analytics

**Expected insights:** Workday shows highest error count, especially on January 15th

---

### Prompt 1.2: Emerging Issues Detection
> **"Are there any unusual spikes in errors or performance issues in the last 7 days? What's causing them?"**

**What it demonstrates:**
- Time-series anomaly detection
- Correlation between events and root cause
- Combines structured metrics with unstructured narratives

**Expected insights:** Major spike on Jan 15 related to Workday expense module, correlated with security patch

---

### Prompt 1.3: Current System Status
> **"Give me a status summary of all major systems. Are there any active incidents or known issues?"**

**What it demonstrates:**
- Real-time operational awareness
- Incident status reporting
- Structured + unstructured incident data

---

## 🔍 Category 2: Root Cause Analysis

### Prompt 2.1: Incident Investigation
> **"Workday had a lot of errors on January 15th. What happened and why?"**

**What it demonstrates:**
- Semantic search over incident narratives
- Root cause explanation in natural language
- Connection between events, incidents, and changes

**Expected insights:** Combines INC-2024-0892 details with CHG-2024-0341 (security patch)

---

### Prompt 2.2: Change Impact Analysis
> **"Were there any changes deployed over the weekend of January 13-14 that might have caused Monday's issues?"**

**What it demonstrates:**
- Temporal correlation between changes and incidents
- Change record search
- Root cause investigation workflow

**Expected insights:** Links Workday Security Patch 23.4.1 to attachment processing slowdown

---

### Prompt 2.3: Pattern Recognition
> **"What's the most common root cause for VPN-related tickets? Is there a pattern?"**

**What it demonstrates:**
- Semantic clustering of ticket descriptions
- Pattern extraction from unstructured text
- Historical analysis

**Expected insights:** Certificate issues are common theme; often related to security updates

---

### Prompt 2.4: Deep Dive Investigation
> **"Tell me everything about incident INC-2024-0892 - what happened, who was affected, what was the root cause, and what did we learn?"**

**What it demonstrates:**
- Single incident deep dive
- Rich narrative synthesis
- Regulatory narrative inclusion

---

## 👥 Category 3: Impact Assessment

### Prompt 3.1: Associate Impact Quantification
> **"How many associates were affected by IT issues last week, and what was the business impact by department?"**

**What it demonstrates:**
- Impact metrics aggregation
- Business unit breakdown
- Structured metrics (counts, duration)

---

### Prompt 3.2: Sentiment Analysis
> **"What's the overall associate sentiment about IT systems this month? What are people most frustrated about?"**

**What it demonstrates:**
- Feedback sentiment aggregation
- Topic extraction from free text
- Combines ratings with qualitative comments

**Expected insights:** Communication/alerting is top frustration; expense system issues caused negative spike

---

### Prompt 3.3: Executive Impact Summary
> **"Summarize the impact of Monday's Workday incident in terms an executive would understand - associate hours lost, business processes affected, and remediation status."**

**What it demonstrates:**
- Executive-level synthesis
- Business impact translation
- Combines multiple data sources into narrative

---

## 🛠️ Category 4: Resolution & Remediation

### Prompt 4.1: Knowledge Retrieval
> **"An associate is getting timeout errors when submitting expense reports with attachments. What's the solution?"**

**What it demonstrates:**
- Cortex Search over knowledge base
- RAG for IT support
- Actionable resolution steps

**Expected insights:** Returns KB-2024-001 with batch submission workaround

---

### Prompt 4.2: Historical Resolution Search
> **"Have we seen issues like this before? What worked to fix them?"**

**What it demonstrates:**
- Semantic similarity search
- Historical ticket resolution mining
- Learning from past solutions

---

### Prompt 4.3: Proactive Guidance
> **"Based on current feedback and ticket patterns, what issues should we prioritize fixing before they get worse?"**

**What it demonstrates:**
- Predictive insights
- Trend analysis + sentiment correlation
- Proactive IT management

**Expected insights:** Communication/alerting, hardware refresh backlog, HEIC format issues

---

### Prompt 4.4: Self-Service Recommendation
> **"What knowledge base articles should we promote to reduce ticket volume? Which topics have the most tickets but also have good documentation?"**

**What it demonstrates:**
- KB effectiveness analysis
- Ticket deflection opportunities
- Data-driven content strategy

---

## 📈 Category 5: Trends & Analytics

### Prompt 5.1: Monthly Comparison
> **"Compare this month's IT support experience to last month. What's getting better? What's getting worse?"**

**What it demonstrates:**
- Period-over-period analysis
- Multi-metric comparison
- Trend identification

---

### Prompt 5.2: Application Performance Trends
> **"Show me the trend of response times and error rates for our top 5 applications over the past 30 days."**

**What it demonstrates:**
- Performance trending
- Multi-application comparison
- Structured metric analysis

---

### Prompt 5.3: Ticket Resolution Performance
> **"What's our average time to resolve tickets by priority level? Are we meeting our SLAs?"**

**What it demonstrates:**
- SLA metrics calculation
- Priority-based performance
- Operational KPIs

---

### Prompt 5.4: Feedback Topic Trends
> **"What themes are emerging in associate feedback that weren't present last month?"**

**What it demonstrates:**
- Temporal topic modeling
- Emerging issue detection
- Unstructured trend analysis

---

## 🏛️ Category 6: Regulatory & Compliance Reporting

### Prompt 6.1: Board-Level Summary
> **"Prepare a summary of significant IT incidents this quarter that should be reported to the board. Include any regulatory implications."**

**What it demonstrates:**
- Regulatory filtering
- Executive narrative synthesis
- Compliance-focused reporting

**Expected insights:** VPN certificate incident (INC-2024-0879) flagged as regulatory reportable

---

### Prompt 6.2: Compliance Status
> **"What's our current status on incidents with regulatory reporting requirements? Are any remediations overdue?"**

**What it demonstrates:**
- Compliance tracking
- Remediation status
- Risk management

---

### Prompt 6.3: Audit Trail
> **"What changes were made to production systems in the last 30 days? Were there any incidents within 48 hours of those changes?"**

**What it demonstrates:**
- Change audit trail
- Change-incident correlation
- Audit readiness

---

## 💡 Category 7: Complex Multi-Source Queries

### Prompt 7.1: Full Investigation Synthesis
> **"I'm investigating slow expense report submissions. Give me: 1) The timeline of events, 2) Related incidents and changes, 3) What associates are saying about it, 4) Relevant knowledge base articles, and 5) Recommended next steps."**

**What it demonstrates:**
- Multi-table synthesis
- Comprehensive investigation
- Actionable recommendations

**This is the "hero" demo prompt - shows full platform value**

---

### Prompt 7.2: Proactive Risk Assessment
> **"Based on current data, what are the top 3 risks to associate digital experience that we should address proactively?"**

**What it demonstrates:**
- Predictive analytics
- Risk prioritization
- Cross-source pattern recognition

---

### Prompt 7.3: Communication Gap Analysis
> **"Associates are complaining about lack of proactive communication during incidents. What evidence supports this, and what do they suggest?"**

**What it demonstrates:**
- Sentiment analysis
- Suggestion extraction
- Actionable improvement insights

**Expected insights:** Multiple feedback entries mention status page, proactive alerts, faster notification

---

### Prompt 7.4: Hardware Refresh Justification
> **"Build a business case for laptop hardware refreshes. What evidence do we have that aging hardware is impacting associate experience?"**

**What it demonstrates:**
- Evidence aggregation
- Business case construction
- ROI justification support

**Expected insights:** Teams crashes, overheating issues, delayed refresh requests all support the case

---

## 🚀 Bonus: Conversational Follow-ups

After any prompt, demonstrate natural follow-up questions:

1. **"Tell me more about that incident"**
2. **"Who was affected?"**
3. **"What's the workaround?"**
4. **"Show me the trend over time"**
5. **"Draft a communication for affected associates"**
6. **"What should we do to prevent this in the future?"**

---

## 📋 Demo Script Recommendation

For a 15-minute demo, use this sequence:

1. **Hook** (2 min): Prompt 1.2 - "Any unusual spikes?" → Shows immediate value
2. **Root Cause** (3 min): Prompt 2.1 - Workday investigation → Deep analysis
3. **Resolution** (2 min): Prompt 4.1 - Find solution → Actionable
4. **Sentiment** (2 min): Prompt 3.2 - Associate feedback → Human element
5. **Hero Query** (4 min): Prompt 7.1 - Full synthesis → Platform power
6. **Compliance** (2 min): Prompt 6.1 - Board summary → Executive relevance

---

## 📝 Notes for Demo

- Data reflects a realistic scenario: Workday security patch caused cascade of issues on January 15
- All data is interconnected - events link to tickets, incidents link to changes, feedback ties to applications
- Unstructured fields contain rich narrative that enables semantic search
- The "story" is about improving associate experience through data-driven insights

---

*Document prepared for Capital One Associate Experience Team - Snowflake Intelligence Demo*
