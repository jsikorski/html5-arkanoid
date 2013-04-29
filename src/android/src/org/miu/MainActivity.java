//
// MainActivity.java
//
// Copyright (c) 2013 Miko³aj Jankowski
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package org.miu;

import org.miu.R;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.text.Html;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;

/**
 * @author Miko³aj Jankowski
 *
 */
public class MainActivity extends Activity {

	private ImageButton newGameButton;

	public boolean oneTimeLoadActivity = false;

    /**
     * Called when BackButton pressed
     *
     * @param void
     * @return void
     * @throws none
     */
	public void onBackPressed() {
		return;
	}

    /**
     * Menu constructor
     *
     * @param Menu menu
     * @return void
     * @throws none
     */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

    /**
     * Menu actions
     *
     * @param MenuItem item
     * @return boolean (always true)
     * @throws none
     */
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {

		/** Exit App */
		case R.id.exitMenu:
			finish();
			break;

		/** Settings menu */
		case R.id.settingsMenu:
			Intent intent = new Intent(MainActivity.this,
					SettingsActivity.class);
			startActivity(intent);
			break;

		/** About menu */
		case R.id.aboutMenu:
			AlertDialog ad = new AlertDialog.Builder(this).create();
			ad.setMessage(Html.fromHtml("<html><b>Arkanoid</b><br><br>"
					+ "Twórcy:<br>"));
			ad.setButton("Close", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
				}
			});
			ad.show();
			break;
		}
		return true;
	}

    /**
     * Called when activity first started
     *
     * @param savedInstanceState
     * @return void
     * @throws none
     */
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		/** Orientation - always Landscape */
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

		/** Full screen */
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);

		/** Keep screen on */
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

		setContentView(R.layout.main);
		
		newGameButton = (ImageButton) findViewById(R.id.newGameButton);

		newGameButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(getBaseContext(),org.miu.GameActivity.class);
				startActivity(i);
			}
		});
	}
}
