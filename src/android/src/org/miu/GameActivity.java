//
// GameActivity.java
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

import org.miu.MySensor.Direction;
import org.miu.R;
import org.miu.MySensor;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.Toast;

/**
 * @author Miko³aj Jankowski
 *
 */
public class GameActivity extends Activity {

	private final static int INTERVAL = 1;

	private MySensor g;
	private ServerConnection server;
	private ImageView left, right;
	private boolean stop;
	private Direction now = Direction.NONE;
	private Handler handler;
	private Runnable runnable;

    /**
     * Called BackButton pressed
     *
     * @param void
     * @return void
     * @throws none
     */
	public void onBackPressed() {
		if (g != null) {
			stop = true;
		}
		if(server.isConnected()) {
			server.disconnect();
			server = null;
			handler.removeCallbacks(runnable);
		}
		server = null;
		finish();
	}

    /**
     * Called when activity first started
     *
     * @param savedInstanceState
     * @return void
     * @throws none
     */
	@Override
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
		setContentView(R.layout.game);

		left = (ImageView) findViewById(R.id.arrowLeft);
		right = (ImageView) findViewById(R.id.arrowRight);
		
		final SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);	
		
		server = new ServerConnection();
			   
		final String ip = prefs.getString("adres", "192.168.1.1");
		final String port = prefs.getString("port", "8080");
		   
		server.connect(ip, port);
	    
		server.waitForConnection();
		
		if (server.isConnected()) {
			g = new MySensor(this);
			stop = false;

			handler = new Handler();
			runnable = new Runnable() {
				public void run() {
					if (stop == true) {
						g.Stop();
					} else {
						getDirection();
					}
					handler.postDelayed(this, INTERVAL);
				}
			};
			handler.postDelayed(runnable, INTERVAL);
		} else {
			Toast.makeText(this, "Nie uda³o siê po³¹czyæ z serwerem", Toast.LENGTH_LONG).show();
			finish();
		}
	}
	/**
     * Geting actual direction and do some action
     *
     * @param void
     * @return void
     * @throws none
     */	
	private void getDirection() {
		if (g.getDirection() != now && g.getDirection() == Direction.LEFT) {
			goLeft();
			now = Direction.LEFT;
		} else if (g.getDirection() != now && g.getDirection() == Direction.RIGHT) {
			goRight();
			now = Direction.RIGHT;
		} else if(g.getDirection() != now && g.getDirection() == Direction.NONE) {
			goStraight();
			now = Direction.NONE;	
		}
	}
	
    /**
     * Called when turned left
     *
     * @param void
     * @return void
     * @throws none
     */
	private void goLeft() {
		if(server.isConnected()) {
			server.pushMove("left");
			left.setImageResource(R.drawable.arrow_left_on);
			right.setImageResource(R.drawable.arrow_right);
		}
	}
    /**
     * Called when turned right
     *
     * @param void
     * @return void
     * @throws none
     */
	private void goRight() {
		if(server.isConnected()) {
			server.pushMove("right");
			right.setImageResource(R.drawable.arrow_right_on);
			left.setImageResource(R.drawable.arrow_left);
		}	
	}
    /**
     * Called when not turned
     *
     * @param void
     * @return void
     * @throws none
     */
	private void goStraight() {
		if(server.isConnected()) {
			server.pushMove("reset");
			left.setImageResource(R.drawable.arrow_left);
			right.setImageResource(R.drawable.arrow_right);
		}
	}
}