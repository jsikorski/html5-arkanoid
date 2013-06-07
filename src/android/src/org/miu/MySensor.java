//
// MySensor.java
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

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

/**
 * @author Miko³aj Jankowski
 *
 */
public class MySensor implements SensorEventListener {
	private SensorManager mSensorManager;
	private Sensor mSensor;
	private final float bound = (float) 2.5;
	private Direction dir = Direction.NONE;
	private float axis = 0;
   
	/**
     * Constructor
     *
     * @param Context c
     * @return void
     * @throws none
     */
	public MySensor(Context c) {
		mSensorManager = (SensorManager) c.getSystemService(Context.SENSOR_SERVICE);
		mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
		mSensorManager.registerListener(this, mSensor, SensorManager.SENSOR_DELAY_NORMAL);
	}

	public enum Direction {
		LEFT, RIGHT, NONE
	}
	
	/**
     * Stop using sensor
     *
     * @param  void
     * @return void
     * @throws none
     */
	public void Stop() {
		mSensorManager.unregisterListener(this);
	}
	
	/**
     * Returns directory
     *
     * @param  void
     * @return Directory (ENUM)
     * @throws none
     */
	public Direction getDirection() {
		return dir;
	}

	/**
     * Returns X Axis Value
     *
     * @param  void
     * @return float
     * @throws none
     */
	public float getAxis() {
		return axis;
	}
	
	/**
     * Called when sensor value changed
     *
     * @param  void
     * @return SensorEvent event
     * @throws none
     */
	public void onSensorChanged(SensorEvent event) {
		axis = event.values[1];

		if (axis > bound) {
			dir = Direction.RIGHT;
		} else if (axis < -bound) {
			dir = Direction.LEFT;
		} else
			dir = Direction.NONE;
	}

	/**
     * onAccuracyChanged event
     *
     * @param  Sensor, accuracy
     * @return void
     * @throws none
     */
	public void onAccuracyChanged(Sensor sensor, int accuracy) {

	}
}
