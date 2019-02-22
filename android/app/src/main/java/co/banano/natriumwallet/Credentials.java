package co.banano.natriumwallet;

import java.util.Arrays;
import java.util.List;

import io.realm.RealmObject;

/**
 * Wallet seed used to store in Realm
 */

public class Credentials extends RealmObject {
    public static final List<Character> VALID_SEED_CHARACTERS = Arrays.asList('a', 'b', 'c', 'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
    private String seed;
    private String privateKey;
    private String uuid;
    private String pin;
    private Boolean seedIsSecure;
    private String newlyGeneratedSeed;
    private Boolean hasSentToNewSeed;

    public Credentials() {
    }

    public static boolean isValidSeed(String seed) {
        if (seed.length() != 64) {
            return false;
        }
        boolean isMatch = true;
        for (int i = 0; i < seed.length() && isMatch; i++) {
            char letter = seed.toLowerCase().charAt(i);
            if (!VALID_SEED_CHARACTERS.contains(letter)) {
                isMatch = false;
            }
        }
        return isMatch;
    }

    public String getSeed() {
        return seed;
    }

    public void setSeed(String seed) {
        this.seed = seed;
    }

    public String getPrivateKey() {
        return privateKey;
    }

    public void setPrivateKey(String privateKey) {
        this.privateKey = privateKey;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getPin() {
        return pin;
    }

    public void setPin(String pin) {
        this.pin = pin;
    }

    public Boolean getSeedIsSecure() {
        return seedIsSecure == null ? false : seedIsSecure;
    }

    public void setSeedIsSecure(Boolean seedIsSecure) {
        this.seedIsSecure = seedIsSecure;
    }

    public String getNewlyGeneratedSeed() {
        return newlyGeneratedSeed;
    }

    public void setNewlyGeneratedSeed(String newlyGeneratedSeed) {
        this.newlyGeneratedSeed = newlyGeneratedSeed;
    }

    public Boolean getHasSentToNewSeed() {
        return hasSentToNewSeed == null ? false : hasSentToNewSeed;
    }

    // Generated fields

    public void setHasSentToNewSeed(Boolean hasSentToNewSeed) {
        this.hasSentToNewSeed = hasSentToNewSeed;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Credentials that = (Credentials) o;

        if (seed != null ? !seed.equals(that.seed) : that.seed != null) return false;
        if (privateKey != null ? !privateKey.equals(that.privateKey) : that.privateKey != null)
            return false;
        if (uuid != null ? !uuid.equals(that.uuid) : that.uuid != null) return false;
        if (pin != null ? !pin.equals(that.pin) : that.pin != null) return false;
        if (seedIsSecure != null ? !seedIsSecure.equals(that.seedIsSecure) : that.seedIsSecure != null)
            return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = seed != null ? seed.hashCode() : 0;
        result = 31 * result + (privateKey != null ? privateKey.hashCode() : 0);
        result = 31 * result + (uuid != null ? uuid.hashCode() : 0);
        result = 31 * result + (pin != null ? pin.hashCode() : 0);
        result = 31 * result + (seedIsSecure != null ? seedIsSecure.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "Credentials{" +
                "seed='" + seed + '\'' +
                ", privateKey='" + privateKey + '\'' +
                ", uuid='" + uuid + '\'' +
                ", pin='" + pin + '\'' +
                ", seedIsSecure=" + seedIsSecure +
                '}';
    }
}