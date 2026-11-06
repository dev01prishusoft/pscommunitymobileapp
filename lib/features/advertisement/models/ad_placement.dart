/// Represents an advertisement placement slot or screen position.
///
/// Fully dynamic: Allows any placement code returned from the backend
/// while maintaining backward compatibility with well-known placements.
class AdPlacement {
  final String code;

  const AdPlacement(this.code);

  // Well-known placements maintained for type-safety and backward compatibility
  static const homeTop = AdPlacement('home-top');
  static const homeBottom = AdPlacement('home-bottom');
  static const memberDirectory = AdPlacement('member-directory');
  static const occupationDirectory = AdPlacement('occupation-directory');
  static const matrimonialDirectory = AdPlacement('matrimonial-directory');
  static const eventList = AdPlacement('event-list');
  static const eventDetail = AdPlacement('event-detail');
  static const notifications = AdPlacement('notifications');
  static const announcements = AdPlacement('announcements');
  static const advertisementList = AdPlacement('advertisement-list');
  static const libraryList = AdPlacement('library-list');
  static const libraryDetail = AdPlacement('library-detail');
  static const other = AdPlacement('other');

  /// Creates or retrieves an [AdPlacement] dynamically from any code string.
  /// Any placement code configured in backend will be dynamically instantiated
  /// and will never collapse to 'other' unless input is null or empty.
  static AdPlacement fromCode(String? code) {
    if (code == null) return AdPlacement.other;
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) return AdPlacement.other;

    switch (normalized) {
      case 'home-top':
        return AdPlacement.homeTop;
      case 'home-bottom':
        return AdPlacement.homeBottom;
      case 'member-directory':
        return AdPlacement.memberDirectory;
      case 'occupation-directory':
        return AdPlacement.occupationDirectory;
      case 'matrimonial-directory':
        return AdPlacement.matrimonialDirectory;
      case 'event-list':
        return AdPlacement.eventList;
      case 'event-detail':
        return AdPlacement.eventDetail;
      case 'notifications':
      case 'notification':
        return AdPlacement.notifications;
      case 'announcements':
      case 'announcement':
        return AdPlacement.announcements;
      case 'advertisement-list':
        return AdPlacement.advertisementList;
      case 'library-list':
        return AdPlacement.libraryList;
      case 'library-detail':
        return AdPlacement.libraryDetail;
      case 'other':
        return AdPlacement.other;
      default:
        // Return a dynamic placement for any custom code from backend
        return AdPlacement(normalized);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdPlacement &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}
