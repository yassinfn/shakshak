# ShakShak - The Secret Agent Messaging App

## Overview

ShakShak is a mobile application for secret agents to exchange geolocated messages. Agents can create hidden messages at their current location, and other agents can discover them when they are physically nearby.

## Features

*   **Agent Profile:** Each agent has a unique username and a `discoveryPoints` score.
*   **Message Creation:** Agents can write a short text message and hide it at their current GPS location. An agent can only post one message per 24 hours.
*   **Message Detection:** Agents can scan their surroundings to find messages hidden by other agents within a 5km radius.
*   **Discovery Points:** Finding a message from another agent for the first time awards 10 discovery points.
*   **Immersive Experience:** The app uses a dark, spy-themed UI and sound effects to enhance the secret agent feel.

## Style and Design

*   **Theme:** Dark, with cyan as the accent color, evoking a high-tech, clandestine atmosphere.
*   **Typography:** Modern and clean fonts for readability.
*   **UI Components:** Custom-styled buttons, text fields, and app bar to fit the theme.

## Project Structure

*   `lib/main.dart`: App entry point, theme definition, and main authentication wrapper.
*   `lib/screens/profile_config_screen.dart`: Screen for new users to create their agent profile (username).
*   `lib/screens/home_screen_dispatcher.dart`: A dispatcher that checks if a user's profile is complete before sending them to the dashboard.
*   `lib/screens/dashboard_screen.dart`: The main hub for agents, showing their score and providing access to core features.
*   `lib/screens/detection_screen.dart`: The screen for detecting nearby messages, using the device's GPS.
*   `lib/screens/create_message_screen.dart`: The screen where agents can write and hide their messages.

## Current Plan (Completed)

This was the final implementation phase. All core features have been implemented.

1.  **Reward and Sound Effects:** Implemented the logic to award discovery points and play a sound effect when a message is found.
2.  **Creation Limitation:** Added a check to ensure users can only create one message every 24 hours.
3.  **Final Polish:** Updated all necessary files and created a placeholder sound file.
