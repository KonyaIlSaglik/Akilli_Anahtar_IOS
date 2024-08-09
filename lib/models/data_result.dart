// ignore_for_file: public_member_api_docs, sort_constructors_first
class DataResult<T> {
  T? data;
  bool success;
  String message;
  DataResult({
    this.data,
    this.success = false,
    this.message = "",
  });
}
