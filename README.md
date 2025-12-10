# Personal Task Manager

A Flutter task management application built with clean architecture principles and modern UI/UX design.

## Architecture

The app follows **Clean Architecture** with three main layers:

- **Domain**: Core business logic and entities (`Task` entity with Freezed)
- **Data**: Data sources and repository implementations using Hive for local storage
- **Presentation**: UI screens, widgets, and state management with Riverpod 3

This separation ensures maintainability, testability, and scalability.

## Features

- ✅ Create, edit, and delete tasks with title and description
- ✅ Mark tasks as complete/incomplete with auto-filtering
- ✅ Search tasks by title or description
- ✅ Filter tasks by due date with horizontal date selector
- ✅ Swipe to delete with confirmation dialog
- ✅ Completed tasks screen with badge counter
- ✅ Persistent local storage with Hive
- ✅ Modern light-themed UI with glass effects
- ✅ Pull to refresh functionality
- ✅ Empty state and error handling with retry

## Tech Stack

- **Flutter**: Cross-platform framework
- **Riverpod 3**: State management with code generation
- **Hive**: Fast NoSQL database for local persistence
- **Freezed**: Immutable data classes and union types
- **UUID**: Unique task identification

## Getting Started

1. Install dependencies: `flutter pub get`
2. Generate code: `dart run build_runner build --delete-conflicting-outputs`
3. Run the app: `flutter run`
