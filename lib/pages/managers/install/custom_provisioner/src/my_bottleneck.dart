import '../my_protocol.dart';

/// Bottlenecker
class MyBottleneck {
  /// Tightness in milliseconds
  late int _tightness;
  int _timeOfPreviousPass = 0;

  /// Constructor of [Bottleneck] with desired [tightness] in milliseconds
  MyBottleneck(int tightness) {
    _tightness = tightness;
  }

  /// Pass the function through the bottleneck
  void flow(Function fn) {
    final ms = MyProtocol.ms();

    if (_tightness > ms - _timeOfPreviousPass) {
      return;
    }

    fn();
    _timeOfPreviousPass = ms;
  }
}
