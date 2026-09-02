import 'package:flutter/foundation.dart';

import 'service_category.dart';

/// A service available through the Portal catalog.
///
/// This frontend domain model intentionally contains no JSON parsing or
/// backend-specific field names. A future API repository will map backend DTOs
/// into this model.
@immutable
final class PortalService {
  const PortalService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    this.isFeatured = false,
    this.isAvailable = true,
  }) : assert(id != '', 'id cannot be empty.'),
       assert(name != '', 'name cannot be empty.'),
       assert(description != '', 'description cannot be empty.'),
       assert(iconName != '', 'iconName cannot be empty.');

  /// Stable service identifier.
  final String id;

  /// User-facing service name.
  final String name;

  /// Short service description displayed in the catalog.
  final String description;

  /// Category used for filtering and organization.
  final ServiceCategory category;

  /// Frontend icon identifier.
  ///
  /// This remains a string instead of an [IconData] value so the domain model
  /// does not depend on Flutter presentation types.
  final String iconName;

  /// Whether the service should be highlighted in the catalog.
  final bool isFeatured;

  /// Whether the service is currently available for use.
  final bool isAvailable;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PortalService &&
            other.id == id &&
            other.name == name &&
            other.description == description &&
            other.category == category &&
            other.iconName == iconName &&
            other.isFeatured == isFeatured &&
            other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      category,
      iconName,
      isFeatured,
      isAvailable,
    );
  }

  @override
  String toString() {
    return 'PortalService('
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'category: $category, '
        'iconName: $iconName, '
        'isFeatured: $isFeatured, '
        'isAvailable: $isAvailable'
        ')';
  }
}
