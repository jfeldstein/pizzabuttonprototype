package com.example.thepizzabutton;

import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Looper;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.Menu;
import android.view.Window;
import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;

@SuppressLint("SetJavaScriptEnabled")
public class MainActivity extends Activity implements LocationListener {

	private WebView pizzaview;
	private LocationManager locationMangaer=null;  
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		pizzaview = (WebView) findViewById(R.id.pizzaview);
		
		pizzaview.setWebChromeClient(new WebChromeClient() {
				public boolean onConsoleMessage(ConsoleMessage cm) {
				  Log.d("MyApplication", cm.message() + " -- From line "
				                       + cm.lineNumber() + " of "
				                       + cm.sourceId() );
				  return true;
				}
				
				public boolean shouldOverrideUrlLoading(WebView view, String url) {
				  if(url.contains("twitter.com")) {
				    Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
				    startActivity(i);
				  } else {
				    view.loadUrl(url);
				  } 
				  return true;
				}
			});
		
		// Allow Javascript and let it do whatever it wants.
		WebSettings settings = pizzaview.getSettings();
		String databasePath = this.getApplicationContext().getDir("databases", Context.MODE_PRIVATE).getPath();
		settings.setDatabasePath(databasePath);
		settings.setJavaScriptEnabled(true);
		settings.setDomStorageEnabled(true); // Persist local storage
		settings.setAllowFileAccessFromFileURLs(true); 
		settings.setAllowUniversalAccessFromFileURLs(true);
		
		pizzaview.loadUrl("file:///android_asset/index.html");
		
		// Pass in location
		locationMangaer = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_COARSE);
        String provider = locationMangaer.getBestProvider(criteria, true);

        // FIXME: Something crashes the emulator when a GPS fix is sent through DDMS
        locationMangaer.requestSingleUpdate(provider, this, Looper.myLooper());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}

	@Override
	public void onLocationChanged(Location location) {
		pizzaview.loadUrl("javascript:setTimeout(\"locationUpdated("+location.getLatitude()+", "+location.getLongitude()+")\", 1000)");
	}

	@Override
	public void onProviderDisabled(String provider) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onProviderEnabled(String provider) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {
		// TODO Auto-generated method stub
		
	}

}
