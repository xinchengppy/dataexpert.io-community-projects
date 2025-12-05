# REDDIT'S KPI AND EXPERIMENTATION

## User Journey

I first discovered Reddit through a Google search when I was looking for specific information that led me to a subreddit. What really made me create an account was the ability to customize my avatar - the Snoo characters were fun and let me express myself. Early on, I was hooked by finding niche communities that matched my specific interests. The comment threads were gold - people actually had real discussions instead of just posting. I started following specific subreddits that really spoke to me.

Over time, my usage evolved significantly. I joined more communities across different areas of my life - music subreddits for discovering new artists, data-related communities for my professional development, and news subreddits to stay informed. I even started playing the little games that some communities offer, which was a fun surprise. However, I rarely comment myself - I'm more of a lurker who absorbs all the great content.

My favorite features now are the consistently high-quality and honest answers from users. When I ask a question or search for information, Redditors give genuine, detailed responses without the BS you find on other platforms. The saved posts feature is also crucial for me - I bookmark helpful answers and guides to reference later. The awards system is another touchpoint I value because it helps me quickly identify which comments are truly valuable when scrolling through long threads. Reddit has become my go-to platform for authentic information, niche interests, and discovering content I wouldn't find anywhere else.

One pain point I have is the UI layout feels a bit messy, particularly the font size being too small, which makes extended reading sessions harder than they should be.

---

## Experiment 1: Adaptive Font Size and Layout - Readability Optimization

**Objective:** Test if an adaptive UI with larger, adjustable font sizes and cleaner layout improves user engagement and reduces session abandonment.

**Treatment:** 
- Default font size increased by 15%
- User-adjustable font slider (small, medium, large, extra-large)
- Increased white space between posts
- Reduced visual clutter in sidebar
- Cleaner comment thread hierarchy with better indentation

**Control:** Current Reddit UI layout and font sizing

**Randomization Unit:** User-level

**Eligibility:** All signed-in users on mobile app and desktop web; exclude users who already use old.reddit.com or custom CSS

**Exposure Definition:** Users who view at least 5 posts in the new UI during a session

**Null Hypothesis:** Adaptive font size and cleaner layout does not significantly improve user engagement metrics compared to current UI.

**Alternative Hypothesis:** Users with adaptive font size and cleaner layout will show significantly higher engagement (longer sessions, more posts viewed) compared to current UI.

**Primary Metric:** Average session duration per user

**Secondary Metrics:** 
- Posts viewed per session
- Comment thread depth reached (how far users scroll into discussions)
- Saved posts per user per week
- Return visit rate within 24 hours

**Leading Metrics:** 
- Time spent reading individual posts (early signal of better readability)
- Scroll depth on comment threads
- Font size adjustment usage rate

**Lagging Metrics:**
- 7-day user retention
- Monthly active users (MAU) growth
- Session frequency (sessions per user per week)

**Guardrails:** 
- Bounce rate (users leaving immediately)
- UI element click-through rates (ensure nothing is hidden/broken)
- Accessibility complaints or help center visits
- Ad viewability and CTR (revenue protection)

**Test Duration:** 3-4 weeks

**Minimum Detectable Effect (MDE):** +5-8% increase in session duration

**Test Cell Allocation:** 50% treatment, 50% control

**Segmentation:** Mobile vs desktop users, age groups (older users may benefit more from larger fonts)

---

## Experiment 2: Community Game Hub - Interactive Engagement Features

**Objective:** Determine if adding a dedicated "Games" tab with community mini-games increases user engagement and time spent on platform.

**Treatment:** 
- New "Games" tab in navigation featuring:
  - r/place style collaborative pixel art (weekly themes)
  - Subreddit-specific trivia games with leaderboards
  - Daily prediction games (karma rewards for correct guesses)
  - "Would You Rather" daily polls
  - Community scavenger hunts
- Game achievements and badges displayed on profile
- Karma multipliers for game participation

**Control:** No games tab; current Reddit experience

**Randomization Unit:** User-level

**Eligibility:** Users who are members of at least 3 subreddits and have been active in the past 30 days; exclude brand new accounts (<7 days old)

**Exposure Definition:** Users who click on the Games tab at least once during the test period

**Null Hypothesis:** Adding a dedicated Games hub does not significantly increase user engagement or platform stickiness.

**Alternative Hypothesis:** Users with access to the Games hub will show significantly higher engagement metrics and return more frequently to the platform.

**Primary Metric:** Daily active users (DAU) rate among exposed users

**Secondary Metrics:**
- Time spent in Games tab per session
- Number of games played per user per week
- Cross-subreddit engagement (do users discover new communities through games?)
- Profile views (people checking out game leaderboards)

**Leading Metrics:**
- Game tab click-through rate in first week
- First-game completion rate
- Share rate of game results to subreddits

**Lagging Metrics:**
- 30-day retention rate
- User stickiness (DAU/MAU ratio)
- Karma earned per user (overall platform engagement)
- Reddit Premium conversion rate (engaged users more likely to subscribe)

**Guardrails:**
- Core feed engagement (ensure games don't cannibalize main content)
- Comment and post creation rates (don't want games to replace discussion)
- Reports of spam/abuse through game features
- Server load and performance metrics

**Test Duration:** 4-6 weeks (games need time to build habit loops)

**Minimum Detectable Effect (MDE):** +10-15% increase in DAU among exposed users

**Test Cell Allocation:** 20% treatment (safer rollout for new feature), 80% control

**Segmentation:** By subreddit interest categories (gaming communities vs news communities vs hobby communities)

---

## Experiment 3: Quality Answer Highlighting - AI-Powered "Best Answer" Tag

**Objective:** Test if algorithmically highlighting the "best answer" in threads improves content discovery and encourages quality contributions.

**Treatment:**
- AI model identifies highest-quality answer in question-based threads
- "Best Answer" badge appears on comment (similar to awards but algorithmic)
- Factors: upvotes, awards, OP reply, verified expert status, comment depth, edit history
- Best Answer pinned near top (below pinned mod comment)
- "Was this helpful?" quick reaction buttons
- Notification to comment author when their answer is tagged as "Best"

**Control:** Current organic ranking (by upvotes/time/hot algorithm)

**Randomization Unit:** Subreddit-level (entire subreddits in treatment or control to avoid mixed experiences)

**Eligibility:** Question-based subreddits only (r/AskReddit, r/explainlikeimfive, r/datascience, tech support subs, advice subs); exclude meme/entertainment subs

**Exposure Definition:** Users who view at least 3 question threads with a "Best Answer" tag during the test period

**Null Hypothesis:** Algorithmic "Best Answer" highlighting does not improve user satisfaction or content quality compared to organic ranking.

**Alternative Hypothesis:** Users exposed to "Best Answer" tags will find solutions faster, save more posts, and report higher satisfaction with answer quality.

**Primary Metric:** "Was this helpful?" positive reaction rate

**Secondary Metrics:**
- Time to find answer (scroll depth before user stops scrolling)
- Answer save rate (% of best answers saved vs regular comments)
- OP satisfaction (does OP reply "thank you" or mark resolved?)
- Increased quality answer submissions (do people try harder to get the badge?)

**Leading Metrics:**
- Click-through rate on Best Answer comments
- Reduced search refinement (users don't go back to Google after viewing thread)
- Immediate engagement with Best Answer vs scrolling past

**Lagging Metrics:**
- User return rate to question-based subreddits
- Growth in answer submission rates (are people motivated to contribute?)
- Reduction in duplicate question posts (users finding answers easier)
- Reddit Premium conversion (value perception increases)

**Guardrails:**
- Algorithm accuracy (manual audit sample - is it actually the best answer?)
- Community pushback (mod feedback, user reports)
- Gaming the system (users trying to manipulate the algorithm)
- Fairness checks (are certain user types favored unfairly?)
- Ensure organic high-quality answers still get visibility

**Test Duration:** 4 weeks

**Minimum Detectable Effect (MDE):** +8-12% increase in "helpful" reactions

**Test Cell Allocation:** 50% treatment subreddits, 50% control subreddits

**Segmentation:** Technical subreddits (r/learnprogramming) vs general advice (r/relationship_advice) vs factual Q&A (r/explainlikeimfive)

---

## Summary

These three experiments target different aspects of Reddit's user experience:
1. **Better readability** addresses a core usability pain point that affects session quality
2. **Games hub** adds a new engagement layer to increase stickiness and daily habits
3. **Quality answer highlighting** enhances Reddit's core value proposition of authentic, helpful information

Each experiment has clear success metrics, protects against negative impacts through guardrails, and can be measured through both leading indicators (early signals) and lagging outcomes (long-term impact).