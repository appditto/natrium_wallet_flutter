package co.banano.natriumwallet;

import android.content.Context;

import com.bottlerocketstudios.vault.SharedPreferenceVault;
import com.bottlerocketstudios.vault.SharedPreferenceVaultFactory;
import com.bottlerocketstudios.vault.SharedPreferenceVaultRegistry;

import java.security.GeneralSecurityException;
import java.security.SecureRandom;

public class Vault {
    public static final String ENCRYPTION_KEY_NAME = "key";
    private static final String TAG = Vault.class.getSimpleName();
    private static final String AUTOMATICALLY_KEYED_PREF_FILE_NAME = "co.banano.natriumwallet.automaticallyKeyedPref";
    private static final String AUTOMATICALLY_KEYED_KEY_FILE_NAME = "co.banano.natriumwallet.automaticallyKeyedKey";
    private static final String AUTOMATICALLY_KEYED_KEY_ALIAS = "co.banano.natriumwallet.automaticallyKeyed";
    private static final int AUTOMATICALLY_KEYED_KEY_INDEX = 3;
    private static final String AUTOMATICALLY_KEYED_PRESHARED_SECRET = "FI>O<_BU4C,33rjUd1V[-H]7";

    public static boolean initializeVault(Context context) {
        try {
            initKeyedVault(context);
            return true;
        } catch (GeneralSecurityException e) {
        }
        return false;
    }

    /**
     * Create a vault that will automatically key itself initially with a random key.
     */
    private static void initKeyedVault(Context context) throws GeneralSecurityException {
        SharedPreferenceVault sharedPreferenceVault = SharedPreferenceVaultFactory
                .getAppKeyedCompatAes256Vault(
                        context,
                        AUTOMATICALLY_KEYED_PREF_FILE_NAME,
                        AUTOMATICALLY_KEYED_KEY_FILE_NAME,
                        AUTOMATICALLY_KEYED_KEY_ALIAS,
                        AUTOMATICALLY_KEYED_KEY_INDEX,
                        AUTOMATICALLY_KEYED_PRESHARED_SECRET
                );
        SharedPreferenceVaultRegistry
                .getInstance()
                .addVault(
                        AUTOMATICALLY_KEYED_KEY_INDEX,
                        AUTOMATICALLY_KEYED_PREF_FILE_NAME,
                        AUTOMATICALLY_KEYED_KEY_ALIAS,
                        sharedPreferenceVault
                );
    }

    /**
     * Encapsulates index knowledge.
     */
    public static SharedPreferenceVault getVault() {
        return SharedPreferenceVaultRegistry.getInstance().getVault(AUTOMATICALLY_KEYED_KEY_INDEX);
    }

    /**
     * Generate a secret key for use with encryption / decryption
     */
    public static byte[] generateKey() {
        byte[] key = new byte[64];
        new SecureRandom().nextBytes(key);
        return key;
    }

}