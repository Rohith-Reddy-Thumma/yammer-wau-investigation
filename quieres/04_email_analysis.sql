/* ================================================
   FILE: 04_email_analysis.sql
   PROJECT: Yammer WAU Drop Investigation
   ANALYST: Rohith Reddy Thumma

   BUSINESS QUESTION:
   Did changes to email notifications contribute
   to the drop in existing user engagement?

   KEY FINDING:
   Emails sent INCREASED after July 28.
   Email opens stayed flat or grew slightly.
   But email clickthroughs COLLAPSED 32%.

   sent_weekly_digest:    3,706 → 4,111  (+11%)  ↑ growing
   email_open:            1,372 → 1,511  (+10%)  ↑ growing
   email_clickthrough:      629 →   485  (-23%)  ↓ collapsed

   CONCLUSION:
   Users received and opened their weekly digest emails
   but stopped clicking through to the app. Combined with
   the mobile device finding, this strongly suggests the
   email → mobile app re-engagement loop broke around
   July 28. Links may have led to a broken mobile
   experience, causing users to stop clicking over time.

   RECOMMENDATION:
   1. Audit mobile deep links in weekly digest emails
   2. Test the email → mobile app flow on iOS and Android
   3. Check if a mobile app update shipped week of Jul 28
      that broke the landing experience for email traffic
   ================================================ */

SELECT
    DATE_TRUNC('week', occurred_at) AS week_of,
    action,
    COUNT(DISTINCT user_id)          AS num_users
FROM tutorial.yammer_emails
GROUP BY
    DATE_TRUNC('week', occurred_at),
    action
ORDER BY
    week_of,
    action


/* ================================================
   RESULTS (run on Mode Analytics):

   week_of     | action                  | num_users
   ------------|-------------------------|----------
   2014-07-28  | sent_weekly_digest      | 3706   <-- PEAK
   2014-07-28  | email_open              | 1372
   2014-07-28  | email_clickthrough      | 629    <-- THEN DROPS
   2014-07-28  | sent_reengagement_email | 230
   ------------|-------------------------|----------
   2014-08-04  | sent_weekly_digest      | 3793   (+2%)
   2014-08-04  | email_open              | 1328   (-3%)
   2014-08-04  | email_clickthrough      | 431    (-32%)  <-- CLIFF
   2014-08-04  | sent_reengagement_email | 206
   ------------|-------------------------|----------
   2014-08-25  | sent_weekly_digest      | 4111   (+11% from peak)
   2014-08-25  | email_open              | 1511   (+10% from peak)
   2014-08-25  | email_clickthrough      | 485    (-23% from peak)
   2014-08-25  | sent_reengagement_email | 263
   ================================================ */
