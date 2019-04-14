package dk.kjeldsen.carwingsflutter;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
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
public class ChargingControlWidget extends AppWidgetProvider {

    private static final String CHARGING_CONTROL_TOGGLE_CLICKED = "chargingToggleClicked";

    public class ChargingControlToggleTask extends AsyncTask<Context, Void, Void> {

        private RemoteViews remoteViews;
        private AppWidgetManager appWidgetManager;
        private int appWidgetId;

        public ChargingControlToggleTask(RemoteViews remoteViews, AppWidgetManager appWidgetManager, int widgetId) {
            this.remoteViews = remoteViews;
            this.appWidgetManager = appWidgetManager;
            this.appWidgetId = widgetId;
        }

        @Override
        protected Void doInBackground(Context... contexts) {
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
                e.printStackTrace();
            }
            return null;
        }

        public void onPostExecute(Void v) {
            remoteViews.setTextViewText(R.id.controlButton, "Charging start");

            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        RemoteViews remoteViews;

        for (int i = 0; i < appWidgetIds.length; i++) {
            int appWidgetId = appWidgetIds[i];

            remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);
            remoteViews.setTextViewText(R.id.controlButton, "Charging start");
            remoteViews.setOnClickPendingIntent(R.id.controlButton, getPendingSelfIntent(context, getAction(CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId)));

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
                RemoteViews remoteViews;

                remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);
                remoteViews.setTextViewText(R.id.controlButton, "Working...");
                remoteViews.setOnClickPendingIntent(R.id.controlButton, getPendingSelfIntent(context, getAction(CHARGING_CONTROL_TOGGLE_CLICKED, appWidgetId)));

                appWidgetManager.updateAppWidget(appWidgetId, remoteViews);

                new ChargingControlToggleTask(remoteViews, appWidgetManager, appWidgetId).execute(context);
            }
        }
    }

    private String getAction(String action, int appWidgetId) {
        return action + appWidgetId;
    }

    protected PendingIntent getPendingSelfIntent(Context context, String action) {
        Intent intent = new Intent(context, getClass());
        intent.setAction(action);
        return PendingIntent.getBroadcast(context, 0, intent, 0);
    }
}
