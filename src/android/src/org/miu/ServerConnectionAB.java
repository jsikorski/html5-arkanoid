package org.miu;

import io.socket.IOAcknowledge;
import io.socket.IOCallback;
import io.socket.SocketIO;
import io.socket.SocketIOException;

import java.net.MalformedURLException;
import java.sql.Connection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ServerConnectionAB {
	protected static final String TAG = "ServerConnectionAB.java";
	private static boolean isConnected = false;
	private SocketIO client;
	private boolean lifeLost = false;
	private boolean forceFeedBack = false;
	
	private JSONObject startMessage, leftMessage, rightMessage, resetMessage;

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

	/**
	 * Constructor
	 * 
	 * @param String
	 *            (adres of server)
	 * @return void
	 * @throws none
	 */
	public ServerConnectionAB() {
		try {
			JSONObject object = new JSONObject();
			object.put("type", "start");
	        startMessage = object;  

	        object = null;
	        object = new JSONObject();
			object.put("type", "move:left");       
	        leftMessage = object;
	        
	        object = null;
	        object = new JSONObject();
			object.put("type", "move:right");
	        rightMessage = object;
	        
	        object = null;
	        object = new JSONObject();
			object.put("type", "move:reset");
			resetMessage = object;
	        
		} catch (JSONException e) {
			e.printStackTrace();
		}
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
		try {
			client = new SocketIO("http://"+ip+":"+port);

			client.connect(new IOCallback() {
            @Override
            public void onMessage(JSONObject json, IOAcknowledge ack) {
                try {
                    JSONArray arguments = json.getJSONArray("message");
					try {
						String arg = arguments.getJSONObject(0).getString("type").toString();

						if (arg.equals("looseLife")) {
							lifeLost = true;
						} else if (arg.equals("force"))
							forceFeedBack = true;

					} catch (JSONException e) {
						e.printStackTrace();
					}
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onMessage(String data, IOAcknowledge ack) {
                System.out.println("Server said: " + data);
            }

            @Override
            public void onError(SocketIOException socketIOException) {
                System.out.println("an Error occured");
                socketIOException.printStackTrace();
            }

            @Override
            public void onDisconnect() {
            	isConnected = false;
                System.out.println("Connection terminated.");
            }

            @Override
            public void onConnect() {
            	isConnected = true;
                System.out.println("Connection established");
            }

            @Override
            public void on(String event, IOAcknowledge ack, Object... args) {
                System.out.println("Server triggered event '" + event + "'");
            }
        });
		} catch (MalformedURLException e1) {
			e1.printStackTrace();
		}
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
		client.send(leftMessage);
		return true;
	}
	public boolean pushMoveRight() {
		client.send(rightMessage);
		return true;
	}
	public boolean pushMoveReset() {
		client.send(resetMessage);
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
		client.send(startMessage);
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
		client.disconnect();
		return true;
	}
}
