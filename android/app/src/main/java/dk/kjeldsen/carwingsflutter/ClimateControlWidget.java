package dk.kjeldsen.carwingsflutter;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.widget.RemoteViews;
import org.joda.time.DateTime;
import org.joda.time.DurationFieldType;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

// Implementation inspiration;
// https://stackoverflow.com/questions/14798073/button-click-event-for-android-widget
// https://stackoverflow.com/questions/17380168/update-android-widget-using-async-task-with-an-image-from-the-internet
// https://stackoverflow.com/questions/18545773/android-update-widget-from-broadcast-receiver
public class ClimateControlWidget extends AppWidgetProvider {

    private static final String CLIMATE_CONTROL_TOGGLE_CLICKED = "climateToggleClicked";
    private static final String CLIMATE_CONTROL_CLEAR = "climateClear";
    private static Map<Integer, Boolean> climateToggleStatus = new HashMap<>();

    public class ClimateControlToggleTask extends AsyncTask<Context, Void, Void> {

        private RemoteViews remoteViews;
        private AppWidgetManager appWidgetManager;
        private int appWidgetId;

        public ClimateControlToggleTask(RemoteViews remoteViews, AppWidgetManager appWidgetManager, int widgetId) {
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

                String vehicleName = PreferencesManager.getClimateControlWidgetVehicleNickname(appWidgetId, contexts[0]);

                if (climateToggleStatus.get(appWidgetId) == null) {
                    climateToggleStatus.put(appWidgetId, false);
                }

                boolean toggle;
                if(climateToggleStatus.get(appWidgetId)) {
                    carwingsSession.climateControlOff(vehicleName);
                    toggle = false;
                } else {
                    carwingsSession.climateControlOn(vehicleName);
                    toggle = true;

                    // Set Climate Control widget to off after preheat for 15 minutes
                    Intent updateIntent = new Intent(getAction(CLIMATE_CONTROL_CLEAR, appWidgetId));
                    updateIntent.setClass(contexts[0], ClimateControlWidget.class);

                    PendingIntent pendingIntent = PendingIntent.getBroadcast(contexts[0], 0,
                            updateIntent, 0);

                    AlarmManager alarmManager = (AlarmManager) contexts[0].getSystemService(Context.ALARM_SERVICE);
                    alarmManager.set(AlarmManager.RTC, DateTime.now().withFieldAdded(DurationFieldType.minutes(), 15).getMillis(), pendingIntent);
                }

                climateToggleStatus.put(appWidgetId, toggle);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        public void onPostExecute(Void v) {
            remoteViews.setTextViewText(R.id.climateControlButton, "Climate " + (climateToggleStatus.get(appWidgetId) ? "On" : "Off"));

            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        RemoteViews remoteViews;

        for (int i = 0; i < appWidgetIds.length; i++) {
            int appWidgetId = appWidgetIds[i];

            remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);
            remoteViews.setTextViewText(R.id.climateControlButton, "Climate off");
            remoteViews.setOnClickPendingIntent(R.id.climateControlButton, getPendingSelfIntent(context, getAction(CLIMATE_CONTROL_TOGGLE_CLICKED, appWidgetId)));

            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }


    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO Auto-generated method stub
        super.onReceive(context, intent);

        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context.getApplicationContext());
        ComponentName thisWidget = new ComponentName(context.getApplicationContext(), ClimateControlWidget.class);
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);

        for (int i = 0; i < appWidgetIds.length; i++) {
            int appWidgetId = appWidgetIds[i];

            if(getAction(CLIMATE_CONTROL_CLEAR, appWidgetId).equals(intent.getAction())) {
                climateToggleStatus.put(appWidgetId, false);

                RemoteViews remoteViews;

                remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);
                remoteViews.setTextViewText(R.id.climateControlButton, "Climate Off");

                appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
            }

            if (getAction(CLIMATE_CONTROL_TOGGLE_CLICKED, appWidgetId).equals(intent.getAction())) {
                RemoteViews remoteViews;

                remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);
                remoteViews.setTextViewText(R.id.climateControlButton, "Working...");

                appWidgetManager.updateAppWidget(appWidgetId, remoteViews);

                new ClimateControlToggleTask(remoteViews, appWidgetManager, appWidgetId).execute(context);
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
