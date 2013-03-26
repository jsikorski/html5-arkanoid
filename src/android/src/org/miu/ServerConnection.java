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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.codebutler.android_websockets.SocketIOClient;

import android.util.Log;

/**
 * @author Miko³aj Jankowski
 *
 */
public class ServerConnection {

	protected static final String TAG = "ServerConnection.java";
	private boolean isConnected = false;
	private SocketIOClient client;
	
	/**
     * Returns true if connection established
     *
     * @param  void
     * @return boolean
     * @throws none
     */
	public boolean isConnected() {
		return isConnected;
	}
	
	/**
     * Constructor
     *
     * @param  String (adres of server)
     * @return void
     * @throws none
     */
	public ServerConnection() {

	}
	
	/**
     * Connecting to server
     *
     * @param  String (adres of server)
     * @return void
     * @throws Connection error
     */
	public void connect(String ip, String port) {
		
		Log.d("ServerConnection", "Start:connect()");

		try {
			final String adres = "http://" + ip + ":" + port;	
			URI uri = URI.create(adres);
			
			client = new SocketIOClient(uri, new SocketIOClient.Handler() {
			    
				public void onConnect() {
			    	isConnected = true;
			    	pushStart();
			        Log.d(TAG, "Connected!");
			    }

			    public void on(String event, JSONArray arguments) {
			        Log.d(TAG, String.format("Got event %s: %s", event, arguments.toString()));
			    }

			    public void onJSON(JSONObject json) {
			        Log.d(TAG, String.format("Got JSON Object: %s", json.toString()));
			    }

			    public void onMessage(String message) {
			        Log.d(TAG, String.format("Got message: %s", message));
			    }

			    public void onDisconnect(int code, String reason) {
			        Log.d(TAG, String.format("Disconnected! Code: %d Reason: %s", code, reason));
			    }

			    public void onError(Exception error) {
			        Log.e(TAG, "Error!", error);
			        isConnected = false;
			    }
			});
			pushStart();
		}
		catch (Exception ex) {

		}
		client.connect();
	}

	/**
     * Push move to server
     *
     * @param  String (message)
     * @return boolean (true if pushed)
     * @throws Connection error
     */
	public boolean pushMove(String msg) {
		if(isConnected) {
			try {
				JSONArray arguments = new JSONArray();		
				//arguments.put("type");
				arguments.put("move:"+msg);	
				
				client.emit("message",arguments);
			} catch (JSONException e) {
				Log.d(TAG, "Error sending JSON - MOVE");
				return false;
			}
			
			return true;
		}
		return false;	
	}
	
	/**
	 * Push start JSON to server
	 *
	 * @param  void
	 * @return boolean (true if pushed)
	 * @throws Connection error
	 */	
	public boolean pushStart() {
		try {
			JSONArray arguments = new JSONArray();
			//arguments.put("type");
			arguments.put("start");	
			
			client.emit("message",arguments);
		} catch (JSONException e) {
			Log.d(TAG, "Error sending JSON - START");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Disconnect from server
	 *
	 * @param  void
	 * @return boolean (true if disconnected)
	 * @throws Connection error
	 */		
	public boolean disconnect() {
		if(isConnected) {
			try {
				client.disconnect();
			} catch (IOException e) {

			}
			return true;
		}
		return false;
	}
}
