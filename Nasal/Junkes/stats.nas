var display = screen.display.new(20, 10);
display.setcolor(1, 0, 0);
display.setfont("SANS_12B", 12);
display.interval = 0;
display.format = "%.4g";
display.redraw();

var stats = 0;

var showStats = func {
  display.add("position/gear-agl-ft");
  display.add("position/altitude-ft");
  display.add("junkes/current-vertical-speed");
  display.add("velocities/airspeed-kt");
  display.add("controls/flight/flaps");
  display.add("consumables/fuel/total-fuel-norm");
  # display.add("controls/engines/engine/throttle");
  # display.add("controls/engines/engine/mixture");
  # display.add("controls/engines/engine/propeller-pitch");
  display.add("autopilot/route-manager/destination/field-elevation-ft");
  display.add("autopilot/route-manager/route/num");
  display.add("junkes/current-wp");
  display.add("junkes/current-wp-index");
  display.add("junkes/current-wp-lat");
  display.add("junkes/current-wp-lon");
  display.add("junkes/current-wp-dist");
  display.add("junkes/current-wp-course");
  display.add("junkes/rwy-dist");
  display.add("junkes/rwy-course");
  stats = 1;
}

var hideStats = func {
  display.reset();
  stats = 0;
}

var toogleStats = func {
  if (stats) {
    hideStats();
  } else {
    showStats();
  }
}

showStats();