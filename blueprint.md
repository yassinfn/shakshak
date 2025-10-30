
# ShakShak App Blueprint

## Overview

ShakShak is a geocaching-style mobile application where users can hide and find messages at specific locations.

## Architecture

- **State Management**: Provider
- **Routing**: go_router
- **Backend**: Firebase (Authentication, Firestore)

## Features

### Current

- **Firebase Setup**: The project is connected to Firebase.
- **Routing**: Basic routing is set up with `go_router`.
- **User Authentication**: Anonymous authentication with Firebase.
- **Message Creation**: Users can create and hide messages at their current location.
- **Message List**: The main screen displays a list of all messages.
- **Message Details**: Users can tap on a message in the list to see more details, including its geographic coordinates.

### Planned

- **Styling**: Improve the overall look and feel of the app.
- **Delete Messages**: Allow users to delete their own messages.
