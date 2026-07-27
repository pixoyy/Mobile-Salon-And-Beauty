class RegisterResult {
  const RegisterResult({
    required this.isSuccess,
    this.error,
    this.fieldErrors = const {},
  });

  final bool isSuccess;
  final String? error;
  final Map<String, String> fieldErrors;

  factory RegisterResult.success() => const RegisterResult(isSuccess: true);

  factory RegisterResult.failure(
    String error, {
    Map<String, String> fieldErrors = const {},
  }) =>
      RegisterResult(
        isSuccess: false,
        error: error,
        fieldErrors: fieldErrors,
      );
}
