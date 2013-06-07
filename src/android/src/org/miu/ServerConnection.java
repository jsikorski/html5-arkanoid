//
// ServerConnection.java
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
import java.net.URI;
import java.sql.Connection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.codebutler.android_websockets.SocketIOClient;

/**
 * @author Miko³aj Jankowski
 * 
 */
public class ServerConnection {

	protected static final String TAG = "ServerConnection.java";
	private static boolean isConnected = false;
	private SocketIOClient client;
	private boolean lifeLost = false;
	private boolean forceFeedBack = false;
	private boolean shoot = false;
	
	private String startMessage, leftMessage, rightMessage, resetMessage, restartMessage, shootMessage;

	public boolean isLifeLost() {
		if (lifeLost) {
			lifeLost = false;
			return true;
		} else
			return false;
	}

	public boolean isforceFeedBack() {
		if (forceFeedBack) {
			forceFeedBack = false;
			return true;
		} else
			return false;
	}
	
	public boolean isShootAvaible() {
		if (shoot) {
			shoot = false;
			return true;
		} else
			return false;
	}

	/**
	 * Returns true if connection established
	 * 
	 * @param void
	 * @return boolean
	 * @throws none
	 */
	public boolean isConnected() {
		return isConnected;
	}

	/**
	 * Constructor
	 * 
	 * @param String
	 *            (adres of server)
	 * @return void
	 * @throws none
	 */
	public ServerConnection() {
		try {
		// Start the game
			JSONArray arguments = new JSONArray();
			JSONObject object = new JSONObject();
			object.put("type", "start");
			arguments.put(object);
	        JSONObject event = new JSONObject();
	        event.put("name", "message");
	        event.put("args", arguments);
	        
	        startMessage = event.toString();
	     // Move left   
	        object.remove("type");
			object.put("type", "move:left");
			arguments.put(object);
	        event.put("name", "message");
	        event.put("args", arguments);	        
	        
	        leftMessage = event.toString();
	     // Move right
	        object.remove("type");
			object.put("type", "move:right");
			arguments.put(object);
	        event.put("name", "message");
	        event.put("args", arguments);	        
	        
	        rightMessage = event.toString();
	     // Reset move
	        object.remove("type");
			object.put("type", "move:reset");
			arguments.put(object);
	        event.put("name", "message");
	        event.put("args", arguments);	        
	        
	        resetMessage = event.toString();
	     // Restart game
	        object.remove("type");
			object.put("type", "restart");
			arguments.put(object);
	        event.put("name", "message");
	        event.put("args", arguments);	        
	        
	        restartMessage = event.toString();
	     // Shoot
	        object.remove("type");
			object.put("type", "shoot");
			arguments.put(object);
	        event.put("name", "message");
	        event.put("args", arguments);	        // Wiadomoœæ do serwera o wystrzale
	        
	        shootMessage = event.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Waiting for connection to established
	 * 
	 * @param void
	 * @return void
	 * @throws none
	 */
	public void waitForConnection() {
		int count = 0;
		while (count < 20) {
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {

				e.printStackTrace();
			}
			if (isConnected())
				count = 20;
			else
				count++;
		}
	}

	/**
	 * Connecting to server
	 * 
	 * @param String
	 *            (adres of server)
	 * @return void
	 * @throws Connection
	 *             error
	 */
	public void connect(String ip, String port) {

		try {
			final String adres = "http://" + ip + ":" + port;
			URI uri = URI.create(adres);

			client = new SocketIOClient(uri, new SocketIOClient.Handler() {

				public void onConnect() {
					isConnected = true;
					client.emit(restartMessage);
				}

				public void on(String event, JSONArray arguments) {
					try {
						String arg = arguments.getJSONObject(0).getString("type").toString();

						if (arg.equals("looseLife"))
							lifeLost = true;
						else if (arg.equals("force"))
							forceFeedBack = true;
						else if (arg.equals("shoot")) // Odebranie wiadomoœci od serwera o mo¿liwoœci strza³u
							shoot = true;

					} catch (JSONException e) {
						e.printStackTrace();
					}
				}

				public void onJSON(JSONObject json) {
				}

				public void onMessage(String message) {
				}

				public void onDisconnect(int code, String reason) {
					isConnected = false;
				}

				public void onError(Exception error) {
					isConnected = false;
				}
			});
		} catch (Exception ex) {

		}
		client.connect();
	}

	/**
	 * Push move to server
	 * 
	 * @param String
	 *            (message)
	 * @return boolean (true if pushed)
	 * @throws Connection
	 *             error
	 */
	public boolean pushMoveLeft() {
		client.emit(leftMessage);
		return true;
	}
	public boolean pushMoveRight() {
		client.emit(rightMessage);
		return true;
	}
	public boolean pushMoveReset() {
		client.emit(resetMessage);
		return true;
	}
	public boolean pushShoot() {
		client.emit(shootMessage);
		return true;
	}
	/**
	 * Push start JSON to server
	 * 
	 * @param void
	 * @return boolean (true if pushed)
	 * @throws Connection
	 *             error
	 */
	public boolean pushStart() {
		client.emit(startMessage);
		return true;
	}

	/**
	 * Disconnect from server
	 * 
	 * @param void
	 * @return boolean (true if disconnected)
	 * @throws Connection
	 *             error
	 */
	public boolean disconnect() {
		try {
			client.disconnect();
		} catch (IOException e) {
			return false;
		}
		return true;
	}
}
