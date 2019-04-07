package dk.kjeldsen.carwingsflutter;

import android.content.Context;

public class ClimateControlConfigWidget extends ConfigWidgetActivity {

    @Override
    public void setPreferencesWidget(int appWidgetId, String vehicleNickname, Context context) {
        PreferencesManager.setClimateControlWidgetVehicleNickname(appWidgetId, vehicleNickname, context);
    }
}
