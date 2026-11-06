import 'package:sac_voc/features/analysis/domain/body_result.dart';
import 'package:sac_voc/features/analysis/domain/color_result.dart';

ColorResult colorResult({String source = 'live'}) => ColorResult.fromJson({
      'sub_season': 'Soft Autumn',
      'primary_season': 'Autumn',
      'confidence': 0.8,
      'analysis_source': source,
      'secondary_season': 'True Autumn',
      'explanation': 'Tông da ấm.',
      'palette': [
        '#8B7355',
        '#A0785A',
        '#C4A882',
        '#8B8B4B',
        '#D2B48C',
        '#BDB76B'
      ],
      'makeup': {'lip': <String>[], 'eye': <String>[], 'hair': <String>[]},
      'advice': 'Ưu tiên olive.',
      'menswear': {
        'tops': ['Olive'],
        'bottoms': ['Khaki'],
        'accessories': ['Đồng']
      },
    });

BodyResult bodyResult({String source = 'live'}) => BodyResult.fromJson({
      'shape': 'Rectangle',
      'confidence': 0.75,
      'analysis_source': source,
      'photo_quality_score': 0.8,
      'photo_quality_band': 'good',
      'measurements': {
        'shoulder_relative': 'balanced',
        'hip_relative': 'balanced',
        'waist_definition': 'minimal'
      },
      'styling_tips': ['Áo vừa vai.', 'Layer mỏng.', 'Quần ống đứng.'],
      'avoid': ['Áo quá rộng.', 'Quần quá bó.'],
      'explanation': 'Vai và hông cân bằng.',
    });
