# for yasim help with the pushback function 

var proprev_enable	= props.globals.getNode("/controls/engines/reverser_allow");
var proprev_controls	= props.globals.getNode("/engines/engine[0]/running");

setlistener("/controls/engines/engine[0]/throttle", func(throttle) {
    var throttle = throttle.getValue();  
    if (proprev_enable.getBoolValue()) {
      setprop("/sim/model/pushback/target-speed-fps", -throttle );
    }
});

var window = screen.window.new(); # criado por Julio Junkes: exibir mensagens para o piloto
window.fg = [1, 1, 1, 1];
window.bg = [0, 0, 0, 0.8];

# Enabled , disabled prop reverser 
toggle_reverse_lockout = func {
  if (!proprev_enable.getValue()) {					# Disabled, toggle to enable
    proprev_enable.setValue(1);
    props.globals.getNode("/sim/model/pushback/enabled", 1 ).setBoolValue(1);
    props.globals.initNode("/sim/model/pushback/target-speed-fps", (getprop("engines/engine[0]/throttle") or 1)*-1 );
    setprop("controls/engines/engine[0]/propeller-pitch", 0);
    setprop("controls/engines/engine[1]/propeller-pitch", 0);
    setprop("controls/engines/engine[2]/propeller-pitch", 0);
    setprop("controls/engines/engine[3]/propeller-pitch", 0);
    setprop("/sim/model/pushback/target-speed-fps", (getprop("engines/engine[0]/throttle") or 1)*-1);
    setprop("/sim/model/pushback/force", 1);
    window.write("Reverse on!");
    window.write("Reverse on! Setting propeller-pitch: " ~ getprop("engines/engine[0]/propeller-pitch"));
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
      window.write("Engines propeller-pitch set to " ~ getprop("engines/engine[0]/propeller-pitch"));
    }, 5);
    dc6b.switch5SoundToggle();
    window.write("Reverse off!");
    
    window.write("Reverse off! Setting propeller-pitch: " ~  getprop("engines/engine[0]/propeller-pitch"));
  }
}

# pitch set to 0 and set throttle as target-speed-fps
toggle_prop_reverse = func {
  if (!proprev_enable.getValue()) { return; }				# Can't toggle reverse if locked out
  if (proprev_controls.getValue()) {		# Using eng 1 as master

      # if(getprop("controls/engines/engine[0]/propeller-pitch") == 1){
      #   setprop("controls/engines/engine[0]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[1]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[2]/propeller-pitch", 0);
      #   setprop("controls/engines/engine[3]/propeller-pitch", 0);
      #   dc6b.switch6SoundToggle();
      # }else{
      #   setprop("controls/engines/engine[0]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[1]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[2]/propeller-pitch", 1);
      #   setprop("controls/engines/engine[3]/propeller-pitch", 1);
      #   dc6b.switch6SoundToggle();
      # }

  }
}

################################################### Adicionado por Julio Junkes #########################################################

setlistener("instrumentation/airspeed-indicator/indicated-speed-kt", func(kt) {

  # if speed lower then 10 kt, reverse off!
  if( proprev_enable.getValue() and proprev_controls.getValue() and kt.getValue() < 10 ) {
    window.write("Speed " ~ kt.getValue());
    # proprev_enable.setValue(0);
    # setprop("/sim/model/pushback/enabled", 0 );
    # setprop("/sim/model/pushback/target-speed-fps", 0 );
    # setprop("/sim/model/pushback/force", 0);

    toggle_reverse_lockout();

    # throttle set to 0
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    window.write("Setting throttle: " ~ getprop("controls/engines/engine[0]/throttle"));
  }
  
});

var voando = 0;

setlistener("position/gear-agl-ft", func(ft) {
  var kt = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  if (ft.getValue() > 500 and voando == 0) {
    voando = 1;
    window.write("500 agl reached...");
  } else {
    if (voando == 1 and ft.getValue() < 500) {
      voando = 2;
      window.write("500 agl reached...");
    }
  }

  if (getprop("autopilot/switches/ap") and ft.getValue() < 30 and voando > 0 and kt > 10) {
    setprop("autopilot/locks/altitude", 'altitude-hold');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    setprop("controls/engines/engine[0]/throttle", 0);
    setprop("controls/engines/engine[1]/throttle", 0);
    setprop("controls/engines/engine[2]/throttle", 0);
    setprop("controls/engines/engine[3]/throttle", 0);
    window.write("Setting throttle: " ~ getprop("controls/engines/engine[0]/throttle"));
    window.write("Landing...");
  }
  
  if (ft.getValue() < 2 and voando > 0 and kt > 10) {
    voando = 0;

    setprop("autopilot/locks/altitude", '');
    setprop("autopilot/locks/heading", '');
    setprop("autopilot/locks/speed", '');
    window.write("Autopilot off ...");
    
    setprop("controls/flight/aileron", 0);
    setprop("controls/flight/aileron-trim", 0);
    setprop("controls/flight/elevator", 0);
    setprop("controls/flight/elevator-trim", 0);
    setprop("controls/flight/rudder", 0);
    setprop("controls/flight/rudder-trim", 0);
    setprop("controls/flight/flaps", 0);
    window.write("Controls and trims centralizeds...");

    settimer(func(){
      # reverse start...
      toggle_reverse_lockout();

      # throttle set to 1...
      setprop("controls/engines/engine[0]/throttle", 1);
      setprop("controls/engines/engine[1]/throttle", 1);
      setprop("controls/engines/engine[2]/throttle", 1);
      setprop("controls/engines/engine[3]/throttle", 1);
      window.write("Setting throttle: " ~ getprop("controls/engines/engine[0]/throttle"));
    }, 5);
  }
});
