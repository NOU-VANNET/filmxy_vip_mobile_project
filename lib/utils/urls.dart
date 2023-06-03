class Urls {
  static String apiDomain({String route = ""}) => "https://dev.filmxy.vip/api/v1/$route";

  static List<Map<String, String>> get labelMaps => [
    {
      "type": "popular",
      "label": "Popular This Week"
    },
    {
      "type": "movies",
      "label": "Latest Movies"
    },
    {
      "type": "tv",
      "label": "Latest TV Series"
    },
    {
      "type": "anime",
      "label": "Latest Anime Series"
    },
  ];
}