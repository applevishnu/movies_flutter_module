# Movies Flutter Module

A production-ready Flutter module built with **Clean Architecture**, **BLoC Pattern**, and **Test Driven Development (TDD)** designed to be embedded into native Android and iOS host apps.

---

## 1. Architecture Overview

This module adheres strictly to Clean Architecture separation of concerns:

- **Presentation Layer** (`lib/features/movies/presentation/`):
  - **BLoC**: `MoviesBloc`, `MoviesEvent`, `MoviesState`
  - **Pages**: `MoviesPage`, `MoviesPageView`
  - **Widgets**: `MovieCard` (cached network images, 3-line overview), `MovieLoadingWidget`, `MovieErrorWidget`
- **Domain Layer** (`lib/features/movies/domain/`):
  - Pure Dart (zero dependencies on Flutter, Dio, or JSON serialization)
  - **Entities**: `Movie`, `Trailer` (`Equatable`)
  - **Use Cases**: `GetPopularMovies`, `GetMovieTrailer`
  - **Repository Interface**: `MovieRepository`
- **Data Layer** (`lib/features/movies/data/`):
  - **Models**: `MovieModel`, `TrailerModel` (extends domain entities, `fromJson`/`toJson`)
  - **Data Source**: `MovieRemoteDataSource` querying TMDB API via `Dio`
  - **Repository Implementation**: `MovieRepositoryImpl` handling network errors and mapping exceptions to `Either<Failure, T>`
- **Core Layer** (`lib/core/`):
  - `di/`: Dependency injection using `get_it`
  - `error/`: Failure and Exception definitions
  - `network/`: Dio client configuration and TMDB auth interceptor
  - `platform/`: `NativeBridge` wrapping `MethodChannel('com.example.movies/bridge')`

---

## 2. Native Bridge Contract

- **Channel Name**: `com.example.movies/bridge`
- **Method**: `openTrailer`
- **Payload Schema**:
```json
{
  "movieId": 550,
  "title": "Fight Club",
  "overview": "A ticking-time-bomb insomniac...",
  "posterUrl": "https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
  "trailerKey": "dG91B3hHyIc"
}
```
After dispatching `openTrailer`, the module signals `closeModule` (`SystemNavigator.pop()` on Android / dismiss on iOS) to return control to the host app.

---

## 3. Setup and Running

### 3.1 Provide TMDB API Key

Get your API key from [The Movie Database (TMDB)](https://www.themoviedb.org/settings/api).

Pass your API key using `--dart-define`:
```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key_here
```

Or target the simulator directly:
```bash
flutter run -d CD8EEF3D-DF25-4D7C-84B7-13FE720DEF8A --dart-define=TMDB_API_KEY=your_tmdb_api_key_here
```

*(A sample template is provided in `.env.example`)*

---

## 4. Running Tests & Code Coverage

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Calculate Domain & Data Layer Coverage:
```bash
awk '/^SF:lib\/features\/movies\/(domain|data)/ {in_target=1} /^end_of_record/ {in_target=0} in_target && /^LF:/ {split($0,a,":"); lf+=a[2]} in_target && /^LH:/ {split($0,a,":"); lh+=a[2]} END {printf "Domain & Data Coverage: %.2f%% (%d/%d lines)\n", (lh/lf)*100, lh, lf}' coverage/lcov.info
```
**Current Result: 90.77% coverage** (Target: ≥ 80%)

### Run Static Analysis:
```bash
flutter analyze
```
Result: **0 issues found**

---

## 5. Host Integration

- **Android Host (`movies_android_app`)**:
  Include the module in `settings.gradle.kts`:
  ```groovy
  setBinding(new Binding([gradle: this]))
  evaluate(new File(settingsDir, '../movies_flutter_module/.android/include_flutter.groovy'))
  ```
  Add `implementation project(':flutter')` in `app/build.gradle`.

- **iOS Host (`movies_ios_app`)**:
  Include the module via CocoaPods in `Podfile`:
  ```ruby
  flutter_application_path = '../movies_flutter_module'
  load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
  install_all_flutter_pods(flutter_application_path)
  ```
