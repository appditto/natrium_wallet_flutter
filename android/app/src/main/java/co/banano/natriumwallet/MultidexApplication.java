// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package co.banano.natriumwallet;

import android.util.Base64;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.CallSuper;
import android.content.Context;
import androidx.multidex.MultiDex;

import io.flutter.view.FlutterMain;

/**
 * Flutter implementation of {@link android.app.Application}, managing
 * application-level global initializations.
 */
public class MultidexApplication extends Application {
    @Override
    protected void attachBaseContext(Context base) {
       super.attachBaseContext(base);
       MultiDex.install(this);
    }

    @Override
    @CallSuper
    public void onCreate() {
        super.onCreate();

        try {
            Vault.initializeVault(this);
            generateEncryptionKey();
        } catch (Exception e) {
    
        }
        FlutterMain.startInitialization(this);
    }

    private Activity mCurrentActivity = null;
    public Activity getCurrentActivity() {
        return mCurrentActivity;
    }
    public void setCurrentActivity(Activity mCurrentActivity) {
        this.mCurrentActivity = mCurrentActivity;
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