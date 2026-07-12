/* ================================================
   FILE: 02_device_analysis.sql
   PROJECT: Yammer WAU Drop Investigation
   ANALYST: Rohith Reddy Thumma

   BUSINESS QUESTION:
   Is the WAU drop coming from a specific device type?
   Are we losing desktop users, mobile users, or both?

   KEY FINDING:
   The drop is concentrated in mobile devices:
   - Phone users dropped 25% (589 → 441)
   - Tablet users dropped 38% (232 → 143)
   - Computer users only dropped 9% (965 → 879)

   CONCLUSION:
   This is a mobile experience problem — not a product-wide
   issue. Something changed in the Yammer mobile app around
   the week of July 28, 2014. Investigation should focus on:
   1. Any mobile app updates released that week
   2. iOS or Android OS updates that may have broken compatibility
   3. Changes to mobile push notifications
   ================================================ */

SELECT
    DATE_TRUNC('week', occurred_at) AS week_of,
    CASE
        WHEN device IN (
            'macbook pro', 'macbook air', 'lenovo thinkpad',
            'dell inspiron notebook', 'asus chromebook',
            'acer aspire notebook', 'windows surface',
            'dell inspiron desktop', 'hp pavilion desktop',
            'acer aspire desktop', 'mac mini'
        ) THEN 'computer'
        WHEN device IN (
            'iphone 5', 'iphone 5s', 'iphone 4s',
            'samsung galaxy s4', 'nexus 5',
            'nokia lumia 635', 'htc one',
            'samsung galaxy note', 'amazon fire phone'
        ) THEN 'phone'
        WHEN device IN (
            'ipad air', 'ipad mini', 'nexus 7',
            'nexus 10', 'kindle fire',
            'samsumg galaxy tablet'
        ) THEN 'tablet'
        ELSE 'unknown'
    END AS device_type,
    COUNT(DISTINCT user_id) AS weekly_active_users
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY week_of, device_type
ORDER BY week_of, device_type


/* ================================================
   RESULTS (run on Mode Analytics):

   week_of     | device_type | weekly_active_users
   ------------|-------------|--------------------
   2014-07-28  | computer    | 965   <-- PEAK
   2014-07-28  | phone       | 589   <-- PEAK
   2014-07-28  | tablet      | 232   <-- PEAK
   ------------|-------------|--------------------
   2014-08-04  | computer    | 921   (-4%)
   2014-08-04  | phone       | 491   (-17%)
   2014-08-04  | tablet      | 155   (-33%)
   ------------|-------------|--------------------
   2014-08-25  | computer    | 879   (-9% from peak)
   2014-08-25  | phone       | 441   (-25% from peak)
   2014-08-25  | tablet      | 143   (-38% from peak)
   ================================================ */
