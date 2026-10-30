# Library Feature - Static Text Keywords & Localization Keys

Complete list of all static text strings, recommended localization keys (`LK`), descriptions, and ready-to-use JSON formats for the entire **Library Feature**.

---

## 1. Quick Summary Table by Module

| # | Screen / Component | Suggested Key Prefix | Keywords Count |
|---|--------------------|----------------------|:--------------:|
| 1 | Categories Page & Category Card | `library_cat_` | 4 |
| 2 | Items Listing & Item Card & Search | `library_item_` | 5 |
| 3 | Audio Player Screen | `library_audio_` | 15 |
| 4 | Video Player Screen | `library_video_` | 17 |
| 5 | PDF Viewer Screen | `library_pdf_` | 8 |
| 6 | Text Document Viewer Screen | `library_text_` | 11 |
| 7 | Image Viewer Screen | `library_image_` | 4 |
| 8 | Download & Share Sheet | `library_sheet_` | 8 |
| 9 | Controller Alerts & Messages | `library_alert_` | 8 |

---

## 2. Detailed Keywords Specification

### 1. Categories Page & Card
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_categories_title` | `"Library"` | AppBar Title | Title |
| `library_search_categories_hint` | `"Search categories..."` | Category Search Bar | Placeholder |
| `library_no_categories_found` | `"No categories found"` | Empty State View | Empty State |
| `library_category_items_suffix` | `"Items"` | Category Card Count Badge | Label |

---

### 2. Items Listing Page & Card
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_items_fallback_title` | `"Library Items"` | AppBar Fallback Title | Title |
| `library_search_items_hint` | `"Search items..."` | Item Search Bar | Placeholder |
| `library_no_items_found` | `"No items found"` | Empty State View | Empty State |
| `library_failed_to_load_more` | `"Failed to load more. Tap to retry"` | Pagination Error Button | Action / Error |
| `library_item_type_fallback` | `"FILE"` | Card Badge Fallback | Badge |

---

### 3. Audio Player Screen
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_audio_loading_title` | `"Audio loading"` | Connecting Snackbar Title | Snackbar Title |
| `library_audio_loading_msg` | `"Please wait, connecting to audio stream..."` | Connecting Snackbar Subtitle | Snackbar Message |
| `library_audio_badge_fallback` | `"MP3"` | Header Badge Fallback | Badge |
| `library_audio_desc_fallback` | `"Audio content"` | Fallback Description | Description |
| `library_audio_track_prefix` | `"Track"` | Track Meta Counter | Label |
| `library_audio_track_of` | `"of"` | Track Meta Counter (`Track X of Y`) | Label |
| `library_audio_muted_badge` | `"MUTED"` | Audio Player Indicator | Badge |
| `library_audio_about_heading` | `"About this audio"` | Section Heading | Heading |
| `library_audio_tracks_heading` | `"Audio Tracks"` | Playlist Section Heading | Heading |
| `library_audio_tap_to_switch` | `"Tap to switch"` | Playlist Sub-label | Label |
| `library_audio_track_title_fallback` | `"Track"` | Track Item Fallback (`Track X`) | Label |
| `library_audio_playing_badge` | `"PLAYING"` | Active Track Badge | Badge |
| `library_audio_selected_badge` | `"SELECTED"` | Active Track Badge | Badge |
| `library_audio_file_fallback` | `"Audio file"` | Single File Card Title Fallback | Label |

---

### 4. Video Player Screen
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_video_muted_title` | `"Muted"` | Audio Toggle Snackbar Title | Snackbar Title |
| `library_video_unmuted_title` | `"Unmuted"` | Audio Toggle Snackbar Title | Snackbar Title |
| `library_video_muted_msg` | `"Video sound is muted."` | Audio Toggle Snackbar Subtitle | Snackbar Message |
| `library_video_unmuted_msg` | `"Video sound is restored."` | Audio Toggle Snackbar Subtitle | Snackbar Message |
| `library_video_desc_fallback` | `"Video content"` | Fallback Description | Description |
| `library_video_collection_heading` | `"Videos in this collection"` | Playlist Section Heading | Heading |
| `library_video_tap_to_play` | `"Tap to play"` | Playlist Sub-label | Label |
| `library_video_item_fallback` | `"Video"` | Episode Item Fallback (`Video X`) | Label |
| `library_video_playing_badge` | `"PLAYING"` | Active Video Badge | Badge |
| `library_video_file_fallback` | `"Video file"` | Single File Card Title Fallback | Label |
| `library_video_unavailable_stream` | `"No playable video stream available"` | Video Surface Error | Empty State |
| `library_video_about_heading` | `"About this video"` | Section Heading | Heading |
| `library_video_open_youtube` | `"Open original on YouTube"` | YouTube External Action Button | Button |
| `library_video_related_heading` | `"Related Videos"` | Section Heading | Heading |

---

### 5. PDF Viewer Screen
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_pdf_dropdown_fallback` | `"Document"` | Dropdown Item Fallback (`Document X`) | Label |
| `library_pdf_pages_tag` | `"pages"` | Dropdown Page Count Tag | Label |
| `library_pdf_loading` | `"Loading PDF document..."` | Loading Placeholder | Loading State |
| `library_pdf_not_available` | `"PDF document not available"` | Unavailable State Placeholder | Empty State |
| `library_pdf_dialog_title` | `"Go to Page"` | Jump-to-Page Dialog Title | Dialog Title |
| `library_pdf_dialog_hint` | `"Enter page number"` | Jump-to-Page Input Hint | Dialog Hint |
| `library_pdf_dialog_cancel` | `"Cancel"` | Dialog Action Button | Dialog Action |
| `library_pdf_dialog_go` | `"Go"` | Dialog Action Button | Dialog Action |

---

### 6. Text Document Viewer Screen
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_text_copied_title` | `"Copied to clipboard"` | Copy Action Snackbar Title | Snackbar Title |
| `library_text_copied_msg` | `"Text copied successfully."` | Copy Action Snackbar Subtitle | Snackbar Message |
| `library_text_badge_fallback` | `"TEXT"` | Header Badge Fallback | Badge |
| `library_text_empty_content` | `"No text content available."` | Content Body Placeholder | Empty State |
| `library_text_part_fallback` | `"Part"` | Section Tab Fallback (`Part X`) | Label |
| `library_text_meaning_heading` | `"Meaning / Translation"` | Section Heading | Heading |
| `library_text_attachments_heading`| `"Files & Attachments"` | Attachment Section Heading | Heading |
| `library_text_attachment_fallback` | `"Attachment"` | Attachment Name Fallback | Label |
| `library_text_font_pt` | `"pt"` | Font Size Unit Label (`Xpt`) | Label |

---

### 7. Image Viewer Screen
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_image_fallback_title` | `"Image Viewer"` | AppBar Fallback Title | Title |
| `library_image_not_available` | `"No image available"` | Empty State View | Empty State |
| `library_image_item_fallback` | `"Image"` | Fallback Image Tag (`Image #X`) | Label |

---

### 8. Download & Share Options Sheet
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_sheet_download_title` | `"Download"` | Sheet Option Title | Button / Tile |
| `library_sheet_download_sub` | `"Save to your device"` | Sheet Option Subtitle | Label |
| `library_sheet_browser_title` | `"Open in new tab"` | Sheet Option Title | Button / Tile |
| `library_sheet_browser_sub` | `"View in browser"` | Sheet Option Subtitle | Label |
| `library_sheet_share_title` | `"Share"` | Sheet Option Title | Button / Tile |
| `library_sheet_share_sub` | `"Share with others"` | Sheet Option Subtitle | Label |
| `library_sheet_cancel` | `"Cancel"` | Sheet Cancel Button | Button |
| `library_sheet_file_fallback` | `"File"` | Fallback File Type Label | Label |

---

### 9. Controller / Network / Alert Messages
| Suggested Key | Static Text Value | UI Location | Type |
|---|---|---|---|
| `library_err_load_categories` | `"Failed to load categories"` | Error Message Fallback | Error |
| `library_err_load_items` | `"Failed to load items"` | Error Message Fallback | Error |
| `library_err_load_details` | `"Failed to load details"` | Error Message Fallback | Error |
| `library_alert_download_failed` | `"Download Failed"` | Snackbar Title | Alert Title |
| `library_alert_no_download_url` | `"No download URL available for this item."` | Snackbar Subtitle | Alert Message |
| `library_alert_download_success` | `"Downloaded successfully"` | Snackbar Title | Alert Title |
| `library_alert_download_error` | `"Download Error"` | Snackbar Title | Alert Title |
| `library_alert_unable_open_link` | `"Unable to open link"` | Snackbar Title | Alert Title |
| `library_alert_could_not_launch` | `"Could not launch URL in external browser."` | Snackbar Subtitle | Alert Message |
| `library_alert_could_not_open_browser` | `"Could not open browser"` | Snackbar Title | Alert Title |

---

## 3. Ready-To-Paste Dart Code (`translation_keys.dart` / `LK` class)

```dart
  // ==================== LIBRARY FEATURE ====================
  // Categories & Listing
  static const String libraryCategoriesTitle = 'Library';
  static const String librarySearchCategoriesHint = 'Search categories...';
  static const String libraryNoCategoriesFound = 'No categories found';
  static const String libraryCategoryItemsSuffix = 'Items';
  static const String libraryItemsFallbackTitle = 'Library Items';
  static const String librarySearchItemsHint = 'Search items...';
  static const String libraryNoItemsFound = 'No items found';
  static const String libraryFailedToLoadMore = 'Failed to load more. Tap to retry';
  static const String libraryItemTypeFallback = 'FILE';

  // Audio Player
  static const String libraryAudioLoadingTitle = 'Audio loading';
  static const String libraryAudioLoadingMsg = 'Please wait, connecting to audio stream...';
  static const String libraryAudioBadgeFallback = 'MP3';
  static const String libraryAudioDescFallback = 'Audio content';
  static const String libraryAudioTrackPrefix = 'Track';
  static const String libraryAudioTrackOf = 'of';
  static const String libraryAudioMutedBadge = 'MUTED';
  static const String libraryAudioAboutHeading = 'About this audio';
  static const String libraryAudioTracksHeading = 'Audio Tracks';
  static const String libraryAudioTapToSwitch = 'Tap to switch';
  static const String libraryAudioPlayingBadge = 'PLAYING';
  static const String libraryAudioSelectedBadge = 'SELECTED';
  static const String libraryAudioFileFallback = 'Audio file';

  // Video Player
  static const String libraryVideoMutedTitle = 'Muted';
  static const String libraryVideoUnmutedTitle = 'Unmuted';
  static const String libraryVideoMutedMsg = 'Video sound is muted.';
  static const String libraryVideoUnmutedMsg = 'Video sound is restored.';
  static const String libraryVideoDescFallback = 'Video content';
  static const String libraryVideoCollectionHeading = 'Videos in this collection';
  static const String libraryVideoTapToPlay = 'Tap to play';
  static const String libraryVideoItemFallback = 'Video';
  static const String libraryVideoPlayingBadge = 'PLAYING';
  static const String libraryVideoFileFallback = 'Video file';
  static const String libraryVideoUnavailableStream = 'No playable video stream available';
  static const String libraryVideoAboutHeading = 'About this video';
  static const String libraryVideoOpenYoutube = 'Open original on YouTube';
  static const String libraryVideoRelatedHeading = 'Related Videos';

  // PDF Viewer
  static const String libraryPdfDropdownFallback = 'Document';
  static const String libraryPdfPagesTag = 'pages';
  static const String libraryPdfLoading = 'Loading PDF document...';
  static const String libraryPdfNotAvailable = 'PDF document not available';
  static const String libraryPdfDialogTitle = 'Go to Page';
  static const String libraryPdfDialogHint = 'Enter page number';
  static const String libraryPdfDialogCancel = 'Cancel';
  static const String libraryPdfDialogGo = 'Go';

  // Text Document Viewer
  static const String libraryTextCopiedTitle = 'Copied to clipboard';
  static const String libraryTextCopiedMsg = 'Text copied successfully.';
  static const String libraryTextBadgeFallback = 'TEXT';
  static const String libraryTextEmptyContent = 'No text content available.';
  static const String libraryTextPartFallback = 'Part';
  static const String libraryTextMeaningHeading = 'Meaning / Translation';
  static const String libraryTextAttachmentsHeading = 'Files & Attachments';
  static const String libraryTextAttachmentFallback = 'Attachment';

  // Image Viewer
  static const String libraryImageFallbackTitle = 'Image Viewer';
  static const String libraryImageNotAvailable = 'No image available';
  static const String libraryImageItemFallback = 'Image';

  // Download & Share Sheet
  static const String librarySheetDownloadTitle = 'Download';
  static const String librarySheetDownloadSub = 'Save to your device';
  static const String librarySheetBrowserTitle = 'Open in new tab';
  static const String librarySheetBrowserSub = 'View in browser';
  static const String librarySheetShareTitle = 'Share';
  static const String librarySheetShareSub = 'Share with others';
  static const String librarySheetCancel = 'Cancel';
  static const String librarySheetFileFallback = 'File';

  // Alerts & Messages
  static const String libraryErrLoadCategories = 'Failed to load categories';
  static const String libraryErrLoadItems = 'Failed to load items';
  static const String libraryErrLoadDetails = 'Failed to load details';
  static const String libraryAlertDownloadFailed = 'Download Failed';
  static const String libraryAlertNoDownloadUrl = 'No download URL available for this item.';
  static const String libraryAlertDownloadSuccess = 'Downloaded successfully';
  static const String libraryAlertDownloadError = 'Download Error';
  static const String libraryAlertUnableOpenLink = 'Unable to open link';
  static const String libraryAlertCouldNotLaunch = 'Could not launch URL in external browser.';
  static const String libraryAlertCouldNotOpenBrowser = 'Could not open browser';
```

---

## 4. Ready-To-Paste JSON Format (`en.json`)

```json
{
  "library_categories_title": "Library",
  "library_search_categories_hint": "Search categories...",
  "library_no_categories_found": "No categories found",
  "library_category_items_suffix": "Items",
  "library_items_fallback_title": "Library Items",
  "library_search_items_hint": "Search items...",
  "library_no_items_found": "No items found",
  "library_failed_to_load_more": "Failed to load more. Tap to retry",
  "library_item_type_fallback": "FILE",
  "library_audio_loading_title": "Audio loading",
  "library_audio_loading_msg": "Please wait, connecting to audio stream...",
  "library_audio_badge_fallback": "MP3",
  "library_audio_desc_fallback": "Audio content",
  "library_audio_track_prefix": "Track",
  "library_audio_track_of": "of",
  "library_audio_muted_badge": "MUTED",
  "library_audio_about_heading": "About this audio",
  "library_audio_tracks_heading": "Audio Tracks",
  "library_audio_tap_to_switch": "Tap to switch",
  "library_audio_playing_badge": "PLAYING",
  "library_audio_selected_badge": "SELECTED",
  "library_audio_file_fallback": "Audio file",
  "library_video_muted_title": "Muted",
  "library_video_unmuted_title": "Unmuted",
  "library_video_muted_msg": "Video sound is muted.",
  "library_video_unmuted_msg": "Video sound is restored.",
  "library_video_desc_fallback": "Video content",
  "library_video_collection_heading": "Videos in this collection",
  "library_video_tap_to_play": "Tap to play",
  "library_video_item_fallback": "Video",
  "library_video_playing_badge": "PLAYING",
  "library_video_file_fallback": "Video file",
  "library_video_unavailable_stream": "No playable video stream available",
  "library_video_about_heading": "About this video",
  "library_video_open_youtube": "Open original on YouTube",
  "library_video_related_heading": "Related Videos",
  "library_pdf_dropdown_fallback": "Document",
  "library_pdf_pages_tag": "pages",
  "library_pdf_loading": "Loading PDF document...",
  "library_pdf_not_available": "PDF document not available",
  "library_pdf_dialog_title": "Go to Page",
  "library_pdf_dialog_hint": "Enter page number",
  "library_pdf_dialog_cancel": "Cancel",
  "library_pdf_dialog_go": "Go",
  "library_text_copied_title": "Copied to clipboard",
  "library_text_copied_msg": "Text copied successfully.",
  "library_text_badge_fallback": "TEXT",
  "library_text_empty_content": "No text content available.",
  "library_text_part_fallback": "Part",
  "library_text_meaning_heading": "Meaning / Translation",
  "library_text_attachments_heading": "Files & Attachments",
  "library_text_attachment_fallback": "Attachment",
  "library_image_fallback_title": "Image Viewer",
  "library_image_not_available": "No image available",
  "library_image_item_fallback": "Image",
  "library_sheet_download_title": "Download",
  "library_sheet_download_sub": "Save to your device",
  "library_sheet_browser_title": "Open in new tab",
  "library_sheet_browser_sub": "View in browser",
  "library_sheet_share_title": "Share",
  "library_sheet_share_sub": "Share with others",
  "library_sheet_cancel": "Cancel",
  "library_sheet_file_fallback": "File",
  "library_err_load_categories": "Failed to load categories",
  "library_err_load_items": "Failed to load items",
  "library_err_load_details": "Failed to load details",
  "library_alert_download_failed": "Download Failed",
  "library_alert_no_download_url": "No download URL available for this item.",
  "library_alert_download_success": "Downloaded successfully",
  "library_alert_download_error": "Download Error",
  "library_alert_unable_open_link": "Unable to open link",
  "library_alert_could_not_launch": "Could not launch URL in external browser.",
  "library_alert_could_not_open_browser": "Could not open browser"
}
```
