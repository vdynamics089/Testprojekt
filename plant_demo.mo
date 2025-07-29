model plant_demo "Demonstrates the usage of a Continuous.LimPID controller"
  extends Modelica.Icons.Example;
  parameter Modelica.Units.SI.Angle driveAngle = 1.570796326794897 "Reference distance to move";
  Modelica.Mechanics.Rotational.Components.Inertia inertia1(phi(fixed = true, start = 0), J = 1, a(fixed = true, start = 0)) annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{2, -20}, {22, 0}})));
  Modelica.Mechanics.Rotational.Sources.Torque torque annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{-25, -20}, {-5, 0}})));
  Modelica.Mechanics.Rotational.Components.SpringDamper spring(c = 1e4, d = 100, stateSelect = StateSelect.prefer) annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{32, -20}, {52, 0}})));
  Modelica.Mechanics.Rotational.Components.Inertia inertia2(J = 2) annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{60, -20}, {80, 0}})));
  Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{22, -50}, {2, -30}})));
  Modelica.Mechanics.Rotational.Sources.ConstantTorque loadTorque(tau_constant = 10, useSupport = false) annotation(
    Placement(transformation(origin = {-42, 16}, extent = {{98, -15}, {88, -5}})));
  Modelica.Blocks.Interfaces.RealInput Aktor annotation(
    Placement(transformation(origin = {-94, 46}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-90, 6}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Blocks.Interfaces.RealOutput Sensor annotation(
    Placement(transformation(origin = {-82, -24}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-76, -22}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(spring.flange_b, inertia2.flange_a) annotation(
    Line(points = {{10, 6}, {18, 6}}));
  connect(inertia1.flange_b, spring.flange_a) annotation(
    Line(points = {{-20, 6}, {-10, 6}}));
  connect(torque.flange, inertia1.flange_a) annotation(
    Line(points = {{-47, 6}, {-40, 6}}));
  connect(speedSensor.flange, inertia1.flange_b) annotation(
    Line(points = {{-20, -24}, {-20, 6}}));
  connect(loadTorque.flange, inertia2.flange_b) annotation(
    Line(points = {{46, 6}, {38, 6}}));
  connect(torque.tau, Aktor) annotation(
    Line(points = {{-68, 6}, {-94, 6}, {-94, 46}}, color = {0, 0, 127}));
  connect(speedSensor.w, Sensor) annotation(
    Line(points = {{-40, -24}, {-82, -24}}, color = {0, 0, 127}));
  annotation(
    Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(origin = {-42, 16}, lineColor = {255, 0, 0}, extent = {{-25, 6}, {99, -50}}), Text(origin = {-42, 16}, textColor = {255, 0, 0}, extent = {{4, 14}, {71, 7}}, textString = "plant (simple drive train)")}),
  experiment(StopTime = 6000, StartTime = 0, Tolerance = 1e-06, Interval = 0.01),
    Documentation(info = "<html>

<p>
This is a simple drive train controlled by a PID controller:
</p>

<ul>
<li> The two blocks \"kinematic_PTP\" and \"integrator\" are used to generate
     the reference speed (= constant acceleration phase, constant speed phase,
     constant deceleration phase until inertia is at rest). To check
     whether the system starts in steady state, the reference speed is
     zero until time = 0.5 s and then follows the sketched trajectory.</li>

<li> The block \"PI\" is an instance of \"Blocks.Continuous.LimPID\" which is
     a PID controller where several practical important aspects, such as
     anti-windup-compensation has been added. In this case, the control block
     is used as PI controller.</li>

<li> The output of the controller is a torque that drives a motor inertia
     \"inertia1\". Via a compliant spring/damper component, the load
     inertia \"inertia2\" is attached. A constant external torque of 10 Nm
     is acting on the load inertia.</li>
</ul>

<p>
The PI controller is initialized in steady state (initType=SteadyState)
and the drive shall also be initialized in steady state.
However, it is not possible to initialize \"inertia1\" in SteadyState, because
\"der(inertia1.phi)=inertia1.w=0\" is an input to the PI controller that
defines that the derivative of the integrator state is zero (= the same
condition that was already defined by option SteadyState of the PI controller).
Furthermore, one initial condition is missing, because the absolute position
of inertia1 or inertia2 is not defined. The solution shown in this examples is
to initialize the angle and the angular acceleration of \"inertia1\".
</p>

<p>
In the following figure, results of a typical simulation are shown:
</p>

<img src=\"modelica://Modelica/Resources/Images/Blocks/Examples/PID_controller.png\"
     alt=\"PID_controller.png\"><br>

<img src=\"modelica://Modelica/Resources/Images/Blocks/Examples/PID_controller2.png\"
     alt=\"PID_controller2.png\">

<p>
In the upper figure the reference speed (= integrator.y) and
the actual speed (= inertia1.w) are shown. As can be seen,
the system initializes in steady state, since no transients
are present. The inertia follows the reference speed quite good
until the end of the constant speed phase. Then there is a deviation.
In the lower figure the reason can be seen: The output of the
controller (PI.y) is in its limits. The anti-windup compensation
works reasonably, since the input to the limiter (PI.limiter.u)
is forced back to its limit after a transient phase.
</p>

</html>"),
    uses(Modelica(version = "4.0.0")),
  __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "euler", variableFilter = ".*"),
  __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian");
end plant_demo;
