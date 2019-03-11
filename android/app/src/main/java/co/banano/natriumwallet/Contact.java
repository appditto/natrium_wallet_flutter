package co.banano.natriumwallet;

import android.net.Uri;

import org.json.JSONException;
import org.json.JSONObject;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;

public class Contact extends RealmObject {
    @Required
    private String name;
    @PrimaryKey
    @Required
    private String address;

    public Contact() {

    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDisplayName() {
        if (name.length() > 20) {
            return name.substring(0, 17) + "...";
        }
        return name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getAddressShort() {
        int frontStartIndex = 0;
        int frontEndIndex = 11;
        int backStartIndex = address.length() - 6;
        return address.substring(frontStartIndex, frontEndIndex) +
                "..." +
                address.substring(backStartIndex, address.length());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Contact that = (Contact) o;

        if (name != null ? !name.equals(that.name) : that.name != null) return false;
        if (address != null ? !address.equals(that.address) : that.address != null)
            return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = name != null ? name.hashCode() : 0;
        result = 31 * result + (address != null ? address.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "Contact{" +
                "name='" + name + '\'' +
                ", address='" + address +
                '}';
    }

    public JSONObject getJson() {
        JSONObject contact = new JSONObject();
        try {
            contact.put("name", name);
            contact.put("address", address);
        } catch (JSONException e) {
            return null;
        }
        return contact;
    }
}