package com.example.thepizzabutton;

import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Looper;
import android.app.Activity;
import android.content.Context;
import android.view.Menu;
import android.webkit.WebView;

public class MainActivity extends Activity implements LocationListener {

	private WebView pizzaview;
	private LocationManager locationMangaer=null;  
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		pizzaview = (WebView) findViewById(R.id.pizzaview);
		pizzaview.getSettings().setJavaScriptEnabled(true);
		pizzaview.getSettings().setDomStorageEnabled(true);
		pizzaview.loadUrl("file:///android_asset/index.html");
		
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
