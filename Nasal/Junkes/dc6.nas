################# Aircraft specific ############################
var cruiseSpeed = 250;
var appSpeed = 125;
var transitionSpeed = 150;
var climbFPM = 1300;
var descentFPM = -2000;
var mixture = 1;
var throttle = 0;
var propellerPitch = 1;
################################################################

var apON = getprop("autopilot/switches/ap");
var gpsON = getprop("autopilot/switches/gps");
var navON = getprop("autopilot/switches/nav");
var apprON = getprop("autopilot/switches/appr");
var altON = getprop("autopilot/switches/alt");
var vsON = getprop("autopilot/switches/pitch");
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
var gsDeflection = getprop("instrumentation/nav/");

var update = func {
  apON = getprop("autopilot/switches/ap");
  gpsON = getprop("autopilot/switches/gps");
  navON = getprop("autopilot/switches/nav");
  apprON = getprop("autopilot/switches/appr");
  altON = getprop("autopilot/switches/alt");
  vsON = getprop("autopilot/switches/pitch");
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
  gsDeflection = getprop("instrumentation/nav/gs-needle-deflection-deg");
}


var setMixture = func(target) {
  setprop("controls/engines/engine[0]/mixture", target);
  setprop("controls/engines/engine[1]/mixture", target);
  setprop("controls/engines/engine[2]/mixture", target);
  setprop("controls/engines/engine[3]/mixture", target);
}

var horizontalNavigation = func {
  if(routeManagerActive) {
    if(wpDist < 1) {
      if (nextWPIndex == lastWPIndex) { 
        # ignore last wp
        return;
      } else {
        setprop("autopilot/route-manager/current-wp", nextWPIndex);
        dc6b.message.write("Route Manager - Waypoint: " ~nextWPIndex~"/"~lastWPIndex);
      }
    }
  }
}

var verticalNavigation = func {
  if (gpsON and aglFT > 500) {
    setprop("controls/gear/gear-down", 'false');
  }

  if (apON and (gpsON or navON) and speedKT > (appSpeed - 20)) {

    if (!navON and navInRange) {
      if (((navCourse - headingDeg) < 30) and ((navCourse - headingDeg) > -30)) {
        setprop("autopilot/switches/nav", 'true');
        dc6b.message.write("Autopilot nav ON");
      }
    }

    if (navON and !apprON and ((altFT - destinationFieldElevationFT) <= 2100) and gsDeflection < 0.2) {
      setprop("autopilot/switches/appr", 'true');
      setprop("controls/gear/gear-down", 'true');
      setprop("autopilot/settings/target-speed-kt", appSpeed);
      setprop("controls/flight/flaps", 1);
      setMixture(1);
      dc6b.message.write("Autopilot appr ON");
      dc6b.message.write("Gears down");
    }

    if (altON and altFT > (targetAltFT + 300)) {
      setprop("autopilot/settings/target-speed-kt", transitionSpeed);
      setprop("autopilot/settings/vertical-speed-fpm", descentFPM);
      setprop("autopilot/switches/pitch", 1);
      setprop("controls/flight/flaps", 0.5);
      setMixture(1);
      
      dc6b.message.write("Setting target speed: " ~ transitionSpeed ~ " kt");
      dc6b.message.write("Setting flaps: 50%");
      dc6b.message.write("Setting vertical speed: " ~ descentFPM ~ " fpm");
      dc6b.message.write("Setting mixture: 1");
    }

    if (altON and altFT < (targetAltFT - 300)) {
      setprop("autopilot/settings/target-speed-kt", transitionSpeed);
      setprop("autopilot/settings/vertical-speed-fpm", climbFPM);
      setprop("autopilot/switches/pitch", 1);
      setprop("controls/flight/flaps", 0.5);
      setMixture(1);

      dc6b.message.write("Setting target speed: " ~ transitionSpeed ~ " kt");
      dc6b.message.write("Setting flaps: 50%");
      dc6b.message.write("Setting vertical speed: " ~ climbFPM ~ " fpm");
      dc6b.message.write("Setting mixture: 1");
    }

    if (!apprON and vsON and altFT > (targetAltFT - 300) and altFT < (targetAltFT + 300)) {
      setprop("autopilot/switches/alt", 'true');
      setprop("controls/flight/flaps", 0);
      setprop("autopilot/settings/target-speed-kt", cruiseSpeed);
      setMixture(0.6);

      dc6b.message.write("Setting target speed: " ~ cruiseSpeed ~ " kt");
      dc6b.message.write("Setting altitude hold: " ~ targetAltFT ~ "ft");
      dc6b.message.write("Setting mixture: 0.6");
    }
  }
}

var main = func {
  update();
  horizontalNavigation();
  verticalNavigation();
  settimer(main, 2);
}

main();
