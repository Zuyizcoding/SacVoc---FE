// Model kết quả F3, chuyển JSON API thành dữ liệu có kiểu rõ.

class OutfitItem {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final String shopeeUrl;
  final String priceRange;
  final double score;
  final double? retrievalScore;
  final List<String> reasonTags;

  const OutfitItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.shopeeUrl,
    required this.priceRange,
    required this.score,
    required this.retrievalScore,
    required this.reasonTags,
  });

  /// Parse từ JSON (API response) → Domain model
  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      shopeeUrl: json['shopee_url'] as String,
      priceRange: json['price_range'] as String,
      score: (json['score'] as num).toDouble(),
      retrievalScore: (json['retrieval_score'] as num?)?.toDouble(),
      reasonTags: List<String>.from(json['reason_tags'] as List? ?? const []),
    );
  }
}

class OutfitResult {
  /// Text query đã dùng để search — hiển thị debug / "Tìm kiếm theo..."
  final String queryUsed;
  final String? querySource;

  /// Top-6 outfit phù hợp nhất
  final List<OutfitItem> outfits;

  const OutfitResult({
    required this.queryUsed,
    required this.querySource,
    required this.outfits,
  });

  /// Parse từ API response data field
  factory OutfitResult.fromJson(Map<String, dynamic> json) {
    return OutfitResult(
      queryUsed: json['query_used'] as String,
      querySource: json['query_source'] as String?,
      outfits: (json['outfits'] as List)
          .map((e) => OutfitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OutfitDetail {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final String shopeeUrl;
  final String priceRange;
  final String? explanation; // SHOULD: Gemini real-time, null ở MUST

  const OutfitDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.shopeeUrl,
    required this.priceRange,
    this.explanation,
  });

  factory OutfitDetail.fromJson(Map<String, dynamic> json) {
    return OutfitDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      shopeeUrl: json['shopee_url'] as String,
      priceRange: json['price_range'] as String,
      explanation: json['explanation'] as String?,
    );
  }
}
