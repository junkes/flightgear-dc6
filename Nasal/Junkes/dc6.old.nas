################# Aircraft specific ############################
var cruiseSpeed = 220;
var turnSpeed = 180;
var appSpeed = 120;
var descentSpeed = 150;
var climbSpeed = 170;
var climbFPM = 1300;
var descentFPM = -2000;
var mixture = 1;
var throttle = 0;
var propellerPitch = 1;
var flaps = 0;
var reverseON = 0;
################################################################

var apON = getprop("autopilot/switches/ap");
var gpsON = getprop("autopilot/switches/gps");
var navON = getprop("autopilot/switches/nav");
var apprON = getprop("autopilot/switches/appr");
var altON = getprop("autopilot/switches/alt");
var vsON = getprop("autopilot/switches/pitch");
var speedON = getprop("autopilot/switches/ias");
var speedKT = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
var altFT = getprop("instrumentation/gps/indicated-altitude-ft");
var targetAltFT = getprop("autopilot/settings/target-altitude-ft");
var aglFT = getprop("position/gear-agl-ft");
var destinationFieldElevationFT = getprop("autopilot/route-manager/destination/field-elevation-ft");
var navCourse = getprop("instrumentation/nav/radials/selected-deg");
var headingDeg = getprop("instrumentation/gps/indicated-track-magnetic-deg");
var routeManagerActive = getprop("autopilot/route-manager/active");
var wpDist = getprop("autopilot/route-manager/wp/dist") or 0;
var currentWPIndex = getprop("autopilot/route-manager/current-wp") or 0;
var nextWPIndex = currentWPIndex + 1;
var routeNum = getprop("autopilot/route-manager/route/num") or 0;
var lastWPIndex = routeNum - 1;
var navInRange = getprop("instrumentation/nav/in-range");
var currentThrottle = getprop("controls/engines/engine/throttle");
var currentMixture = getprop("controls/engines/engine/mixture");
var currentPropellerPitch = getprop("controls/engines/engine/propeller-pitch");
var currentFlaps = getprop("controls/flight/flaps");
var gsDeflection = getprop("instrumentation/nav/gs-needle-deflection-deg");

var updateStats = func {
  apON = getprop("autopilot/switches/ap");
  gpsON = getprop("autopilot/switches/gps");
  navON = getprop("autopilot/switches/nav");
  apprON = getprop("autopilot/switches/appr");
  altON = getprop("autopilot/switches/alt");
  vsON = getprop("autopilot/switches/pitch");
  speedON = getprop("autopilot/switches/ias");
  speedKT = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  altFT = getprop("instrumentation/gps/indicated-altitude-ft");
  targetAltFT = getprop("autopilot/settings/target-altitude-ft");
  aglFT = getprop("position/gear-agl-ft");
  destinationFieldElevationFT = getprop("autopilot/route-manager/destination/field-elevation-ft");
  navCourse = getprop("instrumentation/nav/radials/selected-deg");
  headingDeg = getprop("instrumentation/gps/indicated-track-magnetic-deg");
  routeManagerActive = getprop("autopilot/route-manager/active");
  wpDist = getprop("autopilot/route-manager/wp/dist") or 0;
  currentWPIndex = getprop("autopilot/route-manager/current-wp") or 0;
  nextWPIndex = currentWPIndex + 1;
  routeNum = getprop("autopilot/route-manager/route/num") or 0;
  lastWPIndex = routeNum - 1;
  navInRange = getprop("instrumentation/nav/in-range");
  currentThrottle = getprop("controls/engines/engine/throttle");
  currentMixture = getprop("controls/engines/engine/mixture");
  currentPropellerPitch = getprop("controls/engines/engine/propeller-pitch");
  currentFlaps = getprop("controls/flight/flaps");
  gsDeflection = getprop("instrumentation/nav/gs-needle-deflection-deg");
  settimer(updateStats, 0);
}

var setFlightControls = func() {
  if (!apON) {
    settimer(setFlightControls, 3);
    return 0;
  }
  
  setprop("controls/engines/engine[0]/mixture", mixture);
  setprop("controls/engines/engine[1]/mixture", mixture);
  setprop("controls/engines/engine[2]/mixture", mixture);
  setprop("controls/engines/engine[3]/mixture", mixture);

  setprop("controls/engines/engine[0]/propeller-pitch", propellerPitch);
  setprop("controls/engines/engine[1]/propeller-pitch", propellerPitch);
  setprop("controls/engines/engine[2]/propeller-pitch", propellerPitch);
  setprop("controls/engines/engine[3]/propeller-pitch", propellerPitch);

  # setprop("controls/flight/flaps", flaps);

  if (!speedON) {
    setprop("controls/engines/engine[0]/throttle", throttle);
    setprop("controls/engines/engine[1]/throttle", throttle);
    setprop("controls/engines/engine[2]/throttle", throttle);
    setprop("controls/engines/engine[3]/throttle", throttle);
  }

  settimer(setFlightControls, 0);
}

var reverse = func() {
  if (!speedON and speedKT > 30 and reverseON) {
    setprop("controls/engines/engine[0]/propeller-pitch", 0);
    setprop("controls/engines/engine[1]/propeller-pitch", 0);
    setprop("controls/engines/engine[2]/propeller-pitch", 0);
    setprop("controls/engines/engine[3]/propeller-pitch", 0);
    setprop("controls/engines/engine[0]/throttle", 1);
    setprop("controls/engines/engine[1]/throttle", 1);
    setprop("controls/engines/engine[2]/throttle", 1);
    setprop("controls/engines/engine[3]/throttle", 1);
    setprop("/sim/model/pushback/enabled", 1 );
    setprop("/sim/model/pushback/force", 1);
    props.globals.initNode("/sim/model/pushback/target-speed-fps", 0);
    settimer(func(){
      setprop("/sim/model/pushback/target-speed-fps", 1);
    }, 3);
    reverseON = 0;
    dc6b.message.write("Reverse ON");
    var reverseListener = setlistener("instrumentation/airspeed-indicator/indicated-speed-kt", func(speed) {
      if (speed.getValue() < 30) {
        setprop("controls/engines/engine[0]/propeller-pitch", 1);
        setprop("controls/engines/engine[1]/propeller-pitch", 1);
        setprop("controls/engines/engine[2]/propeller-pitch", 1);
        setprop("controls/engines/engine[3]/propeller-pitch", 1);
        setprop("controls/engines/engine[0]/throttle", 0);
        setprop("controls/engines/engine[1]/throttle", 0);
        setprop("controls/engines/engine[2]/throttle", 0);
        setprop("controls/engines/engine[3]/throttle", 0);
        setprop("/sim/model/pushback/enabled", 0);
        setprop("/sim/model/pushback/force", 0);
        setprop("/sim/model/pushback/target-speed-fps", 0);
        removelistener(reverseListener);
        dc6b.message.write("Reverse OFF");
      }
    });
  } else {
    reverseON = 0;
  }
}

var reverseByKeyboard = func() {
  reverseON = 1;
  reverse();
}

var horizontalNavigation = func {
  if(!routeManagerActive) {
    settimer(horizontalNavigation, 2);
    return 0;
  }

  if(wpDist < 1) {
    if (nextWPIndex == lastWPIndex) { 
      # ignore last wp
      return;
    } else {
      setprop("autopilot/route-manager/current-wp", nextWPIndex);
      dc6b.message.write("Route Manager - Waypoint: " ~nextWPIndex~"/"~lastWPIndex);
    }
  }

  settimer(horizontalNavigation, 2);
}

var verticalNavigation = func {
  if(!routeManagerActive) {
    settimer(verticalNavigation, 2);
    return 0;
  }

  if (gpsON and aglFT > 500 and getprop("controls/gear/gear-down")) {
    setprop("controls/gear/gear-down", 'false');
    setprop("autopilot/settings/vertical-speed-fpm", climbFPM);
    dc6b.message.write("Setting vertical speed: " ~ climbFPM ~ " fpm");
  }

  if (apON and (gpsON or navON) and speedKT > (appSpeed - 20)) {

    if (!navON and navInRange) {
      if (((navCourse - headingDeg) < 30) and ((navCourse - headingDeg) > -30)) {
        setprop("autopilot/switches/nav", 'true');
        dc6b.message.write("Autopilot nav ON");
      }
    }

    if (
        navON and 
        !apprON and 
        ((altFT - destinationFieldElevationFT) <= 2100) and 
        currentWPIndex == (routeNum - 1) and 
        aglFT > 40
      ) {
      setprop("autopilot/switches/appr", 1);
      setprop("controls/gear/gear-down", 'true');
      setprop("autopilot/settings/target-speed-kt", appSpeed);
      flaps = 1;
      mixture = 1;
      dc6b.message.write("Autopilot appr ON");
      dc6b.message.write("Gears down");
      dc6b.message.write("Setting flaps: " ~ flaps);
    }

    if (altON and altFT > (targetAltFT + 300)) {
      setprop("autopilot/settings/target-speed-kt", descentSpeed);
      setprop("autopilot/settings/vertical-speed-fpm", descentFPM);
      setprop("autopilot/switches/pitch", 1);
      flaps = 0;
      mixture = 1;
      
      dc6b.message.write("Setting target speed: " ~ descentSpeed ~ " kt");
      dc6b.message.write("Setting flaps: " ~ flaps);
      dc6b.message.write("Setting vertical speed: " ~ descentFPM ~ " fpm");
      dc6b.message.write("Setting mixture: 1");
    }

    if (!apprON and altON and altFT < (targetAltFT - 300)) {
      var rateClimb = aglFT < 200 ? 1000 : climbFPM;

      setprop("autopilot/settings/target-speed-kt", climbSpeed);
      setprop("autopilot/settings/vertical-speed-fpm", rateClimb);
      setprop("autopilot/switches/pitch", 1);
      flaps = 0;
      mixture = 1;

      dc6b.message.write("Setting target speed: " ~ climbSpeed ~ " kt");
      dc6b.message.write("Setting flaps: " ~ flaps);
      dc6b.message.write("Setting vertical speed: " ~ rateClimb ~ " fpm");
      dc6b.message.write("Setting mixture: 1");
    }

    if (!apprON and vsON and altFT > (targetAltFT - 300) and altFT < (targetAltFT + 300)) {
      var speed = navON ? descentSpeed : cruiseSpeed;
      flaps = navON ? 0.5 : 0;
      mixture = navON ? 1 : 0.6;
      setprop("autopilot/switches/alt", 'true');
      setprop("autopilot/settings/target-speed-kt", speed);

      dc6b.message.write("Setting target speed: " ~ speed ~ " kt");
      dc6b.message.write("Setting altitude hold: " ~ targetAltFT ~ "ft");
      dc6b.message.write("Setting flaps: " ~ flaps);
      dc6b.message.write("Setting mixture: " ~ mixture);
    }

    if (apprON and aglFT <= 2 ) {
      setprop("autopilot/switches/ias", 0);
      setprop("autopilot/switches/ap", 0);
      setprop("autopilot/switches/nav", 0);
      setprop("autopilot/switches/appr", 0);
      setprop("autopilot/switches/alt", 0);
      setprop("autopilot/switches/gps", 0);
      setprop("autopilot/switches/pitch", 0);
      throttle = 0;
      propellerPitch = 0;
      flaps = 0;
      reverseON = 1;
      settimer(reverse, 3);
    }
  }
  settimer(verticalNavigation, 2);
}

setlistener("instrumentation/airspeed-indicator/indicated-speed-kt", func(kt) {
  var range = (kt.getValue() - 120);
  if (range < 0) range = 0;
  var percent = 1 - (range / 80);
  if (!apprON) {
    percent /= 4;
  }
  if (kt.getValue() > 160 or aglFT < 2) {
    percent = 0;
  }
  setprop("controls/flight/flaps", percent);
});

updateStats();
setFlightControls();
horizontalNavigation();
verticalNavigation();
