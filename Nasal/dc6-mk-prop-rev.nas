# for yasim help with the pushback function 

var proprev_enable	= props.globals.getNode("/controls/engines/reverser_allow");
var proprev_controls	= props.globals.getNode("/engines/engine[0]/running");

setlistener("/controls/engines/engine[0]/throttle", func(throttle) {
    var throttle = throttle.getValue();  
    if (proprev_enable.getBoolValue()) {
      setprop("/sim/model/pushback/target-speed-fps", -throttle );
    }
});

# Enabled , disabled prop reverser 
toggle_reverse_lockout = func {
  if (!proprev_enable.getValue()) {					# Disabled, toggle to enable
    proprev_enable.setValue(1);
    props.globals.getNode("/sim/model/pushback/enabled", 1 ).setBoolValue(1);
    props.globals.initNode("/sim/model/pushback/target-speed-fps", (getprop("/controls/engines/engine[0]/throttle") * -1));
    setprop("controls/engines/engine[0]/propeller-pitch", 0);
    setprop("controls/engines/engine[1]/propeller-pitch", 0);
    setprop("controls/engines/engine[2]/propeller-pitch", 0);
    setprop("controls/engines/engine[3]/propeller-pitch", 0);
    setprop("/sim/model/pushback/force", 1);
    setprop("/sim/model/pushback/target-speed-fps", (getprop("/controls/engines/engine[0]/throttle") * -1));
    dc6b.message.write("Reverse on!");
    dc6b.message.write("Reverse on! Setting propeller-pitch: 0");
    dc6b.switch5SoundToggle();
  } else {						
    proprev_enable.setValue(0);
    setprop("/sim/model/pushback/enabled", 0 );
    setprop("/sim/model/pushback/target-speed-fps", 0 );
    setprop("/sim/model/pushback/force", 0);
    settimer(func(){
      setprop("controls/engines/engine[0]/propeller-pitch", 1);
      setprop("controls/engines/engine[1]/propeller-pitch", 1);
      setprop("controls/engines/engine[2]/propeller-pitch", 1);
      setprop("controls/engines/engine[3]/propeller-pitch", 1);
      junkes.propellerPitch = 1;
      dc6b.message.write("Setting propeller-pitch: 0");
    }, 5);
    dc6b.switch5SoundToggle();
    dc6b.message.write("Reverse off!");
    dc6b.message.write("Reverse off! Setting propeller-pitch: 0");
  }
}

# pitch set to 0 and set throttle as target-speed-fps
toggle_prop_reverse = func {
  return 0;
}

################################################### Adicionado por Julio Junkes #########################################################

setlistener("instrumentation/airspeed-indicator/indicated-speed-kt", func(kt) {

  # if speed lower then 10 kt, reverse off!
  if( proprev_enable.getValue() and proprev_controls.getValue() and kt.getValue() < 30 ) {
    dc6b.message.write("Speed " ~ kt.getValue());

    toggle_reverse_lockout();

    # throttle set to 0
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    dc6b.message.write("Setting throttle: 0");
  }
  
});

var voando = 0;

setlistener("position/gear-agl-ft", func(ft) {
  var kt = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  if (ft.getValue() > 500 and voando == 0) {
    voando = 1;
    dc6b.message.write("500 agl reached...");
  } else {
    if (voando == 1 and ft.getValue() < 500) {
      voando = 2;
      dc6b.message.write("500 agl reached...");
    }
  }

  if (getprop("autopilot/switches/ap") and ft.getValue() < 20 and voando == 2 and kt > 100) {
    voando = 3;
    setprop("autopilot/locks/altitude", 'altitude-hold');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    dc6b.message.write("Setting throttle: 0");
    dc6b.message.write("Landing...");
  }
  
  if (ft.getValue() < 2 and voando == 3 and kt > 10) {
    voando = 0;

    setprop("autopilot/locks/altitude", '');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    dc6b.message.write("Autopilot off ...");
    
    setprop("controls/flight/aileron", 0);
    setprop("controls/flight/aileron-trim", 0);
    setprop("controls/flight/elevator", 0);
    setprop("controls/flight/elevator-trim", 0);
    setprop("controls/flight/rudder", 0);
    setprop("controls/flight/rudder-trim", 0);
    setprop("controls/flight/flaps", 0);
    dc6b.message.write("Controls and trims centralizeds...");

    # reverse start...
    toggle_reverse_lockout();

    settimer(func(){

      # throttle set to 1...
      setprop("controls/engines/engine[0]/throttle", 1);
      setprop("controls/engines/engine[1]/throttle", 1);
      setprop("controls/engines/engine[2]/throttle", 1);
      setprop("controls/engines/engine[3]/throttle", 1);
      dc6b.message.write("Setting throttle: 1");
    }, 3);
  }
});
