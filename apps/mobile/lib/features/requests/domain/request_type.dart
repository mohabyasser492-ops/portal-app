/// Identifies the type of an employee request.
///
/// These values belong to the frontend domain layer. A future API repository
/// will map backend response values into this enum after the shared API
/// contract becomes available.
enum RequestType {
  leave,
  employmentLetter,
  salaryCertificate,
  profileUpdate,
  payrollInquiry,
  generalInquiry,
}
