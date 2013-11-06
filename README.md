ThePizzaButton Mobile (Web) App
===============================

This bad boy is the buttons and UX for the pizza button app. 

It's a web app, built using Yoeman. Currently needs to be wrapped into iOS and Android native app shims, but can be made to work and look good on it's own. 

The server endpoints for finding restaurants, shipping pizzas and registering users is here: [TBD]

**Start the local server** with `grunt server`. It uses LiveReload to automatically refresh the window when detecting changes to files. 

Add new Backbone components using: 

    yo backbone:model Blog
    yo backbone:view Blog
    yo backbone:collection Blog
    yo backbone:router Blog

More on yoeman's generator-backbone [here](https://github.com/yeoman/generator-backbone)

## Files of note: 

 - `app/scripts/main.coffee` is the entry point. It defines the global `pizzabuttonapp` namespace and inits the Backbone routers. It also kicks of some async background fetches for data (currently just location and nearby restaurants).
 - `app/scripts/routes/app.coffee` is currently the only Backbone router in place. It controls the flow of the UX and what appears on the screen. Each "Route" is bound to a specific url hash, which Backbone's routers make work using magic. 
 - `app/scripts/views/Base.coffee` is a base view, which all other views should extend. It currently just provides the common `render()` method, and makes some global view helpers available to the template() methods. 
 - `app/scripts/views/ViewPusher.coffee` is what actually appears the results of other views' `render()` calls into the DOM. Right now, it just replaces whatevers there with what's new, but will eventually [transition](https://github.com/ccoenraets/PageSlider/blob/master/pageslider.js) in the new content when moving to new pages (using [this css](http://coenraets.org/blog/2013/03/hardware-accelerated-page-transitions-for-mobile-web-apps-phonegap-apps/)) so the app looks fancy. 