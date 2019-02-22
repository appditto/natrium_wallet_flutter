package co.banano.natriumwallet;

import android.os.Bundle;
import android.util.Base64;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.realm.Realm;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "fappchannel";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Realm.init(this);

    Vault.initializeVault(this);
    generateEncryptionKey();

    GeneratedPluginRegistrant.registerWith(this);

      new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
          new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                  if (call.method.equals("getLegacySeed")) {
                      result.success(new MigrationStuff().getLegacySeed());
                  } else if (call.method.equals("getLegacyContacts")) {
                      result.success(new MigrationStuff().getLegacyContactsAsJson());
                  } else if (call.method.equals("clearLegacyData")) {
                      new MigrationStuff().clearLegacyData();
                  } else if (call.method.equals("getLegacyPin")) {
                      result.success(new MigrationStuff().getLegacyPin());
                  } else {
                      result.notImplemented();
                  }
              }
          }
     );
  }

  /**
   * generate an encryption key and store in the vault
   */
  private void generateEncryptionKey() {
    if (Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null) == null) {
      Vault.getVault()
              .edit()
              .putString(Vault.ENCRYPTION_KEY_NAME,
                      Base64.encodeToString(Vault.generateKey(), Base64.DEFAULT))
              .apply();
    }
  }
}
