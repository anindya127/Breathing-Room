# The "Breathing Room" App: Master Blueprint

This document is the complete architectural map for building a psychology-based smoking cessation app in Flutter. It combines a simple tracker with a smart coaching algorithm, financial tracking, and a gamified "Non-Smoker Path" to keep the user motivated.

---

## Part 1: Core Features (The "What")

### 1. Dual-Mode Tracking (The Core Interface)
* **What it is:** When you set up the app, you choose your path.
    * **Simple Counter Mode:** For people who just want a clean, stress-free button to count their daily smokes without any rules or goals.
    * **Coach Mode (The Staircase):** The app actively sets a daily limit, slowly stepping the number down over weeks to prevent withdrawal panic.

### 2. The Wallet (Financial Tracker)
* **What it is:** A system to track the financial cost of smoking.
* **How it works:** * You enter how much a pack costs and how many cigarettes are in a pack.
    * **Multi-Currency:** A dropdown lets you select popular currencies (USD, EUR, GBP, JPY, CNY, etc.).
    * **The Math:** Every time you tap the smoke button, the app calculates the exact cost of that single cigarette and adds it to your "Spent Today" total.
    * **Money Saved:** In Coach Mode, it calculates the money you *didn't* spend by staying under your old baseline.

### 3. The Time Machine (Statistics & Reports)
* **What it is:** A dashboard showing your history in easy-to-read charts.
* **Views:**
    * **Daily:** Exactly what times of day you smoked (to identify stress triggers).
    * **Weekly:** A bar chart comparing Monday through Sunday.
    * **Monthly:** A broader view to show the "staircase" trending downwards over time.

### 4. The Trophy Room (Reward Mode)
* **What it is:** A positive reinforcement system.
* **How it works:** You earn digital badges for milestones. 
    * *Examples:* "First Day Under Budget," "3-Day Streak," "Saved Your First $50," "100 Smokes Avoided."

### 5. The Non-Smoker Path (The Journey)
* **What it is:** A visual "roadmap" or video-game-style level map.
* **How it works:** As your daily average drops, your avatar moves along a path. Along the path are "Health Milestones" based on real science (e.g., *Day 3: Lung capacity improving*, *Week 2: Circulation returning to normal*).

---

## Part 2: Technical Architecture (The "Tools")

To build this cleanly in Flutter, we will use these specific tools (packages):

* **Framework:** Flutter (Dart).
* **State Management:** `Riverpod` (To manage the heavy logic of money, limits, and modes without slowing down the app).
* **Database:** `SQLite` or `Isar` (We need a real database now, not just shared preferences, because we are saving hundreds of timestamps and money data).
* **Charts:** `fl_chart` (A beautiful Flutter tool for drawing the Weekly and Monthly bar graphs).
* **UI/UX:** Flutter's `ThemeData` for automatic Light/Dark mode.

---

## Part 3: Development Roadmap (The 6 Phases)

**Golden Rule:** Build one phase completely before starting the next. Do not build the charts until the buttons work perfectly.

### Phase 1: The Foundation & Settings
* Build the basic screens: Home Screen, Settings Screen.
* Build the setup logic: Ask the user for Pack Cost, Currency, and let them pick "Simple" or "Coach" mode.
* **ELI5:** We are building the front door and the reception desk before we build the rest of the house.

### Phase 2: The Tracker & The Database
* Build the "Simple Counter" interface.
* Connect it to the Database. Every time you tap, save the exact Time and the Money Cost to the database.
* **ELI5:** We are hooking up the button so it writes a permanent receipt in our digital notebook every single time it's pressed.

### Phase 3: The Coach Logic (The Algorithm)
* Write the math for Coach Mode. 
* Tell the app to calculate yesterday's total, apply the "Staircase" rule, and generate today's limit.
* Build the visual "Icon Grid" so the user can see their daily allowance.

### Phase 4: The Money & The Charts (Analytics)
* Install the `fl_chart` package.
* Write code to read the database and draw a Weekly Bar Chart.
* Create the "Wallet" screen showing "Money Spent" and "Money Saved."

### Phase 5: Gamification (Rewards & The Path)
* Build the logic for Badges (e.g., *If streak == 3, unlock Bronze Badge*).
* Design the visual "Non-Smoker Path" screen using a scrolling list of health milestones.

### Phase 6: Polish & Launch
* Refine the Light and Dark mode colors.
* Add gentle haptic feedback (phone vibrations) when a button is pressed.
* Add custom app icons.