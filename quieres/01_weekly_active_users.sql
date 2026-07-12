/* ================================================
   FILE: 01_weekly_active_users.sql
   PROJECT: Yammer WAU Drop Investigation
   ANALYST: Rohith Reddy Thumma
   
   BUSINESS QUESTION:
   "Our Weekly Active Users dropped last month.
   When exactly did the drop start and how severe is it?"
   
   KEY FINDING:
   WAU peaked at 1,443 on July 28, 2014 and dropped
   17% to 1,194 by August 25 — a loss of 249 weekly
   active users in just 4 weeks.
   
   INTERPRETATION:
   The drop is not gradual — it starts sharply the week
   of August 4th and continues declining every week after.
   This suggests a specific event (bug, feature change,
   or external factor) rather than natural churn.
   
   NEXT STEPS:
   Investigate whether the drop is coming from:
   1. A specific device or platform
   2. A specific user segment
   3. A drop in new user signups
   ================================================ */

-- WAU trend across all users
-- One row per week showing unique active users

SELECT
    DATE_TRUNC('week', occurred_at) AS week_of,
    COUNT(DISTINCT user_id)          AS weekly_active_users
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY week_of
ORDER BY week_of


/* ================================================
   RESULTS (run on Mode Analytics, July 2024):
   
   week_of     | weekly_active_users
   ------------|--------------------
   2014-04-28  | 701
   2014-05-05  | 1054
   2014-05-12  | 1094
   2014-05-19  | 1147
   2014-05-26  | 1113
   2014-06-02  | 1173
   2014-06-09  | 1219
   2014-06-16  | 1263
   2014-06-23  | 1249
   2014-06-30  | 1271
   2014-07-07  | 1355
   2014-07-14  | 1345
   2014-07-21  | 1363
   2014-07-28  | 1443   <-- PEAK
   2014-08-04  | 1266   <-- DROP STARTS (-177)
   2014-08-11  | 1215
   2014-08-18  | 1203
   2014-08-25  | 1194   <-- 17% below peak
   ================================================ */
