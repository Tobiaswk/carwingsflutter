package dk.kjeldsen.carwingsflutter;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.widget.RemoteViews;
import org.json.JSONObject;

// Implementation inspiration;
// https://stackoverflow.com/questions/14798073/button-click-event-for-android-widget
// https://stackoverflow.com/questions/17380168/update-android-widget-using-async-task-with-an-image-from-the-internet
// https://stackoverflow.com/questions/18545773/android-update-widget-from-broadcast-receiver
public class ChargingControlWidget extends ControlWidget {

    private static final String CHARGING_CONTROL_TOGGLE_CLICKED = "chargingToggleClicked";

    public class ChargingControlToggleTask extends AsyncTask<Context, Void, Context> {

        private AppWidgetManager appWidgetManager;
        private int appWidgetId;

        public ChargingControlToggleTask(AppWidgetManager appWidgetManager, int widgetId) {
            this.appWidgetManager = appWidgetManager;
            this.appWidgetId = widgetId;
        }

        @Override
        protected Context doInBackground(Context... contexts) {
            CarwingsSession carwingsSession = new CarwingsSession();
            try {
                JSONObject loginSettings = PreferencesManager.getLoginSettings(contexts[0]);
                String username = loginSettings.getString("username");
                String password = loginSettings.getString("password");
                String region = loginSettings.getString("region");

                carwingsSession.login(username, password, region);

                String vehicleName = PreferencesManager.getChargingControlWidgetVehicleNickname(appWidgetId, contexts[0]);

                carwingsSession.chargingControlOn(vehicleName);
            } catch (Exception e) {
                return contexts[0];
            }
            return contexts[0];
        }

        public void onPostExecute(Context context) {
            RemoteViews remoteViews = getRemoteViews(context, "Charging start", CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId);

            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int i = 0; i < appWidgetIds.length; i++) {
            int appWidgetId = appWidgetIds[i];

            RemoteViews remoteViews = getRemoteViews(context, "Charging start", CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId);;

            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO Auto-generated method stub
        super.onReceive(context, intent);

        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context.getApplicationContext());
        ComponentName thisWidget = new ComponentName(context.getApplicationContext(), ChargingControlWidget.class);
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);

        for (int i = 0; i < appWidgetIds.length; i++) {
            int appWidgetId = appWidgetIds[i];

            if (getAction(CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId).equals(intent.getAction())) {
                RemoteViews remoteViews = getRemoteViews(context, "Working...", CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId);

                appWidgetManager.updateAppWidget(appWidgetId, remoteViews);

                new ChargingControlToggleTask(appWidgetManager, appWidgetId).execute(context);
            }
        }
    }

}
