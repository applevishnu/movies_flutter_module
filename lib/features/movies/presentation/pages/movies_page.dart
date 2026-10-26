import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/platform/native_bridge.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_error_widget.dart';
import '../widgets/movie_loading_widget.dart';
import 'movie_detail_page.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MoviesBloc>(
      create: (context) => sl<MoviesBloc>()..add(const FetchMovies()),
      child: const MoviesPageView(),
    );
  }
}

class MoviesPageView extends StatefulWidget {
  const MoviesPageView({super.key});

  @override
  State<MoviesPageView> createState() => _MoviesPageViewState();
}

class _MoviesPageViewState extends State<MoviesPageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MoviesBloc>().add(const LoadMoreMovies());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Popular Movies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              try {
                sl<NativeBridge>().closeModule();
              } catch (_) {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<MoviesBloc, MoviesState>(
        listener: (context, state) {
          if (state is MoviesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const MovieLoadingWidget();
          }

          if (state is MoviesError) {
            return MovieErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<MoviesBloc>().add(const FetchMovies());
              },
            );
          }

          if (state is MoviesLoaded) {
            if (state.movies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.movie_filter_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No movies found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MoviesBloc>().add(const RefreshMovies());
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MoviesBloc>().add(const RefreshMovies());
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.hasReachedMax
                    ? state.movies.length
                    : state.movies.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.movies.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final movie = state.movies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      context.read<MoviesBloc>().add(MovieSelected(movie));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(movie: movie),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
