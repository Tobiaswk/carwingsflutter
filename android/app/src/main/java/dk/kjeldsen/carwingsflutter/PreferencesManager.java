package dk.kjeldsen.carwingsflutter;

import android.content.Context;
import android.content.SharedPreferences;
import org.json.JSONException;
import org.json.JSONObject;

public class PreferencesManager {

    // https://github.com/flutter/plugins/blob/master/packages/shared_preferences/android/src/main/java/io/flutter/plugins/sharedpreferences/SharedPreferencesPlugin.java
    // Use name from Shared preferences plugin
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    private static SharedPreferences getSharedPreferences(Context context) {
        System.out.println(context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE).getAll().toString());
        return context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    }

    public static boolean getDonated(Context context) {
        return getSharedPreferences(context).getBoolean("flutter.donated", false);
    }

    public static JSONObject getLoginSettings(Context context) throws JSONException {
        return new JSONObject(getSharedPreferences(context).getString("flutter.login", null));
    }

    // Persists the vehicle nickname for Climate Control widget
    // Essentially "locks" Climate Control widget to one vehicle
    public static void setClimateControlWidgetVehicleNickname(int appWidgetId, String vehicleNickname, Context context) {
        getSharedPreferences(context).edit().putString("climateControlWidgetNickname"+appWidgetId, vehicleNickname).commit();
    }

    public static String getClimateControlWidgetVehicleNickname(int appWidgetId, Context context) {
        return getSharedPreferences(context).getString("climateControlWidgetNickname"+appWidgetId, null);
    }

    public static void setChargingControlWidgetVehicleNickname(int appWidgetId, String vehicleNickname, Context context) {
        getSharedPreferences(context).edit().putString("chargingControlWidgetNickname"+appWidgetId, vehicleNickname).commit();
    }

    public static String getChargingControlWidgetVehicleNickname(int appWidgetId, Context context) {
        return getSharedPreferences(context).getString("chargingControlWidgetNickname"+appWidgetId, null);
    }

}
