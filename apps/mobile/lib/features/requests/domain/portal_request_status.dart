/// Represents the current lifecycle status of a Portal request.
///
/// These frontend domain values do not assume how the backend represents
/// request statuses in JSON.
enum PortalRequestStatus { draft, submitted, inReview, approved, rejected, cancelled }
