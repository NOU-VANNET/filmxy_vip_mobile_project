import 'package:video_player/video_player.dart';
import 'package:vip/models/caption_model.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/models/genre_type.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/models/subtitle_model.dart';

abstract class Repository {

  Future<List<MovieModel>> fetchData(String type, {int? page, String? filterType});

  Future<String> fetchUrlBody(String url);

  Future<List<MovieModel>> searchMovie(String query);

  Future<List<GenreTypeModel>> getGenreType(String url);

  Future<List<MovieModel>> getMoviesTypeList(String url);

  Future<DetailModel> getDetailModel(String link);

  Future<List<SubtitleModel>> getSubtitles(String url);

  Future<String?> getDirectLink(String linkId);

  Future<String> getSubtitleSource(String k);

  List<CaptionModel> captionDecode(String source);

  CaptionModel? findCaptionFromDuration(List<CaptionModel> captions, VideoPlayerController controller);

  Future<String> getDetailCache();

  Future setDetailCache(List<DetailModel> dataList);

  Future<Map<String, dynamic>> serverLogin(String login, String password);

  Future<String?> download({
    required String linkId,
    required String filename,
    required num postId,
  });

  Future<String> get getLocalDownloadPath;

}
