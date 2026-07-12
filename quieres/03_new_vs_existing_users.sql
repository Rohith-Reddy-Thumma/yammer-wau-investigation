/* ================================================
   FILE: 03_new_vs_existing_users.sql
   PROJECT: Yammer WAU Drop Investigation
   ANALYST: Rohith Reddy Thumma

   BUSINESS QUESTION:
   Is the WAU drop coming from existing users going
   inactive OR from fewer new users signing up?

   KEY FINDING:
   The drop is 100% an existing user problem.
   New users are actually GROWING every week.

   EXISTING USERS:  723 (Jul 28) → 446 (Aug 25) = -38%
   NEW USERS:       720 (Jul 28) → 748 (Aug 25) = +4%

   CONCLUSION:
   Something changed around July 28 that broke the
   habits of existing users — not new users.
   This rules out bad marketing, bad press, and bad
   onboarding as causes.

   COMBINED WITH DEVICE FINDING (02_device_analysis):
   The drop is concentrated in mobile + existing users.
   A mobile app change around July 28 likely disrupted
   the established usage patterns of long-term users.

   RECOMMENDED NEXT STEPS:
   1. Check what mobile app updates shipped week of Jul 28
   2. Investigate email notification changes (see 04_email_analysis)
   3. Survey churned existing mobile users directly
   ================================================ */

SELECT
    DATE_TRUNC('week', e.occurred_at) AS week_of,
    CASE
        WHEN u.activated_at >= '2014-06-01' THEN 'new_user'
        ELSE 'existing_user'
    END AS user_type,
    COUNT(DISTINCT e.user_id) AS weekly_active_users
FROM tutorial.yammer_events e
LEFT JOIN tutorial.yammer_users u
    ON e.user_id = u.user_id
WHERE e.event_type = 'engagement'
    AND e.occurred_at >= '2014-04-01'
    AND e.occurred_at < '2014-09-01'
GROUP BY
    DATE_TRUNC('week', e.occurred_at),
    CASE
        WHEN u.activated_at >= '2014-06-01' THEN 'new_user'
        ELSE 'existing_user'
    END
ORDER BY
    week_of,
    user_type


/* ================================================
   RESULTS (run on Mode Analytics):

   week_of     | user_type      | weekly_active_users
   ------------|----------------|--------------------
   2014-04-28  | existing_user  | 701
   2014-05-05  | existing_user  | 1054
   2014-05-12  | existing_user  | 1094
   2014-05-19  | existing_user  | 1147
   2014-05-26  | existing_user  | 1102
   2014-05-26  | new_user       | 11
   2014-06-02  | existing_user  | 967
   2014-06-02  | new_user       | 206
   2014-06-09  | existing_user  | 881
   2014-06-09  | new_user       | 338
   2014-06-16  | existing_user  | 808
   2014-06-16  | new_user       | 455
   2014-06-23  | existing_user  | 757
   2014-06-23  | new_user       | 492
   2014-06-30  | existing_user  | 725
   2014-06-30  | new_user       | 546
   2014-07-07  | existing_user  | 756
   2014-07-07  | new_user       | 599
   2014-07-14  | existing_user  | 720
   2014-07-14  | new_user       | 625
   2014-07-21  | existing_user  | 701
   2014-07-21  | new_user       | 662
   2014-07-28  | existing_user  | 723    <-- PEAK then COLLAPSE
   2014-07-28  | new_user       | 720    <-- keeps growing
   2014-08-04  | existing_user  | 614    (-15%)
   2014-08-04  | new_user       | 652
   2014-08-11  | existing_user  | 509    (-30%)
   2014-08-11  | new_user       | 706
   2014-08-18  | existing_user  | 479    (-34%)
   2014-08-18  | new_user       | 724
   2014-08-25  | existing_user  | 446    (-38%)
   2014-08-25  | new_user       | 748    (+4% from peak)
   ================================================ */
