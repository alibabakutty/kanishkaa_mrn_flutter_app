

class SiteModel {
  final int id;
  final String siteName;
  final String siteCategory;
  final String siteStatus;


  SiteModel({
    required this.id,
    required this.siteName,
    required this.siteCategory,
    required this.siteStatus,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'],
      siteName: json['siteName'],
      siteCategory: json['siteCategory'],
      siteStatus: json['siteStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteName': siteName,
      'siteCategory': siteCategory,
      'siteStatus': siteStatus,
    };
  }
}