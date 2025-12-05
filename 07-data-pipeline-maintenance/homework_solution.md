# Data Pipeline Maintenance Plan
**Team:** 4 Data Engineers | **Company:** SaaS Platform

---

## Pipeline Ownership

| Pipeline | Primary Owner | Secondary Owner |
|----------|---------------|-----------------|
| Aggregate Profit (investors) | DE1 | DE2 |
| Unit-level Profit (experiments) | DE2 | DE1 |
| Aggregate Growth (investors) | DE3 | DE4 |
| Daily Growth (experiments) | DE4 | DE3 |
| Aggregate Engagement (investors) | DE1 | DE3 |

We paired related pipelines together (like aggregate + unit-level profit) so the same people maintain both. This way if something breaks in one, they already understand the data flow. We also made sure each engineer owns at least one critical investor pipeline so nobody gets stuck with only low-priority stuff.

---

## On-Call Schedule

### Basic Rotation
Weekly rotation: DE1 → DE2 → DE3 → DE4 (repeat)

### Holidays
- If you're on-call during a major holiday (Christmas, New Year's, Thanksgiving, etc.), you get either a comp day or 1.5x pay
- You can swap weeks with someone else - just give the team a week's notice
- During holidays, the secondary owner is on backup in case things go really sideways
- **Exception:** Last week of the month, everyone's on deck because investor reports are due

### When Things Go Wrong
1. On-call engineer tries to fix it (30 min response time)
2. If still broken after 2 hours, secondary owner jumps in
3. After 4 hours, escalate to team lead
4. If it's a cross-team issue, loop in Finance/Accounts/Engineering teams

---

## Runbooks

## Profit Pipeline

**Owners:** DE1 (primary), DE2 (secondary)  
**What it does:** Calculates how much money we're making for investor reports

### Data Sources
- Billing system for revenue
- HR system for salaries
- AWS/Azure/GCP for infrastructure costs
- Operations team for other expenses

### Common Issues

**Numbers don't match accounting**
- Happens when: Our profit numbers are different from what Finance says
- Why: Timing issues (we count things on different days), missing expense categories, currency conversion problems

**Missing subscription data**
- Happens when: We're missing revenue or subscriber counts
- Why: Billing API goes down, payment processing delays, database isn't syncing

**Expenses in the wrong month**
- Happens when: Costs show up in the wrong time period
- Why: Operations team submits expenses late, cloud billing has a delay, someone fat-fingered a manual entry

**Math errors**
- Happens when: You see NULL, division by zero, or negative profit when it should be positive
- Why: Bad NULL handling, joins creating duplicate rows, wrong data types

**Old data**
- Happens when: Dashboard shows last week's numbers when it should be today's
- Why: Upstream data is delayed, job scheduler failed, not enough compute resources

### SLAs
- Data freshness: 24 hours
- Month-end close is sacred - cannot miss this
- Fix issues within 3 business days

### On-Call Notes
- Weekly rotation + heightened monitoring last week of month
- DE1 and DE2 on high alert for month-end close

---

## Growth Pipeline

**Owners:** DE3 (primary), DE4 (secondary)  
**What it does:** Tracks new customers, upgrades, downgrades, and churn

### Data Sources
- Salesforce (our CRM)
- Account database
- Subscription management system
- Sales team records

### Common Issues

**Accounts skip steps**
- Happens when: An account goes from "A" to "C" but never showed as "B" in between
- Why: Account executives forget to update Salesforce, manual entry mistakes, automation broke

**Updates are late**
- Happens when: This week's account changes aren't in the system yet
- Why: AE team is swamped, manual updates take forever, sync failed

**Duplicate accounts**
- Happens when: Same company counted twice
- Why: Data quality issues in CRM, company got acquired and we didn't merge records, slightly different company names

**Growth and revenue don't line up**
- Happens when: We show 10 new accounts but revenue only went up a little
- Why: Contract start date vs when payment actually came through, pro-rating calculations

**Wrong churn classification**
- Happens when: Account marked as cancelled but they're still using the product
- Why: Payment failed (not intentional churn), grace periods, delayed processing

### SLAs
- All account statuses updated by end of week
- Fix issues during business hours within 2 days
- Month-end close cannot be missed

### On-Call
- No emergency on-call - we fix things during business hours. 
- But during month-end, both DE3 and DE4 are actively watching.

---

## Engagement Pipeline

**Owners:** DE1 (primary), DE3 (secondary)  
**What it does:** Measures how much customers actually use our product

### Data Sources
- Frontend events streaming through Kafka
- Web analytics
- Mobile app analytics
- Backend API logs

### Common Issues

**Data shows up late**
- Happens when: Events from yesterday (or earlier) suddenly appear
- Why: Network issues, mobile users went offline and synced later, retry logic

**Kafka goes down**
- Happens when: Event stream drops to zero
- Why: Kafka broker crashed, producer can't connect, network problems

**Duplicate events**
- Happens when: Same user click gets recorded 3 times
- Why: Client retry logic gone wrong, network glitch, no deduplication

**Spark jobs crash with OOM**
- Happens when: Aggregation job fails with out of memory error
- Why: Joining millions of accounts with revenue and engagement data, one account has way more data than others (data skew)

**Missing data from other pipelines**
- Happens when: NULL values everywhere, divide by zero errors
- Why: Profit or Growth pipeline didn't finish yet, backfill still running

**Schema changes break everything**
- Happens when: Can't parse events, missing fields
- Why: Frontend team deployed new event format without telling us

### SLAs
- Data should arrive within 48 hours
- Fix issues within 1 week
- Month-end close cannot be missed

### On-Call
- Weekly rotation. Do a 30-minute handoff meeting when switching. 
- Have a contact on the Frontend team for questions. 
- Everyone's watching closely last week of the month.

---

## Pipeline Dependencies

**Dependency Chain:**
```
Profit Pipeline ─┐
Growth Pipeline ─┼─→ Aggregate Investor Pipeline
Engagement Pipeline ─┘
```

**Key Considerations:**
- Upstream pipelines must complete before downstream aggregation
- Establish backfill procedures for late data
- Implement cross-pipeline validation checks
- Alert when upstream SLAs at risk

---

## Monitoring Setup

### Automatic Alerts
- Data older than 18 hours (warning) or 24 hours (critical)
- Row count anomalies (>20% variance)
- NULL values in critical columns
- Pipeline job failures
- SLA about to be missed (24 hours before deadline)

### Manual Checks
- Weekly: Look at metrics, make sure nothing looks weird
- Monthly: Meet with Finance/Accounts/Product teams to reconcile
- Month-end: Everyone verifies investor reports look right