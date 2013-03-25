//
// SplashActivity.java
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
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

/**
 * @author Miko³aj Jankowski
 *
 */
public class SplashActivity extends Activity {

    /**
     * Called BackButton pressed
     *
     * @param void
     * @return void
     * @throws none
     */
	public void onBackPressed() {
		return;
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

		setContentView(R.layout.splashscreen);

		Thread actionThread = new Thread() {

			public void run() {

				/** Disable screen lock */

				try {
					Thread.sleep(1000);
				} catch (Exception e) {
					Log.d("SplashScreen", "An error ocured");
				} finally {
					finish();
					Intent i = new Intent(getBaseContext(),
							org.miu.MainActivity.class);
					startActivity(i);
					interrupt();
				}
			}
		};
		actionThread.start();
	}
}
