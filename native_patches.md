## Remove title bar

Put `<item name="android:windowNoTitle">true</item>` inside default theme. (res/values/styles.xml)

## Allow local webview JS to work as expected

1. Enable JS
2. Persist local storage (Parse stores user id in local storage)
3. Disable cross-domain protection
4. Use permission `android.permission.INTERNET`

    // Allow Javascript and let it do whatever it wants.
    WebSettings settings = webview.getSettings();
    String databasePath = this.getApplicationContext().getDir("databases", Context.MODE_PRIVATE).getPath();
    settings.setDatabasePath(databasePath);
    settings.setJavaScriptEnabled(true);
    settings.setDomStorageEnabled(true); // Persist local storage
    settings.setAllowFileAccessFromFileURLs(true); 
    settings.setAllowUniversalAccessFromFileURLs(true);

## Push console messages to logcat

    public class MainActivity extends Activity {

      protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        myview = (WebView) findViewById(R.id.myview);
        
        myview.setWebChromeClient(new WebChromeClient() {
            public boolean onConsoleMessage(ConsoleMessage cm) {
              Log.d("MyApplication", cm.message() + " -- From line "
                                   + cm.lineNumber() + " of "
                                   + cm.sourceId() );
              return true;
            }
          });
      }
    }

## Push starting location into webview

1. Use Permission `android.permission.ACCESS_COARSE_LOCATION`
2. Get location
3. Push location into javascript once known


    public class MainActivity extends Activity implements LocationListener {

      private LocationManager locationMangaer=null;  
      
      @Override
      protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        myview = (WebView) findViewById(R.id.myview);
        
        // javascript on this page defines `locationUpdated` as a callback for receiving location.
        myview.loadUrl("file:///android_asset/index.html");
        
        // Pass in location
        locationMangaer = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_COARSE);
        String provider = locationMangaer.getBestProvider(criteria, true);

        // FIXME: Something crashes the emulator when a GPS fix is sent through DDMS
        locationMangaer.requestSingleUpdate(provider, this, Looper.myLooper());
      }

      @Override
      public void onLocationChanged(Location location) {
        // Send location to `locationUpdated` callback, where app will handle it.
        myview.loadUrl("javascript:setTimeout(\"locationUpdated("+location.getLatitude()+", "+location.getLongitude()+")\", 750)");
      }

    }


## Capture back button to go to previous webview screen, or exit app.

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK) && webView.canGoBack()) { 
                //if Back key pressed and webview can navigate to previous page
            webView.goBack();
                // go back to previous page
            return true;
        }
        else
        {
            finish();
               // finish the activity
        }
        return super.onKeyDown(keyCode, event);
    }