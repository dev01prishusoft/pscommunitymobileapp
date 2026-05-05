/// ─────────────────────────────────────────────────────────────────────────────
/// UI Review Mode flag
///
/// Set [kUiReviewMode] to `true` to bypass all form validation and API calls
/// so you can walk through the entire app flow without credentials.
///
/// ⚠️  MUST be `false` before any production / staging build.
/// ─────────────────────────────────────────────────────────────────────────────
const bool kUiReviewMode = bool.fromEnvironment(
  'UI_REVIEW_MODE',
  defaultValue: true,
);
