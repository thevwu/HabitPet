# Overview
A cozy, local-first productivity app where your pet reflects how well you care for your routines and how sustainable your system really is.
Features a cute reactive pet companion and a sync-aware architecture.

## Tech Choices
### Swift
  - SwiftUI-first for the UI, UIKit for chart & timeline component
  - TCA for state management and effects
  - Core Data for local persistence
  - Swift Concurrency end to end
  - WidgetKit for home screen surface

### Backend and sync platform
  - Supabase for authentication and Postgres-backed remote storage
  - Sync-aware data model from day one
  - Optional account creation can be deferred without changing the local-first architecture


### Website
  - Polished landing page
  - Technical case study page
  - Keeping the website lightweight during v1

## Architecture
Uses a state-driven, feature-based architecture centered on The Composable Architecture (TCA).

### App modules
  - App / Composition
  - Features
  - Domain
  - Data
  - Persistence
  - Services
  - Widgets
  - Tests

## v1 in progress
### Home
  - pet hero card
  - today’s habits and tasks
  - pet mood and status line
  - quick complete / snooze / skip
  - care score summary
  - overload indicator if the day is overpacked
  - sync status badge
    
### Habits
  - recurring habits
  - schedule and cadence
  - difficulty / effort
  - category or tag
  - reminder
  - optional note
  - streak
  - freeze / skip support
  - streak protection

### Tasks
  - one-off tasks
  - due date / time
  - category or tag
  - effort
  - optional note
  - complete / reschedule

### Pet
  - choose pet: dog, cat (more planned for v2)
  - base mood states
  - visible response to completion or neglect
  - simple progression / evolution system
  - interaction screen that reflects progress 

### Insights
  - streak chart
  - care score trend
  - burnout / overload indicator
  - weekly completion summary

### System
  - onboarding
  - local notifications
  - widget
  - local-first persistence
  - optional sign-in after onboarding
  - settings
  - privacy screen
  - app icon / theme polish
