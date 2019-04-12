package dk.kjeldsen.carwingsflutter;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static dk.kjeldsen.carwingsflutter.PreferencesManager.getDonated;

public abstract class ConfigWidgetActivity extends ListActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTitle("Choose vehicle");

        if(getDonated(getBaseContext())) {
            new GetVehiclesTask(this).execute(getBaseContext());
        } else {
            showDonationNeededDialog();
        }
    }

    private void showDonationNeededDialog() {
        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle("Donation required");
        alertDialog.setMessage("You haven't donated and therefore do not have access to widgets!");
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
        alertDialog.show();
    }

    public class GetVehiclesTask extends AsyncTask<Context, Void, List<CarwingsSession.Vehicle>> {

        private ProgressDialog progressDialog;
        private ListActivity listActivity;

        public GetVehiclesTask(ListActivity listActivity) {
            this.listActivity = listActivity;
            progressDialog = ProgressDialog.show(listActivity, "", "Getting your vehicles...", true);
        }

        @Override
        protected List<CarwingsSession.Vehicle> doInBackground(Context... contexts) {
            CarwingsSession carwingsSession = new CarwingsSession();
            try {
                JSONObject loginSettings = PreferencesManager.getLoginSettings(contexts[0]);
                String username = loginSettings.getString("username");
                String password = loginSettings.getString("password");
                String region = loginSettings.getString("region");

                return carwingsSession.login(username, password, region);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        public void onPostExecute(List<CarwingsSession.Vehicle> vehicles) {
            progressDialog.dismiss();

            List<String> vehicleNicknames = new ArrayList<>();
            for(CarwingsSession.Vehicle vehicle : vehicles) {
                vehicleNicknames.add(vehicle.nickname);
            }
            setListAdapter(new ArrayAdapter<String>(listActivity, android.R.layout.simple_list_item_1, vehicleNicknames));

            ListView listView = getListView();
            listView.setTextFilterEnabled(true);

            listView.setOnItemClickListener((parent, view, position, id) -> {
                String vehicleNickname = (String) ((TextView) view).getText();

                int appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;

                Intent intent = listActivity.getIntent();
                Bundle extras = intent.getExtras();

                appWidgetId = extras.getInt(
                        AppWidgetManager.EXTRA_APPWIDGET_ID,
                        AppWidgetManager.INVALID_APPWIDGET_ID);

                if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
                    listActivity.finish();
                }

                setPreferencesWidget(appWidgetId, vehicleNickname, listActivity.getBaseContext());

                Intent resultValue = new Intent();

                //Pass the original appWidgetId
                resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);

                //Set the results from the ‘Configure’ Activity
                setResult(RESULT_OK, resultValue);

                //Finish the Activity
                finish();
            });
        }
    }

    public abstract void setPreferencesWidget(int appWidgetId, String vehicleNickname, Context context);
}
