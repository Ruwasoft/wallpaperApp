class WallpaperModel{


  String photographer;
  String photographerUrl;
  int photographerId;
  SrcModel src;

  WallpaperModel({this.photographer,this.photographerUrl,this.photographerId,this.src});

  factory WallpaperModel.fromMap(Map<String,dynamic> jsonData )
  {
    return WallpaperModel(
      src: SrcModel.fromMap(jsonData["src"]),
      photographerUrl: jsonData["photographerUrl"],
      photographerId: jsonData["photographerId"],
      photographer: jsonData["photographer"]
    );
  }
}


class SrcModel{

  String original;
  String small;
  String portrait;

  SrcModel({this.original,this.small,this.portrait});

  factory SrcModel.fromMap(Map<String,dynamic> jsonData){
    return SrcModel(
        portrait: jsonData["portrait"],
      original: jsonData["original"],
      small: jsonData["small"]
    );
  }

}