# Limitations

Every analysis has gaps. These are mine.

---

## 1. The root cause is a hypothesis, not a confirmed fact

Everything in this investigation points to the `publisher_update` feature rollout as the cause of the WAU drop. The timing lines up. The A/B test data shows the test group had significantly worse engagement. The drop is concentrated in existing mobile users — exactly the audience that would have been affected by a feature change.

But I don't have the engineering deployment log. I can't confirm the exact date `publisher_update` shipped to 100% of users. July 28 is inferred from the data, not verified from a release record. A proper post-mortem would cross-reference this analysis with the actual deployment timeline before calling it confirmed.

---

## 2. The experiment sample was small

The `publisher_update` experiment ran for about 6 weeks on a subset of users. By the end of June, the control group had 52 users and the test group had 23. Those are small numbers. A 72% gap between test and control sounds dramatic — and the trend is clear across multiple weeks — but with sample sizes that small you can't rule out noise entirely.

In a real setting I'd run a statistical significance test before presenting this as evidence. With n=23 in the test group the confidence interval is wide. The direction is right but the magnitude should be treated with some caution.

---

## 3. Seasonality wasn't controlled for

The WAU drop happens in August. August is when a lot of people go on vacation — particularly in Europe and the US. Some portion of the drop could be seasonal rather than product-driven.

The analysis doesn't separate seasonal effects from the feature rollout effect. Ideally you'd compare August 2014 against August 2013 to see whether a summer dip is normal for Yammer. That data may exist but wasn't part of this investigation.

---

## 4. Correlation between email clickthroughs and mobile experience

The email analysis shows clickthroughs dropped 32% while opens stayed flat. The interpretation — that users clicked and hit a broken mobile experience — is logical but not directly proven. An alternative explanation is that the email content changed around July 28 and became less compelling, causing users to opt out of clicking without ever landing on the app.

Distinguishing between "broken landing experience" and "less compelling email content" would require click-to-session data — did users who clicked actually open the app, or did the link fail silently?

---

## What would strengthen this analysis

- Engineering deployment log for the week of July 28
- Server-side error rates by device and endpoint for that week
- Click-to-session tracking on email links
- August 2013 WAU data for seasonal comparison
- Statistical significance testing on the experiment results
- User support ticket volume filed week of July 28
