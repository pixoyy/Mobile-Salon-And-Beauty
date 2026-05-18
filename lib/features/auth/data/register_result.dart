class RegisterResult {
  const RegisterResult({
    required this.isSuccess,
    this.error,
  });

  final bool isSuccess;
  final String? error;

  factory RegisterResult.success() => const RegisterResult(isSuccess: true);

  factory RegisterResult.failure(String error) =>
      RegisterResult(isSuccess: false, error: error);
}
