package dk.kjeldsen.carwingsflutter;

import android.app.PendingIntent;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

public abstract class ControlWidget extends AppWidgetProvider {

    protected RemoteViews getRemoteViews(Context context, String controlButtonName, String action, int appWidgetId) {
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.control_widget);

        remoteViews.setTextViewText(R.id.controlButton, controlButtonName);
        remoteViews.setOnClickPendingIntent(R.id.controlButton, getPendingSelfIntent(context, action, appWidgetId));

        return remoteViews;
    }

    protected String getAction(String action, int appWidgetId) {
        return action + appWidgetId;
    }

    protected PendingIntent getPendingSelfIntent(Context context, String action, int appWidgetId) {
        Intent intent = new Intent(context, getClass());
        intent.setAction(getAction(action, appWidgetId));
        return PendingIntent.getBroadcast(context, 0, intent, 0);
    }
}
