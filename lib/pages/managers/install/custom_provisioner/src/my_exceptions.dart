/// Generic EspSmartconfig exception
abstract class MyEspSmartConfigException implements Exception {
  /// Message
  final String? message;

  MyEspSmartConfigException(this.message);

  @override
  String toString() => message ?? super.toString();
}

/// Generic provisioning exception
class MyProvisioningException extends MyEspSmartConfigException {
  MyProvisioningException([super.message]);
}

/// Error that will be thrown on try to add response
/// that already exists in the list of protocol responses
class MyProvisioningResponseAlreadyReceivedError
    extends MyProvisioningException {
  MyProvisioningResponseAlreadyReceivedError([super.message]);
}

/// Invalid provisioning reponse exception
class MyInvalidProvisioningResponseDataException
    extends MyProvisioningException {
  MyInvalidProvisioningResponseDataException([super.message]);
}
