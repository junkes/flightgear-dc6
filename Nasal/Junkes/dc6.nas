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
var airport = 0;
var rwy = 0;
var totalWP = 0;
var currentWPIndex = 0;
var lastWPIndex = 0;
var courseWP = 0;
var distanceWP = 0;
var courseRWY = 0;
var distanceRWY = 0;
var elevationRWY = 0;
var positionRWY = {lat: 0, lon: 0};
var headingRWY = 0;
var WPlat = 0;
var WPlon = 0;
var verticalSpeed = 0;
var targetAltitude = 0;
var currentAltitude = 0;
var currentSpeed = 0;
################################################################

props.globals.initNode("junkes/current-wp", '');
props.globals.initNode("junkes/current-wp-index", 0);
props.globals.initNode("junkes/current-wp-lat", 0);
props.globals.initNode("junkes/current-wp-lon", 0);
props.globals.initNode("junkes/current-wp-dist", 0);
props.globals.initNode("junkes/current-wp-course", 0);
props.globals.initNode("junkes/rwy-dist", 0);
props.globals.initNode("junkes/rwy-course", 0);
props.globals.initNode("junkes/current-vertical-speed", 0);

var main = func {
  setprop("junkes/current-vertical-speed", (getprop("velocities/vertical-speed-fps") or 0) * 60);


  if (getprop("autopilot/route-manager/active")) {
    airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
    totalWP = getprop("autopilot/route-manager/route/num");
    lastWPIndex = totalWP - 1;
    rwy = airport.runways[getprop("autopilot/route-manager/destination/runway")];
    positionRWY.lat = rwy.lat;
    positionRWY.lon = rwy.lon;
    elevationRWY = getprop("autopilot/route-manager/destination/field-elevation-ft");
    headingRWY = rwy.heading;

    setprop("autopilot/route-manager/active", 'false');
  }

  if (airport != 0) {
    WPlat = getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/latitude-deg");
    WPlon = getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/longitude-deg");

    (courseWP, distanceWP) = courseAndDistance({lat: WPlat, lon: WPlon});
    dc6b.message.write("courseWP: " ~ sprintf("%.2f", courseWP));
    dc6b.message.write("distanceWP: " ~ sprintf("%.2f", distanceWP));

    (courseRWY, distanceRWY) = courseAndDistance(positionRWY);
    dc6b.message.write("courseRWY: " ~ sprintf("%.2f", courseRWY));
    dc6b.message.write("distanceRWY: " ~ sprintf("%.2f", distanceRWY));

    targetAltitude = getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/altitude-ft");
    currentAltitude = getprop("position/altitude-ft");
    verticalSpeed = targetAltitude - currentAltitude;
    if (verticalSpeed > 1500) verticalSpeed = 1500;
    if (verticalSpeed < -2000) verticalSpeed = -2000;
    currentSpeed = getprop("velocities/airspeed-kt");
  }

  if (currentWPIndex != lastWPIndex) {
    setprop("junkes/current-wp", getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/id"));
    setprop("junkes/current-wp-index", currentWPIndex);
    setprop("junkes/current-wp-lat", WPlat);
    setprop("junkes/current-wp-lon", WPlon);
    setprop("junkes/current-wp-dist", distanceWP);
    setprop("junkes/current-wp-course", courseWP);
    setprop("junkes/rwy-dist", distanceRWY);
    setprop("junkes/rwy-course", courseRWY);
    if (currentWPIndex == (lastWPIndex - 2)) {
      setprop("autopilot/settings/target-speed-kt", 150);
      setprop("controls/flight/flaps", 0.5);
    } elsif (currentWPIndex == (lastWPIndex - 1)) {
      setprop("autopilot/settings/target-speed-kt", 120);
      setprop("controls/flight/flaps", 1);
    } else {
      setprop("autopilot/settings/target-speed-kt", 220);
      setprop("controls/flight/flaps", 0);
    }
    if (currentSpeed > 100) {
      setprop("autopilot/locks/heading", "true-heading-hold");
      setprop("autopilot/locks/altitude", "vertical-speed-hold");
      setprop("autopilot/settings/true-heading-deg", courseWP);
      setprop("autopilot/settings/vertical-speed-fpm", verticalSpeed);
    } else {
      setprop("autopilot/locks/heading", "");
    }
    if (distanceWP < 1) {
      currentWPIndex += 1;
    }
  }

  settimer(main, 0, 0);
}

main();

# var listener = setlistener("autopilot/route-manager/distance-remaining-nm", func(n){
#   var lastWPIndex = (getprop("autopilot/route-manager/route/num")-1);
#   var currentWPIndex = getprop("autopilot/route-manager/current-wp");
#   var agl = getprop("position/gear-agl-ft");

#   ####################################################################################################
#   airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
#   rwy = getprop("autopilot/route-manager/destination/runway");
#   var lon = airport.runways[rwy].lon;
#   var lat = airport.runways[rwy].lat;
#   var (course, dist) = courseAndDistance({lat: lat, lon: lon});
#   # var pos = greatCircleMove(course, dist);
#   # debug.dump(pos);
#   print("Turn to heading ", sprintf("%.2f", course), ". You have ", sprintf("%.2f", dist), " nm to go");
#   print("Runway heading ", sprintf("%.2f", airport.runways[rwy].heading));
#   ####################################################################################################

#   if (currentWPIndex == lastWPIndex) {
    
#     if (n.getValue() > 0.5) {
#       var difHeading = course - airport.runways[rwy].heading;
#       var newHeading = 0;
#       if (difHeading > 5 or difHeading < -5) {
#         newHeading = difHeading > 0 ? course + 5 : course - 5;
#       } elsif (difHeading > 0.5 or difHeading < -0.5) {
#         newHeading = difHeading > 0 ? getprop("autopilot/route-manager/wp/bearing-deg") + 1 : getprop("autopilot/route-manager/wp/bearing-deg") - 1;
#       } else {
#         newHeading = getprop("autopilot/route-manager/wp/bearing-deg");
#       }
#       setprop("autopilot/locks/heading", "dg-heading-hold");
#       setprop("autopilot/settings/heading-bug-deg", newHeading);
#       print('runway: ', rwy, ', heading: ', airport.runways[rwy].heading);
#       print('atual heading: ', getprop("autopilot/route-manager/wp/true-bearing-deg"));
#       print('difHeading: ', difHeading);
#     }

#     # dc6b.message.write("Route Manager - Last Waypoint: " ~ getprop("autopilot/route-manager/route/wp["~lastWPIndex~"]/id"));
#     var difAltitude = getprop("position/altitude-ft") - getprop("autopilot/route-manager/destination/field-elevation-ft");
#     var fpm = (difAltitude / (getprop("autopilot/route-manager/ete"))) * 60;
#     if (n.getValue() <= 5.5 and agl > 10) {
#       setprop("autopilot/settings/vertical-speed-fpm", fpm * -1);
#       setprop("autopilot/locks/altitude", "vertical-speed-hold");
#     }
#     if (difAltitude > 50) {
#       setprop("autopilot/settings/target-speed-kt", 120);
#       setprop("controls/flight/flaps", 1);
#     }
#     if (agl < 10 and agl > 1) {
#       setprop("autopilot/settings/vertical-speed-fpm", 100);
#       setprop("autopilot/settings/target-speed-kt", 0);
#     }
#     if (agl < 1) {
#       setprop("autopilot/locks/altitude", "");
#       setprop("autopilot/locks/heading", "");
#       setprop("autopilot/locks/speed", "");
#       setprop("controls/flight/aileron", 0);
#       setprop("controls/flight/elevator", 0);
#       setprop("controls/flight/rudder", 0);
#     }
#     setprop("controls/gear/gear-down", 'true');
#   } else {
#     if (agl > 500) {
#       setprop("controls/gear/gear-down", 'false');
#     }
#     if (currentWPIndex == 0) {
#       setprop("autopilot/route-manager/current-wp", currentWPIndex += 1);
#     }
#     if (currentWPIndex == 1 and getprop("velocities/airspeed-kt") > 100) {
#       setprop("autopilot/settings/vertical-speed-fpm", 1500);
#       setprop("autopilot/locks/altitude", "vertical-speed-hold");
#     }
#     if (getprop("autopilot/route-manager/wp/eta-seconds") != nil and getprop("autopilot/route-manager/wp/eta-seconds") < (getprop("velocities/airspeed-kt") / 10)) {
#       setprop("autopilot/route-manager/current-wp", currentWPIndex += 1);
#       setprop("autopilot/locks/altitude", "altitude-hold");
#     }
#     if (currentWPIndex == (lastWPIndex -2)) {
#       setprop("autopilot/settings/target-speed-kt", 150);
#       setprop("controls/flight/flaps", 0.7);
#     }
#     # dc6b.message.write("Route Manager - Waypoint: " ~ getprop("autopilot/route-manager/route/wp["~currentWPIndex~"]/id"));
#   }
# }, 0, 0);