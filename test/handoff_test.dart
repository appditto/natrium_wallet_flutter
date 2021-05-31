import 'package:flutter_test/flutter_test.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_channels.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_spec.dart';

void main() {
  group('handoff specification', () {
    test('specification decoding', _testSpecDecode);
  });
}

void _testSpecDecode() {
  var testData = 'eyJpZCI6ImEyYjI0YzhhLTNjMmEtNGVjNC1hNTJlLTEyMGQwMjhlNjU0YSIsImQiOiJuYW5vXzM4cmt4ZGM2ZHI0d2FwOWthbXN1N2s4Y3F5OGJqMW91Z3J4OGZpZnd1emV5ZHpjaDlkdGNtdDY2bXJjYyIsImEiOiIxMjM0MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAiLCJjIjp7Imh0dHBzIjp7InVybCI6ImV4YW1wbGUuY29tL2hhbmRvZmYifSwidW5rbm93biI6eyJzb21ldmFsIjoyfX0sIndrIjpmYWxzZSwidmEiOnRydWUsInJlIjp0cnVlfQ';
  HandoffPaymentSpec spec = HandoffPaymentSpec.fromBase64(testData);

  expect(spec.paymentId, 'a2b24c8a-3c2a-4ec4-a52e-120d028e654a');
  expect(spec.destinationAddress, 'nano_38rkxdc6dr4wap9kamsu7k8cqy8bj1ougrx8fifwuzeydzch9dtcmt66mrcc');
  expect(spec.amount.toString(), '123400000000000000000000000000');
  expect(spec.channels.length, 2);
  var httpsChannel = spec.getChannel(HandoffChannel.https);
  expect(httpsChannel, isNotNull);
  expect((httpsChannel as HttpsChannelProcessor).url.toString(),
      'https://example.com/handoff');
  expect(spec.variableAmount, true);
  expect(spec.requiresWork, false);
  expect(spec.reusable, true);
}



