enum AdPlacement {
  homeTop,
  homeBottom,
  memberDirectory,
  occupationDirectory,
  matrimonialDirectory,
  eventList,
  eventDetail,
  notifications,
  announcements,
  other,
  advertisementList;

  String get code {
    switch (this) {
      case AdPlacement.homeTop:
        return 'home-top';
      case AdPlacement.homeBottom:
        return 'home-bottom';
      case AdPlacement.memberDirectory:
        return 'member-directory';
      case AdPlacement.occupationDirectory:
        return 'occupation-directory';
      case AdPlacement.matrimonialDirectory:
        return 'matrimonial-directory';
      case AdPlacement.eventList:
        return 'event-list';
      case AdPlacement.eventDetail:
        return 'event-detail';
      case AdPlacement.notifications:
        return 'notifications';
      case AdPlacement.announcements:
        return 'announcements';
      case AdPlacement.other:
        return 'other';
      case AdPlacement.advertisementList:
        return 'advertisement-list';
    }
  }

  static AdPlacement fromCode(String? code) {
    if (code == null) return AdPlacement.other;
    final normalized = code.trim().toLowerCase();
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
      case 'other':
      default:
        return AdPlacement.other;
    }
  }
}
