package dk.kjeldsen.carwingsflutter;

import android.content.Context;

public class ChargingControlConfigWidget extends ConfigWidgetActivity {

    @Override
    public void setPreferencesWidget(int appWidgetId, String vehicleNickname, Context context) {
        PreferencesManager.setChargingControlWidgetVehicleNickname(appWidgetId, vehicleNickname, context);
    }
}
