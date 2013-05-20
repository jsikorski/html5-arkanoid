package org.miu;

import java.io.IOException;
import java.sql.Connection;
import java.util.concurrent.locks.ReentrantLock;

import org.json.JSONObject;

import android.util.Log;
import de.tavendo.autobahn.WebSocketConnection;
import de.tavendo.autobahn.WebSocketException;
import de.tavendo.autobahn.WebSocketHandler;

public class ServerConnectionAB {
	protected static final String TAG = "ServerConnectionAB.java";
	private static boolean isConnected = false;
	private WebSocketConnection client = new WebSocketConnection();;
	private JSONObject jsonMessage = null;
	private final ReentrantLock lock = new ReentrantLock();

	public JSONObject getMessag() {
		return jsonMessage;
	}
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
     * Waiting for connection to established
     *
     * @param void
     * @return void
     * @throws none
     */
	public void waitForConnection() {
	    int count = 0;
	    while(count < 20){
	    	try {
				Thread.sleep(500);
			} catch (InterruptedException e) {

				e.printStackTrace();
			}
	    	if(isConnected())
	    		count = 20;
	    	else
	    		count++;
	    }
	}
	/**
     * Connecting to server
     *
     * @param  String (adres of server)
     * @return void
     * @throws Connection error
     */
	public void connect(String ip, String port) {
	      final String wsuri = "ws:////"+ip+":"+port;
	      
	      try {
	    	  client.connect(wsuri, new WebSocketHandler() {
	 
	            @Override
	            public void onOpen() {
	               Log.d(TAG, "Status: Connected to " + wsuri);
	               client.sendTextMessage("Hello, world!");
	            }
	 
	            @Override
	            public void onTextMessage(String payload) {
	               Log.d(TAG, "Got echo: " + payload);
	            }
	 
	            @Override
	            public void onClose(int code, String reason) {
	               Log.d(TAG, "Connection lost.");
	            }
	         });
	      } catch (WebSocketException e) {
	 
	         Log.d(TAG, e.toString());
	      }
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
			lock.lock();
			try {
				String message = "5:::{\"name\":\"message\",\"args\":[{\"type\"move:" + msg + "\"}]}";
				
				client.sendTextMessage(message);
			} catch (Exception e) {
				Log.d(TAG, "Error sending JSON - MOVE");
				return false;
			} finally {
				lock.unlock();
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
		lock.lock();
		try {
			String message = "5:::{\"name\":\"message\",\"args\":[{\"type\"start\"}]}";
			
			client.sendTextMessage(message);
		} catch (Exception e) {
			Log.d(TAG, "Error sending JSON - START");
			return false;
		} finally {
			lock.unlock();
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
	public boolean disconnect() throws IOException {
		if(isConnected) {
			client.disconnect();
			return true;
		}
		return false;
	}
}
