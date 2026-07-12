/* ================================================
   FILE: 05_final_summary.sql
   PROJECT: Yammer WAU Drop Investigation
   ANALYST: Rohith Reddy Thumma

   THE CEO'S QUESTION:
   "Our Weekly Active Users dropped last month.
   I need to know why, which users we're losing,
   and what we should do about it."

   ════════════════════════════════════════════
   THE COMPLETE ANSWER
   ════════════════════════════════════════════

   WHAT HAPPENED:
   WAU peaked at 1,443 on July 28 and dropped 17%
   to 1,194 by August 25 — a loss of 249 weekly
   active users in 4 weeks.

   WHO WE ARE LOSING:
   - Existing users (activated before June 2014): -38%
   - Mobile users specifically: phones -25%, tablets -38%
   - New users are completely unaffected (+4% growth)

   WHY IT HAPPENED:
   The email → mobile app re-engagement loop broke.
   - Yammer sent MORE emails than ever (+11%)
   - Users OPENED those emails (+10%)
   - But clickthroughs COLLAPSED 32%
   - When existing users clicked email links on mobile
     they hit a broken experience and stopped returning

   ROOT CAUSE (HYPOTHESIS):
   A mobile app update shipped around July 28 broke
   the experience for existing users accessing via
   email deep links. New users who found Yammer via
   other channels on desktop were unaffected.

   ════════════════════════════════════════════
   RECOMMENDATIONS
   ════════════════════════════════════════════

   IMMEDIATE (this week):
   1. Audit mobile deep links in weekly digest emails
      on both iOS and Android
   2. Check the mobile app release log for the week
      of July 28 — identify what changed
   3. Reproduce the broken flow: open a weekly digest
      email on mobile and follow the links

   SHORT TERM (this month):
   4. Fix the broken mobile email → app flow
   5. Send a re-engagement campaign to existing users
      who went inactive after July 28
   6. A/B test a simplified email template with fewer
      but higher-quality clickthrough links

   LONGER TERM:
   7. Build an email clickthrough rate (CTR) alert —
      if weekly digest CTR drops >10% week-over-week,
      trigger an automatic investigation
   8. Separate mobile vs desktop email click tracking
      to catch device-specific issues faster

   ════════════════════════════════════════════
   EVIDENCE SUMMARY
   ════════════════════════════════════════════

   File                        | Key Metric        | Finding
   ----------------------------|-------------------|------------------
   01_weekly_active_users      | Overall WAU       | -17% from peak
   02_device_analysis          | Mobile WAU        | -25% to -38%
   03_new_vs_existing_users    | Existing user WAU | -38%
   04_email_analysis           | Email clickthrough| -32%

   ================================================ */


-- ================================================
-- MASTER SUMMARY QUERY
-- All 4 dimensions in one view
-- ================================================

-- 1. Overall WAU trend
SELECT
    'overall_wau'                            AS metric,
    DATE_TRUNC('week', occurred_at)          AS week_of,
    COUNT(DISTINCT user_id)                  AS value
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY DATE_TRUNC('week', occurred_at)

UNION ALL

-- 2. Email clickthrough trend
SELECT
    'email_clickthrough'                     AS metric,
    DATE_TRUNC('week', occurred_at)          AS week_of,
    COUNT(DISTINCT user_id)                  AS value
FROM tutorial.yammer_emails
WHERE action = 'email_clickthrough'
GROUP BY DATE_TRUNC('week', occurred_at)

ORDER BY week_of, metric
