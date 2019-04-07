package dk.kjeldsen.carwingsflutter;

import android.util.Base64;
import okhttp3.*;
import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

public class CarwingsSession {

    final String baseUrl = "https://gdcportalgw.its-mo.com/api_v190228_NE/gdc/";

    // Result of the call to InitialApp.php, which appears to
    // always be the same.  It'll probably break at some point but
    // for now... skip it.
    final String blowfishKey = "uyI5Dj9g8VCOFDnBRUbr3g";

    // Extracted from the NissanConnect EV app
    final String initialAppStrings = "geORNtsZe5I4lRGjG9GZiA";

    final OkHttpClient client = new OkHttpClient();

    String username;
    String password;
    String region;
    String gdcUserId;
    String language;
    String dcmId;
    String timeZone;

    Vehicle vehicle;
    List<Vehicle> vehicles = new ArrayList<>();

    private JSONObject requestWithRetry(String endpoint, Map<String, String> params) throws Exception {
        JSONObject response = request(endpoint, params);

        if (getStatus(response) >= 400) {
            login(username, password, region);

            response = request(endpoint, params);
        }
        return response;
    }

    private JSONObject request(String endpoint, Map<String, String> params) throws IOException, JSONException {
        final MediaType JSON
                = MediaType.get("application/json");

        params.put("initial_app_strings", initialAppStrings);

        if (vehicle != null && vehicle.customSessionID != null) {
            params.put("custom_sessionid", vehicle.customSessionID);
        } else {
            params.put("custom_sessionid", "");
        }

        System.out.println("invoking carwings API; " + endpoint);
        System.out.println("params: " + params.toString());

        FormBody.Builder requestBody = new FormBody.Builder();
        for (String key : params.keySet()) {
            requestBody.add(key, params.get(key));
        }
        Request request = new Request.Builder()
                .url(baseUrl + endpoint)
                .post(requestBody.build())
                .build();
        try (Response response = client.newCall(request).execute()) {
            String body = response.body().string();
            System.out.println("result: " + body);
            return new JSONObject(body);
        }
    }

    public List<Vehicle> login(String username, String password, String region) throws Exception {
        this.username = username;
        this.password = password;
        this.region = getRegion(region);

        String basePrm = (String) request("InitialApp.php", new HashMap() {{
            put("RegionCode", CarwingsSession.this.region);
            put("lg", "en-US");
        }}).get("baseprm");

        JSONObject response = request("UserLoginRequest.php", new HashMap() {{
            put("RegionCode", CarwingsSession.this.region);
            put("UserId", username);
            put("Password", encrypt(basePrm, password));
        }});

        if (getStatus(response) != 200) {
            throw new Exception("Login error");
        }

        language = response.getJSONObject("CustomerInfo").getString("Language");
        gdcUserId = response.getJSONObject("vehicle").getJSONObject("profile").getString("gdcUserId");
        dcmId = response.getJSONObject("vehicle").getJSONObject("profile").getString("dcmId");
        timeZone = response.getJSONObject("CustomerInfo").getString("Timezone");

        if (response.get("VehicleInfoList") != null) {
            JSONArray jsonArray = response.getJSONObject("VehicleInfoList").getJSONArray("vehicleInfo");
            for (int i = 0; i < jsonArray.length(); i++) {
                Vehicle vehicle = new Vehicle();
                vehicle.session = this;
                vehicle.customSessionID = jsonArray.getJSONObject(i).getString("custom_sessionid");
                vehicle.vin = jsonArray.getJSONObject(i).getString("vin");
                vehicle.nickname = jsonArray.getJSONObject(i).getString("nickname");
                vehicles.add(vehicle);
            }
        } else {
            JSONArray jsonArray = response.getJSONArray("vehicleInfo");
            for (int i = 0; i < jsonArray.length(); i++) {
                Vehicle vehicle = new Vehicle();
                vehicle.session = this;
                vehicle.customSessionID = jsonArray.getJSONObject(i).getString("custom_sessionid");
                vehicle.vin = jsonArray.getJSONObject(i).getString("vin");
                vehicle.nickname = jsonArray.getJSONObject(i).getString("nickname");
                vehicles.add(vehicle);
            }
        }
        vehicle = vehicles.get(0);
        return vehicles;
    }

    private int getStatus(JSONObject jsonObject) throws JSONException {
        if (jsonObject.get("status") != null) {
            return (int) jsonObject.get("status");
        }
        return -1;
    }

    private String getRegion(String region) {
        switch (region) {
            case "USA":
                return "NNA";
            case "Europe":
                return "NE";
            case "Canada":
                return "NCI";
            case "Australia":
                return "NMA";
            case "Japan":
                return "NML";
            default:
                return "NE";
        }
    }

    private String encrypt(String key, String password) throws Exception {
        byte[] KeyData = key.getBytes();
        SecretKeySpec KS = new SecretKeySpec(KeyData, "Blowfish");
        Cipher cipher = Cipher.getInstance("Blowfish");
        cipher.init(Cipher.ENCRYPT_MODE, KS);
        return Base64.encodeToString(cipher.doFinal(password.getBytes()), Base64.NO_CLOSE);
    }

    public boolean climateControlOn(String vehicleNickname) throws Exception {
        return findVehicleByNickName(vehicleNickname).climateControlOn();
    }

    public boolean climateControlOff(String vehicleNickname) throws Exception {
        return findVehicleByNickName(vehicleNickname).climateControlOff();
    }

    public boolean chargingControlOn(String vehicleNickname) throws Exception {
        return findVehicleByNickName(vehicleNickname).chargingControlOn();
    }

    private Vehicle findVehicleByNickName(String vehicleNickname) {
        for (Vehicle vehicle : vehicles) {
            if(vehicle.nickname.equals(vehicleNickname)) {
                return vehicle;
            }
        }
        return null;
    }

    public class Vehicle {
        CarwingsSession session;
        String customSessionID;
        String vin;
        String nickname;

        public boolean climateControlOn() throws Exception {
            return getStatus(session.requestWithRetry("ACRemoteUpdateRequest.php", new HashMap() {{
                put("RegionCode", session.region);
                put("lg", session.language);
                put("DCMID", session.dcmId);
                put("VIN", vin);
                put("tz", session.timeZone);
                put("ExecuteTime", new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new DateTime().withZone(DateTimeZone.UTC).toLocalDateTime().toDate()));
            }})) == 200;
        }

        public boolean climateControlOff() throws Exception {
            return getStatus(session.requestWithRetry("ACRemoteOffRequest.php", new HashMap() {{
                put("RegionCode", session.region);
                put("lg", session.language);
                put("DCMID", session.dcmId);
                put("VIN", vin);
                put("tz", session.timeZone);
            }})) == 200;
        }

        public boolean chargingControlOn() throws Exception {
            return getStatus(session.requestWithRetry("BatteryRemoteChargingRequest.php", new HashMap() {{
                put("RegionCode", session.region);
                put("lg", session.language);
                put("DCMID", session.dcmId);
                put("VIN", vin);
                put("tz", session.timeZone);
                put("ExecuteTime", new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new DateTime().withZone(DateTimeZone.UTC).toLocalDateTime().toDate()));
            }})) == 200;
        }
    }

}
