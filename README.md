<div align="center">

# My Study Buddy

**A Flutter mobile app that helps students study in a healthier, more balanced way**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-informational)]()
[![Status](https://img.shields.io/badge/status-in%20progress-yellow)]()

</div>

---

## Overview

Most study apps optimize for one thing: getting you to work more. **My Study Buddy** starts from a different question — *what does a student actually need to study well?*

The answer is usually more than a timer. Stress, low motivation, and feeling overwhelmed are often the real blockers, not a lack of discipline. My Study Buddy pairs a focus timer with mood check-ins, mood-based coping exercises, and a gentle progress system, so productivity and well-being are treated as part of the same problem instead of two separate apps.

It's a solo project built end-to-end in Flutter — UI, state, local persistence, and product design — as part of my portfolio as a computer engineering student.

## Table of Contents

- [Why I Built This](#why-i-built-this)
- [What Makes It Different](#what-makes-it-different)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [What I Learned](#what-i-learned)
- [Project Status & Roadmap](#project-status--roadmap)
- [Disclaimer](#disclaimer)
- [Author](#author)

## Why I Built This

Most productivity apps focus only on tasks, timers, and streaks. I wanted to explore what happens if a study app also asks *how are you feeling* before it asks *how long did you study* — encouraging students to notice their state, take small steps, and build consistency without pressure or perfection.

## What Makes It Different

- **Mood-aware, not one-size-fits-all** — exercises are chosen based on how the student actually feels, not a generic tip list.
- **Calm by design** — a soft, teddy-themed interface built to feel supportive rather than intimidating.
- **Gentle progress system** — stars and constellations reward consistency without turning studying into a competition.
- **Small, realistic actions** — every feature nudges toward one small next step instead of demanding perfection.

## Features

### Focus Timer
Start a study session and earn progress rewards on completion — a simple, low-friction way to build focus habits.

### Mood Check-In
Students select how they feel — anxious, tired, overwhelmed, calm, focused, happy — and the app responds with a matching exercise: breathing, grounding, journaling, tiny steps, reframing, or intention setting.

### Motivation Boost
Pick what you're struggling with and get a short, encouraging message plus one concrete action you can take right now.

### Progress Tracking
A dedicated screen tracks completed sessions, stars earned, total focus time, and unlocked constellations, all persisted locally on the device.

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="screenshots/home.png" width="220"><br>
      <sub><b>Home Screen</b></sub>
    </td>
    <td align="center">
      <img src="screenshots/timer.png" width="220"><br>
      <sub><b>Focus Timer</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/mood-checkin.png" width="220"><br>
      <sub><b>Mood Check-In</b></sub>
    </td>
    <td align="center">
      <img src="screenshots/progress.png" width="220"><br>
      <sub><b>Progress Tracking</b></sub>
    </td>
  </tr>
</table>

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Local storage:** SharedPreferences
- **UI:** Material Design
- **Targets:** Android, iOS (project also includes Windows/macOS/Linux/Web build scaffolding)

## Getting Started

```bash
# Clone the repo
git clone https://github.com/Rymzz/my-study-buddy.git
cd my-study-buddy

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured.

## What I Learned

Building My Study Buddy end-to-end meant going well beyond writing screens:

- Structuring a multi-screen Flutter app and managing state across features
- Designing responsive, reusable UI components
- Persisting user progress locally with SharedPreferences
- Translating a real user need (student stress + productivity) into a coherent feature set
- Thinking as a product designer, not just a developer — deciding what *not* to build was as important as what to build

## Project Status & Roadmap

The core features (focus timer, mood check-in, motivation boost, progress tracking) are functional. Currently polishing:

- [ ] UI/UX refinements
- [ ] Code cleanup and documentation
- [ ] Additional screenshots and demo GIF
- [ ] Portfolio-ready release build

## Disclaimer

My Study Buddy is **not** a medical or therapeutic tool. It's a student productivity and wellness project designed to support studying, motivation, and personal organization — not a substitute for professional mental health support.

## Author

**Rym Zidi**
Computer Engineering Student

