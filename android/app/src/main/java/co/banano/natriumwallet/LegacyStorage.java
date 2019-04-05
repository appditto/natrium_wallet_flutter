package co.banano.natriumwallet;

import android.util.Base64;

public class LegacyStorage {

    public String getSecret() {
       return generateEncryptionKey();
    }

    private String generateEncryptionKey() {
        if (Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null) == null) {
        Vault.getVault()
                .edit()
                .putString(Vault.ENCRYPTION_KEY_NAME,
                        Base64.encodeToString(Vault.generateKey(), Base64.DEFAULT))
                .apply();
        }
        return Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null);
    }
}