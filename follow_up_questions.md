# Follow-up Questions

The investigation answered the CEO's question. These are the questions I'd want to answer next.

---

**1. Which specific actions did mobile users stop doing?**

The device analysis shows mobile users dropped off but doesn't show *what* they stopped doing. The `yammer_events` table has an `event_name` column - login, like_message, send_message, search_run, view_inbox that I never broke down by device.

Did mobile users stop logging in entirely? Or did they log in but stop posting? That distinction matters. If they stopped logging in, the entry point is broken - probably the email deep link. If they logged in but stopped posting, the publisher feature itself is broken.

```sql
SELECT
    event_name,
    COUNT(DISTINCT user_id) AS users_before,
FROM tutorial.yammer_events
WHERE occurred_at BETWEEN '2014-07-01' AND '2014-07-28'
    AND device IN (
        'iphone 5', 'iphone 5s', 'iphone 4s',
        'samsung galaxy s4', 'nexus 5', 'htc one',
        'ipad air', 'ipad mini', 'nexus 7', 'nexus 10'
    )
GROUP BY event_name
ORDER BY users_before DESC
```

Run this for before July 28 and after the event_name that drops hardest is the broken feature.

---

**2. Was the drop concentrated in specific countries?**

The `yammer_events` table has a `location` column I never touched. If the publisher_update rolled out region by region - US first, then Europe, then Asia — the WAU drop would show up in those regions in sequence rather than all at once globally.

A geographic breakdown of the drop would either confirm a global rollout (drop hits everywhere simultaneously) or a phased one (drop hits one region first, then spreads). That would help pinpoint the exact rollout date more precisely than the data currently allows.

---

**3. Did WAU recover after the fix?**

The data ends August 25. The analysis identifies the problem but doesn't show what happened next. Did Yammer roll back publisher_update? Did WAU recover in September? Did existing users come back or did Yammer lose them permanently?

A 90-day recovery analysis would be the natural follow-up and would show whether the re-engagement campaign recommendation from the README actually worked.

---

**4. Were certain companies hit harder than others?**

The `yammer_users` table has a `company_id` column. Yammer sells to enterprise companies if one large company had 500 users and they all went inactive, that alone could explain a significant chunk of the WAU drop. It might not be a product problem at all — it could be a single churned account.

Checking whether the drop is distributed evenly across company IDs or concentrated in a few large accounts would either confirm the product explanation or open a completely different investigation.

---

## If I had access to more data

**Engineering deployment log** — the single most valuable piece of missing information. Cross-referencing the July 28 date with the actual deployment record would confirm or refute the root cause hypothesis in five minutes.

**Server error rates** — if the mobile app was throwing errors after July 28, that would show up in server logs as a spike in 4xx or 5xx responses on mobile endpoints. That's direct evidence of a broken experience, not inferred evidence.

**User support tickets** — a spike in support tickets the week of July 28 complaining about mobile issues would be the smoking gun that turns a hypothesis into a confirmed finding.

**A/B test metadata** — the experiments table shows what happened during the test but not what the publisher_update feature actually changed. Was it the post composer? The feed algorithm? The notification system? Knowing what the feature did would make the mechanism of the drop much clearer.
