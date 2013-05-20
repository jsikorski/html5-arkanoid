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

import java.io.IOException;
import java.util.concurrent.locks.ReentrantLock;

import org.miu.MySensor.Direction;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Toast;

/**
 * @author Miko³aj Jankowski
 * 
 */
public class GameActivity extends Activity {

	private final static int INTERVAL = 10;

	private MySensor g;
	private ServerConnection server;
	private ImageView left, right;
	private Direction now = Direction.NONE;
	private int leftImg, rightImg, offImg;
	private Handler handler;
	private Runnable runnable;
	private boolean started = false;
	private int lifes = 3;
	private ImageView[] lifeImage;
	private ImageButton actionBtn;
	private final ReentrantLock lock = new ReentrantLock();

	/**
	 * Called BackButton pressed
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	public void onBackPressed() {
		if (server.isConnected()) {
			server.disconnect();
		}
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

		actionBtn = (ImageButton) findViewById(R.id.actionBtn);
		lifeImage = new ImageView[3];
		lifeImage[0] = (ImageView) findViewById(R.id.life1);
		lifeImage[1] = (ImageView) findViewById(R.id.life2);
		lifeImage[2] = (ImageView) findViewById(R.id.life3);

		leftImg = R.drawable.arrow_left_on;
		rightImg = R.drawable.arrow_right_on;
		offImg = R.drawable.arrow_off;

		actionBtn.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (server.isConnected()) {
					if (!started) {
						server.pushStart();
						started = true;
						actionBtn.setImageResource(R.drawable.button);
					}
				}
			}
		});

		left = (ImageView) findViewById(R.id.arrowLeft);
		right = (ImageView) findViewById(R.id.arrowRight);

		final SharedPreferences prefs = PreferenceManager
				.getDefaultSharedPreferences(this);

		server = new ServerConnection();

		final String ip = prefs.getString("adres", "192.168.1.1");
		final String port = prefs.getString("port", "8080");

		server.connect(ip, port);

		server.waitForConnection();

		if (server.isConnected()) {
			g = new MySensor(this);

			handler = new Handler();
			runnable = new Runnable() {
				public void run() {
					if (server.isConnected()) {
						getDirection();
						handler.postDelayed(this, INTERVAL);
					} else {
						g.Stop();
						finish();
						toast("Po³¹czenie zerwane");
					}
				}
			};
			handler.postDelayed(runnable, INTERVAL);
		} else {
			toast("Nie uda³o siê po³¹czyæ z serwerem");
			finish();
		}
	}

	private void toast(String message) {
		Toast.makeText(this, message, Toast.LENGTH_LONG).show();
	}

	/**
	 * Called when life is lost
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	private void lifeLost() throws IOException {
		if (lifes > 1) {
			lifeImage[lifes - 1].setImageDrawable(null);
			lifes--;
			actionBtn.setImageResource(R.drawable.start_btn);
			started = false;
		} else {
			gameOver();
			server.disconnect();
		}
	}

	/**
	 * Called when game is over
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	private void gameOver() {
		toast("Game Over");
	}

	/**
	 * Geting actual direction and do some action
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	private void getDirection() {
		Direction get = g.getDirection();
		try {
			if (now != get) {
				if (get == Direction.LEFT) {
					now = Direction.LEFT;
					goLeft();
				} else if (get == Direction.RIGHT) {
					now = Direction.RIGHT;
					goRight();
				} else {
					now = Direction.NONE;
					goStraight();
				}
			}
		} catch (Exception ex) {

		}
	}

	/**
	 * Called when turned left
	 * 
	 * @param void
	 * @return void
	 * @throws InterruptedException
	 * @throws none
	 */
	private void goLeft() throws InterruptedException {
		lock.lock();
		//server.pushMove("reset");
		server.pushMove("left");
		//left.setImageResource(leftImg);
		lock.unlock();
	}

	/**
	 * Called when turned right
	 * 
	 * @param void
	 * @return void
	 * @throws InterruptedException
	 * @throws none
	 */
	private void goRight() throws InterruptedException {
		lock.lock();
		//server.pushMove("reset");
		server.pushMove("right");
		//right.setImageResource(rightImg);
		lock.unlock();
	}

	/**
	 * Called when not turned
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	private void goStraight() {
		lock.lock();
		server.pushMove("reset");
		//left.setImageResource(offImg);
		//right.setImageResource(offImg);
		lock.unlock();
	}
}