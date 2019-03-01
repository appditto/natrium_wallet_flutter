package co.banano.natriumwallet;

import android.support.annotation.NonNull;
import android.util.Base64;

import io.realm.DynamicRealm;
import io.realm.FieldAttribute;
import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmMigration;
import io.realm.RealmSchema;
import io.realm.exceptions.RealmFileException;

public class RealmUtil {
    private static final int SCHEMA_VERSION = 1;
    private static final String DB_NAME = "natrium.realm";

    public Realm getRealmInstance() {
        byte[] key = getEncryptionKey();
        try {
            RealmConfiguration realmConfiguration = new RealmConfiguration.Builder()
                    .name(DB_NAME)
                    .encryptionKey(key)
                    .schemaVersion(SCHEMA_VERSION)
                    .migration(new Migration())
                    .build();

            Realm.setDefaultConfiguration(realmConfiguration);
            // Open the Realm with encryption enabled
            return Realm.getInstance(realmConfiguration);
        } catch (RealmFileException e) {
            // regenerate key and open realm with new key
            Vault.getVault()
                    .edit()
                    .putString(Vault.ENCRYPTION_KEY_NAME,
                            Base64.encodeToString(Vault.generateKey(), Base64.DEFAULT))
                    .apply();

            RealmConfiguration realmConfiguration = new RealmConfiguration.Builder()
                    .name(DB_NAME)
                    .encryptionKey(Base64.decode(Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null), Base64.DEFAULT))
                    .schemaVersion(SCHEMA_VERSION)
                    .migration(new Migration())
                    .build();

            Realm.setDefaultConfiguration(realmConfiguration);
            Realm.deleteRealm(realmConfiguration);

            return Realm.getInstance(realmConfiguration);
        }
    }

    private byte[] getEncryptionKey() {
        if (Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null) == null) {
            Vault.getVault()
                    .edit()
                    .putString(Vault.ENCRYPTION_KEY_NAME,
                            Base64.encodeToString(Vault.generateKey(), Base64.DEFAULT))
                    .apply();
        }
        if (Vault.getVault() != null && Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null) != null) {
            return Base64.decode(Vault.getVault().getString(Vault.ENCRYPTION_KEY_NAME, null), Base64.DEFAULT);
        } else {
            return Vault.generateKey();
        }
    }
}

class Migration implements RealmMigration {

    @Override
    public void migrate(@NonNull DynamicRealm realm, long oldVersion, long newVersion) {
        RealmSchema schema = realm.getSchema();
    }

    @Override
    public int hashCode() {
        return 37;
    }

    @Override
    public boolean equals(Object o) {
        return (o instanceof RealmMigration);
    }

}
