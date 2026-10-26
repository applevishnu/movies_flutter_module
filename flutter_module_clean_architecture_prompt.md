# Prompt: Flutter Module + Native Android/iOS Integration (Clean Architecture, Bloc, TDD)

You are a senior mobile engineer experienced in Flutter, native Android (Kotlin), native iOS (Swift), Clean Architecture, and Test Driven Development. Build the complete solution described below. Work step by step, write tests before implementation (red, green, refactor), and explain key decisions briefly as you go.

---

## 1. Goal

Build a **Flutter module** that is embedded into two **native apps** (Android and iOS).

Flow:
1. The native app shows a button labeled **"Show List of Movies"**.
2. Tapping it launches the Flutter module.
3. The Flutter module fetches movies from the **TMDB API** and shows them as a list of cards (movie name, poster image, description).
4. When the user taps a movie, the Flutter module closes and returns control to the native app, passing the selected movie's data.
5. The native app opens a **native screen that plays the movie's trailer**.

---

## 2. Deliverables: three separate public GitHub repositories

| Repo | Contents |
|------|----------|
| `movies_flutter_module` | Flutter module (Dart), Clean Architecture, Bloc, all tests |
| `movies_android_app` | Native Android app (Kotlin) that hosts the Flutter module and plays trailers |
| `movies_ios_app` | Native iOS app (Swift) that hosts the Flutter module and plays trailers |

Each repo needs a `README.md` with setup steps, architecture explanation, how to run tests, and how the three repos connect (e.g. Android uses the module as a Gradle/AAR or `settings.gradle` include; iOS uses CocoaPods or a built XCFramework).

---

## 3. Flutter module requirements

### 3.1 Create as a module
```
flutter create --template=module movies_flutter_module
```

### 3.2 Clean Architecture folder structure
```
lib/
├── core/
│   ├── error/            # Failure, Exception classes
│   ├── network/          # Dio client, interceptors, NetworkInfo
│   ├── usecase/          # Base UseCase<Type, Params>
│   ├── di/               # get_it service locator
│   └── platform/         # MethodChannel wrapper (native bridge)
├── features/
│   └── movies/
│       ├── data/
│       │   ├── datasources/   # MovieRemoteDataSource (+ abstract interface)
│       │   ├── models/        # MovieModel (fromJson/toJson), extends Movie entity
│       │   └── repositories/  # MovieRepositoryImpl
│       ├── domain/
│       │   ├── entities/      # Movie (pure Dart, no Flutter/JSON imports)
│       │   ├── repositories/  # MovieRepository (abstract)
│       │   └── usecases/      # GetPopularMovies, GetMovieTrailer
│       └── presentation/
│           ├── bloc/          # MoviesBloc, MoviesEvent, MoviesState
│           ├── pages/         # MoviesPage
│           └── widgets/       # MovieCard, loading/error/empty widgets
└── main.dart
```

Rules:
- **Dependency rule**: presentation → domain ← data. The domain layer must not import Flutter, Dio, or any data/presentation code.
- Use **`Either<Failure, T>`** (`dartz` or `fpdart`) for error handling in repositories and use cases.
- Use **dependency injection** with `get_it` (constructor injection everywhere).
- Use `equatable` for entities, events, and states.

### 3.3 TMDB integration
- Generate my own API key at themoviedb.org (Settings → API). **Do not hardcode or commit the key.** Load it via `--dart-define=TMDB_API_KEY=...` or a git-ignored `.env`, and document this in the README. Provide a `.env.example`.
- Endpoints:
  - `GET /movie/popular` (or `/movie/now_playing`) with pagination (`page` param)
  - `GET /movie/{movie_id}/videos` to get the trailer (pick the YouTube video with `type == "Trailer"` and `site == "YouTube"`; fall back to Teaser)
- Poster URL: `https://image.tmdb.org/t/p/w500{poster_path}`
- Use `dio` with a base-URL config and an auth interceptor.

### 3.4 UI
- Scrollable list of **cards**; each card shows poster image (use `cached_network_image` with placeholder and error widget), title, and description (max 3 lines, ellipsized).
- States handled: loading (shimmer or spinner), success, empty, error with a **Retry** button.
- Infinite scroll / pagination (nice to have).
- Pull to refresh (nice to have).
- Light and dark theme support.

### 3.5 State management: Bloc
- `MoviesBloc` with events: `FetchMovies`, `LoadMoreMovies`, `RefreshMovies`, `MovieSelected(movie)`.
- States: `MoviesInitial`, `MoviesLoading`, `MoviesLoaded(movies, hasReachedMax)`, `MoviesError(message)`.
- On `MovieSelected`, the bloc calls the trailer use case, then invokes the native bridge to hand the result to the native app (via a `NavigationService` abstraction so it is mockable in tests).

### 3.6 Native bridge (Flutter ↔ native)
- Use `MethodChannel('com.example.movies/bridge')`.
- Flutter → native method: `openTrailer` with payload:
  ```json
  { "movieId": 123, "title": "...", "overview": "...", "posterUrl": "...", "trailerKey": "YOUTUBE_KEY" }
  ```
- After sending, Flutter closes itself (`SystemNavigator.pop()` on Android; dismiss the FlutterViewController on iOS). Define this clearly in the contract so both native apps behave the same.
- Wrap the channel in an abstract `NativeBridge` class in `core/platform` with an implementation and a fake/mock for tests.

---

## 4. Native Android app (`movies_android_app`)

- Language: Kotlin; min SDK 24; ViewBinding or Jetpack Compose (state your choice).
- Main screen with a button labeled exactly **"Show List of Movies"**.
- On tap, launch the Flutter module using `FlutterActivity` with a cached `FlutterEngine` (pre-warm in `Application`), or `withNewEngine()`.
- Register the `MethodChannel` and handle `openTrailer`: start a native `TrailerActivity` passing the data as intent extras.
- `TrailerActivity` plays the YouTube trailer natively. Use the `android-youtube-player` library (or a WebView with the YouTube embed URL), and show the movie title and overview beneath the player.
- Handle back navigation correctly (trailer screen → main screen).
- Integrate the module as a Gradle dependency (`include_flutter.groovy` or built AAR); document the exact approach.

## 5. Native iOS app (`movies_ios_app`)

- Language: Swift; iOS 14+; UIKit or SwiftUI (state your choice).
- Main screen with a button labeled exactly **"Show List of Movies"**.
- On tap, present a `FlutterViewController` using a shared `FlutterEngine` created in the `AppDelegate`.
- Register the `FlutterMethodChannel` and handle `openTrailer`: dismiss the Flutter view controller, then push/present a native `TrailerViewController`.
- `TrailerViewController` plays the YouTube trailer natively (`WKWebView` with the YouTube embed URL, or `YouTubeiOSPlayerHelper`), with title and overview shown below.
- Integrate the module using CocoaPods (`flutter_module` pod via `podhelper.rb`) and document the exact steps.

---

## 6. Testing and TDD (bonus; please treat as required)

Follow **red → green → refactor**. Commit history should show tests committed before or alongside the implementation (e.g. `test: add failing test for GetPopularMovies`, `feat: implement GetPopularMovies`).

**Unit tests** (`test/`) using `flutter_test`, `bloc_test`, and `mocktail`:
- Models: `fromJson` / `toJson`, using JSON fixtures under `test/fixtures/`.
- Data source: mock Dio and test success, non-200 responses, and exceptions.
- Repository: success → `Right`, exception → `Left(Failure)`.
- Use cases: delegate to the repository correctly.
- Bloc: use `blocTest` for every event and state transition, including error and pagination cases.

**Widget tests**:
- `MovieCard` renders title, description, and image placeholder.
- `MoviesPage` shows the loading, loaded, error (with retry), and empty states.
- Tapping a card dispatches `MovieSelected`.

**Integration tests** (`integration_test/`):
- Full flow in the Flutter module with a mocked/fake HTTP layer: launch → list loads → tap a movie → bridge receives `openTrailer` with the correct payload.
- Native side (basic): Android Espresso test and iOS XCUITest verifying that the button exists, launches the Flutter screen, and that the trailer screen opens after the bridge call.

Target **≥ 80% coverage** on the domain and data layers; include the coverage command and result in the README.

---

## 7. Quality requirements

- Null-safe, lint-clean code (`flutter_lints` or `very_good_analysis`); `flutter analyze` must pass with zero issues.
- No API keys or secrets committed.
- Meaningful commit messages (Conventional Commits).
- Handle no-internet, timeout, and API error cases with user-friendly messages.
- Keep files small and single-purpose; name things consistently.

## 8. What I want back from you

1. A short architecture overview (layers, data flow diagram in text/mermaid, and the bridge contract).
2. The full file tree for all three repositories.
3. Complete code for every file, in implementation order, following TDD (the test file first, then the implementation).
4. Exact integration steps for Android and iOS.
5. A README for each repository.
6. A final checklist confirming every requirement above is met.

Start with step 1, then proceed through the Flutter module layer by layer: **domain → data → presentation → bridge**, and only then the native apps.
