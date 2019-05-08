import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nano_core/flutter_nano_core.dart';

void main() {
  test('test seed to private key', () {
    expect(NanoKeys.seedToPrivate('E11A48D701EA1F8A66A4EB587CDC8808D726FE75B325DF204F62CA2B43F9ADA1', 0), '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
    expect(NanoKeys.seedToPrivate('E11A48D701EA1F8A66A4EB587CDC8808D726FE75B325DF204F62CA2B43F9ADA1', 1), '22EDDBF0D72E9A4232C3FE6689A6CB0A228C9ED822715A63E2F8644AA2C905A4');
  });

  test('test address from seed', () {
    var privKey = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
    expect(NanoAccounts.createAccount(NanoAccountType.BANANO, 
                                      NanoKeys.createPublicKey(privKey)),
          'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc');
    expect(NanoAccounts.createAccount(NanoAccountType.NANO, 
                                      NanoKeys.createPublicKey(privKey)),
          'nano_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc');
  });

  test('test hex to byte array and back', () {
    var hex = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
    var byteArray = NanoHelpers.hexToBytes('67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
    expect(NanoHelpers.byteToHex(byteArray), hex);
  });

  test('test hex to binary and back', () {
    var hex = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
    var binary = NanoHelpers.hexToBinary('67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
    expect(NanoHelpers.binaryToHex(binary), hex);
  });

  test('test bigint to byte and back', () {
    var raw = BigInt.parse('1000000000000000000000000000000');
    var byteRaw = NanoHelpers.bigIntToBytes(raw);
    expect(NanoHelpers.byteToBigInt(byteRaw), raw);
  });
  test('test address validation', () {
    // Three valid accounts
    expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
    expect(NanoAccounts.isValid(NanoAccountType.NANO, 'xrb_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
    expect(NanoAccounts.isValid(NanoAccountType.NANO, 'nano_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
    // Invalid checksum
    expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_3zzzzzzzzzzzhw11111111111111111111111111111111111111spcronyu'), false);
    // Too short of length
    expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkg'), false);
    // Invalid prefix
    expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'xrb_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), false);
  });

  test('test state block hash computation', () {
    // open state block
    var accountType = NanoAccountType.NANO;
    var account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
    var previous = '0';
    var representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
    var balance = BigInt.parse('1');
    var link = '1EF0AD02257987B48030CC8D38511D3B2511672F33AF115AD09E18A86A8355A8';
    var calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
    expect(calculatedHash,
          'FC5A7FB777110A858052468D448B2DF22B648943C097C0608D1E2341007438B0');
    // receive state block
    account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
    previous = 'FC5A7FB777110A858052468D448B2DF22B648943C097C0608D1E2341007438B0';
    representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
    balance = BigInt.parse('5000000000000000000000000000001');
    link = 'B2EC73C1F503F47E051AD72ECB512C63BA8E1A0ACC2CEE4EA9A22FE1CBDB693F';
    calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
    expect(calculatedHash,
          '597395E83BD04DF8EF30AF04234EAAFE0606A883CF4AEAD2DB8196AAF5C4444F');
    // send state block
    account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
    previous = '597395E83BD04DF8EF30AF04234EAAFE0606A883CF4AEAD2DB8196AAF5C4444F';
    representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
    balance = BigInt.parse('3000000000000000000000000000001');
    link = 'xrb_1q3hqecaw15cjt7thbtxu3pbzr1eihtzzpzxguoc37bj1wc5ffoh7w74gi6p';
    calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
    expect(calculatedHash,
          '128106287002E595F479ACD615C818117FCB3860EC112670557A2467386249D4');
    // change state block
    account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
    previous = '128106287002E595F479ACD615C818117FCB3860EC112670557A2467386249D4';
    representative = 'xrb_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs';
    balance = BigInt.parse('3000000000000000000000000000001');
    link = '0000000000000000000000000000000000000000000000000000000000000000';
    calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
    expect(calculatedHash,
          '2A322FD5ACAF50C057A8CF5200A000CF1193494C79C786B579E0B4A7D10E5A1E');
  });

  test('test block signature', () {
    var privKey = '9F0E444C69F77A49BD0BE89DB92C38FE713E0963165CCA12FAF5712D7657120F';
    var hash = 'AEC75F807DCE45AFA787DE7B395BE498A885525569DD614162E0C80FD4F27EE9';

    String signature = NanoSignatures.signBlock(hash, privKey);

    expect(signature,
          '1123C926EF53B0FFA3585D5F6FA17D05B2AAD486D28CBEED88837B83265F264CBAF3FEA78AF80AAB4C59740546B220ADBE207F6B800FFE864E0934E9C1078401');
  });
}
