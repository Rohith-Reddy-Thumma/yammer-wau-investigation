# Yammer WAU Drop Investigation

> **A complete product analytics investigation into a 17% Weekly Active User drop at Yammer — using SQL on real data. The same case study used in interviews at Airbnb, Stripe, and Lyft.**

---

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Mode](https://img.shields.io/badge/Tool-Mode%20Analytics-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat)
![Queries](https://img.shields.io/badge/SQL%20Files-5-blueviolet?style=flat)

---

## The Brief

> *"Our Weekly Active Users dropped last month. I need to know why, which users we're losing, and what we should do about it."*

That's the CEO's question. This repository is the complete answer — five SQL queries, four findings, and a concrete recommendation built on real Yammer data from 2014.

---

## The Dataset

**Source:** Mode Analytics public Yammer dataset
**Tables used:**
| Table | Description | Rows |
|-------|-------------|------|
| `tutorial.yammer_events` | Every user action (login, like, message, search) | ~90,000 |
| `tutorial.yammer_users` | Every user account with signup and activation dates | ~19,000 |
| `tutorial.yammer_emails` | Every email sent, opened, and clicked | ~40,000 |

---

## The Investigation

### Finding 1 — When did the drop start?
**File:** `queries/01_weekly_active_users.sql`

WAU peaked at **1,443** on July 28, 2014 and dropped **17%** to 1,194 by August 25 — a loss of 249 weekly active users in just 4 weeks. The drop was sharp and sudden, not gradual — pointing to a specific event rather than natural churn.

```
Week of Jul 28  →  1,443  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  PEAK
Week of Aug 04  →  1,266  ▓▓▓▓▓▓▓▓▓▓▓▓▓    -12%
Week of Aug 11  →  1,215  ▓▓▓▓▓▓▓▓▓▓▓▓     -16%
Week of Aug 18  →  1,203  ▓▓▓▓▓▓▓▓▓▓▓▓     -17%
Week of Aug 25  →  1,194  ▓▓▓▓▓▓▓▓▓▓▓▓     -17%
```

---

### Finding 2 — Which device type?
**File:** `queries/02_device_analysis.sql`

The drop was concentrated entirely in **mobile devices.** Desktop users were barely affected.

| Device | Peak WAU | Aug 25 WAU | Change |
|--------|---------|------------|--------|
| Computer | 965 | 879 | **-9%** |
| Phone | 589 | 441 | **-25%** ⚠️ |
| Tablet | 232 | 143 | **-38%** 🚨 |

**Conclusion:** This is a mobile problem, not a product-wide problem.

---

### Finding 3 — New users or existing users?
**File:** `queries/03_new_vs_existing_users.sql`

The most revealing finding. New users were completely unaffected — in fact they grew.

| User Type | Peak WAU (Jul 28) | Aug 25 WAU | Change |
|-----------|-------------------|------------|--------|
| Existing users | 723 | 446 | **-38%** 🚨 |
| New users | 720 | 748 | **+4%** ✅ |

**Conclusion:** Something broke specifically for existing users. This rules out bad marketing, bad press, and poor onboarding as causes.

---

### Finding 4 — Email engagement
**File:** `queries/04_email_analysis.sql`

Yammer sent more emails than ever after July 28. Users opened them. But they stopped clicking through.

| Metric | Jul 28 | Aug 25 | Change |
|--------|--------|--------|--------|
| Emails sent | 3,706 | 4,111 | **+11%** ↑ |
| Emails opened | 1,372 | 1,511 | **+10%** ↑ |
| Clicked through | 629 | 485 | **-23%** 🚨 |

**Conclusion:** The email → mobile app re-engagement loop broke. Users received and opened emails but the clickthrough experience (likely on mobile) was broken.

---

## The Root Cause

Combining all four findings:

> **A mobile app update shipped around July 28 broke the experience for existing users accessing Yammer via email deep links. When existing users clicked through their weekly digest emails on mobile, they hit a broken experience and stopped returning. New users who discovered Yammer through other channels on desktop were completely unaffected.**

---

## Recommendations

### Immediate (this week)
1. **Audit mobile deep links** in weekly digest emails on iOS and Android
2. **Check the mobile app release log** for the week of July 28
3. **Reproduce the broken flow** — open a weekly digest on mobile and follow the links

### Short term (this month)
4. **Fix the broken mobile email → app flow**
5. **Re-engagement campaign** for existing users who went inactive after July 28
6. **A/B test** a simplified email template with fewer, higher-quality links

### Longer term
7. **Build a CTR alert** — if weekly digest clickthrough drops >10% week-over-week, trigger automatic investigation
8. **Separate mobile vs desktop tracking** in email analytics to catch device-specific issues faster

---

## File Structure

```
yammer-wau-investigation/
├── README.md
└── queries/
    ├── 01_weekly_active_users.sql    ← When did WAU drop?
    ├── 02_device_analysis.sql        ← Which device type?
    ├── 03_new_vs_existing_users.sql  ← Who are we losing?
    ├── 04_email_analysis.sql         ← Email engagement breakdown
    └── 05_final_summary.sql          ← Master summary + recommendations
```

---

## Key SQL Concepts Used

| Concept | Where used |
|---------|-----------|
| `DATE_TRUNC` | Group events by week |
| `COUNT(DISTINCT)` | Count unique users not total events |
| `CASE WHEN` | Bucket devices into categories |
| `LEFT JOIN` | Combine events + users tables |
| `GROUP BY` | Aggregate by week and segment |
| `UNION ALL` | Combine multiple metrics in one query |

---

## How to Reproduce

1. Create a free account at [mode.com](https://mode.com)
2. Open a new SQL query and connect to the **Mode Analytics Training Database**
3. Copy any query from the `queries/` folder
4. Run it — all tables are prefixed with `tutorial.`

---

## About

Built by **Rohith Reddy Thumma** — Product Analyst, MS Business Analytics @ NAU (GPA 4.0, Distinction, May 2026).

- 🌐 Portfolio: [veritas-ui-eight.vercel.app](https://veritas-ui-eight.vercel.app)
- 💼 LinkedIn: [linkedin.com/in/rohithreddythumma](https://linkedin.com/in/rohithreddythumma)
- 📧 rohiththumma2001@gmail.com

---

*Part of a broader product analytics portfolio that includes a production Power BI retention dashboard (20,941 students), a 1st-place transit analytics capstone (Mountain Line), and a deployed AI chatbot (Veritas).*
