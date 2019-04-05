package co.banano.natriumwallet;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "fappchannel";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

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
}
