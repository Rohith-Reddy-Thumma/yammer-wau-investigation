# Analyst Notes — What I Learned Running This Investigation

These are my honest notes from working through this investigation. Not a summary of findings — that's in the README. This is the stuff that doesn't make it into a clean write-up.

---

## What slowed me down

The JOIN query in `03_new_vs_existing_users.sql` was the most time-consuming step by far. Joining `yammer_events` (~90,000 rows) against `yammer_users` (~19,000 rows) without a date filter just sat there. First attempt timed out entirely.

The fix was obvious in hindsight — filter the events table down to the relevant date range *before* the join, not after:

```sql
-- slow version: joins everything then filters
WHERE e.event_type = 'engagement'

-- fast version: limits the scan before joining
WHERE e.event_type = 'engagement'
    AND e.occurred_at >= '2014-04-01'
    AND e.occurred_at < '2014-09-01'
```

Adding those two date filters cut the query time significantly. The lesson: push filters as early as possible in the query. Don't let the database join a million rows only to throw most of them away at the end.

---

## The device bucketing — I'd do this differently

`02_device_analysis.sql` has a CASE WHEN block that lists every single device by name. It works, but it's brittle — if a new device appears in the data that isn't in the list, it silently gets dropped into NULL rather than being counted. And it's long. Reading that query is painful.

A cleaner approach would be pattern matching:

```sql
CASE
    WHEN LOWER(device) LIKE '%iphone%'
      OR LOWER(device) LIKE '%samsung%'
      OR LOWER(device) LIKE '%nexus%'
      OR LOWER(device) LIKE '%htc%'
      OR LOWER(device) LIKE '%nokia%'    THEN 'phone'
    WHEN LOWER(device) LIKE '%ipad%'
      OR LOWER(device) LIKE '%kindle%'
      OR LOWER(device) LIKE '%tablet%'   THEN 'tablet'
    WHEN LOWER(device) LIKE '%book%'
      OR LOWER(device) LIKE '%desktop%'
      OR LOWER(device) LIKE '%chromebook%'
      OR LOWER(device) LIKE '%surface%'  THEN 'computer'
    ELSE 'other'
END
```

Or better — a separate device lookup table that maps device names to categories. Then the CASE WHEN disappears entirely and you just do a join. That approach scales. The CASE WHEN approach doesn't.

The current version in the repo is explicit and readable for anyone reviewing the code. But in a production environment I'd push for the lookup table.

---

## The moment the investigation clicked

Query 3 was the turning point.

I went into this expecting to find a new user acquisition problem — that's usually what drives WAU drops at SaaS companies. Fewer people signing up means fewer active users downstream. It's the most common answer.

When the results came back showing existing users at 446 and new users at 748 by August 25 — with new users still growing — I had to stop and reread it. That's not a typical pattern. Something was actively breaking the experience for people who already knew and used the product, while simultaneously not affecting anyone who was just discovering it.

That narrowed the suspect list immediately. Broken onboarding — ruled out. Bad marketing — ruled out. Bad press — ruled out. Whatever this was, it only hit people with established usage habits. That's when I started thinking about the email re-engagement loop and eventually the A/B test.

---

## What I'd do next if I had more time

**1. Break down mobile event types after July 28**

The device analysis shows mobile users dropped off — but it doesn't show *what* they stopped doing. Did they stop logging in entirely? Stop posting? Stop clicking search? A breakdown by `event_name` filtered to mobile devices after July 28 would tell you exactly which feature broke. That's the query I'd run next.

```sql
SELECT
    event_name,
    COUNT(DISTINCT user_id) AS users
FROM tutorial.yammer_events
WHERE device IN ('iphone 5', 'iphone 5s', ...)
    AND occurred_at >= '2014-07-28'
GROUP BY event_name
ORDER BY users DESC
```

**2. Geographic breakdown**

The events table has a `location` column I never touched. Did the publisher_update roll out to certain regions first? If the WAU drop is concentrated in one country, that points to a regional rollout rather than a global one.

**3. Confirm the rollout date precisely**

Everything in this investigation points to July 28 as the date the publisher_update shipped to all users. But that's inferred from the data — the WAU drop starts that week, the experiment ended around that time. To confirm it I'd need the engineering deployment log. Without that, the root cause is a well-supported hypothesis, not a confirmed fact.

---

## What this investigation taught me

Product analytics isn't about finding the answer. It's about eliminating the wrong answers fast enough that you're left with something defensible.

Every query here was designed to rule something out:
- Query 1 ruled out "it's been declining for months"
- Query 2 ruled out "it's a desktop problem"
- Query 3 ruled out "it's an acquisition problem"
- Query 4 ruled out "email engagement is broken across the board"
- Query 5 pointed at the specific cause

By the time you get to query 5 you're not guessing anymore. You're confirming.

That's the mental model I'd bring to any investigation — start broad, eliminate fast, go deep on whatever survives.
