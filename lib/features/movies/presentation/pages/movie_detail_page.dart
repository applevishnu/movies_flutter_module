import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/platform/native_bridge.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/trailer.dart';
import '../../domain/usecases/get_movie_trailer.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final GetMovieTrailer? getMovieTrailer;
  final NativeBridge? nativeBridge;

  const MovieDetailPage({
    super.key,
    required this.movie,
    this.getMovieTrailer,
    this.nativeBridge,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Trailer? _trailer;
  bool _isLoadingTrailer = true;
  String? _trailerError;

  @override
  void initState() {
    super.initState();
    _loadTrailer();
  }

  Future<void> _loadTrailer() async {
    setState(() {
      _isLoadingTrailer = true;
      _trailerError = null;
    });

    if (widget.getMovieTrailer == null && !sl.isRegistered<GetMovieTrailer>()) {
      if (mounted) {
        setState(() {
          _isLoadingTrailer = false;
        });
      }
      return;
    }

    final getMovieTrailer = widget.getMovieTrailer ?? sl<GetMovieTrailer>();
    final result = await getMovieTrailer(
      GetMovieTrailerParams(movieId: widget.movie.id),
    );

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoadingTrailer = false;
            _trailerError = failure.message;
          });
        }
      },
      (trailer) {
        if (mounted) {
          setState(() {
            _isLoadingTrailer = false;
            _trailer = trailer;
          });
        }
      },
    );
  }

  void _onPlayTrailer() {
    if (_trailer == null) return;

    final posterUrl = ApiConstants.posterUrl(widget.movie.posterPath);

    final bridge = widget.nativeBridge ??
        (sl.isRegistered<NativeBridge>() ? sl<NativeBridge>() : null);

    bridge?.openTrailer(
      movieId: widget.movie.id,
      title: widget.movie.title,
      overview: widget.movie.overview,
      posterUrl: posterUrl,
      trailerKey: _trailer!.key,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Trailer [${_trailer!.key}] sent to Native Host Bridge!',
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterUrl = ApiConstants.posterUrl(widget.movie.posterPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster / Header Banner
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (posterUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.movie, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.movie, size: 64),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.movie.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata Badges
                  Row(
                    children: [
                      if (widget.movie.releaseDate != null &&
                          widget.movie.releaseDate!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.movie.releaseDate!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (widget.movie.voteAverage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.movie.voteAverage!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overview Section
                  Text(
                    'Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'No overview available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Trailer Section
                  Text(
                    'Official Trailer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoadingTrailer)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_trailer != null) ...[
                    GestureDetector(
                      onTap: _onPlayTrailer,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://img.youtube.com/vi/${_trailer!.key}/hqdefault.jpg',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.black87,
                                  child: const Icon(
                                    Icons.play_circle_outline,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _onPlayTrailer,
                        icon: const Icon(Icons.play_circle_filled_rounded),
                        label: Text('Play Trailer (${_trailer!.name})'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _trailerError ?? 'No trailer available.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
