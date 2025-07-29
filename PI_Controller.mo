model PI_Controller "Demonstrates the usage of a Continuous.LimPID controller"
  extends Modelica.Icons.Example;
  parameter Modelica.Units.SI.Angle driveAngle = 1.570796326794897 "Reference distance to move";
  Modelica.Blocks.Continuous.LimPID PI(k = 100, Ti = 0.1, yMax = 12, Ni = 0.1, initType = Modelica.Blocks.Types.Init.SteadyState, controllerType = Modelica.Blocks.Types.SimpleController.PI, limiter(u(start = 0)), Td = 0.1) annotation(
    Placement(transformation(origin = {56, -8}, extent = {{-56, -20}, {-36, 0}})));
  Modelica.Blocks.Sources.KinematicPTP kinematicPTP(startTime = 0.5, deltaq = {driveAngle}, qd_max = {1}, qdd_max = {1}) annotation(
    Placement(transformation(origin = {56, -8}, extent = {{-92, 20}, {-72, 40}})));
  Modelica.Blocks.Continuous.Integrator integrator(initType = Modelica.Blocks.Types.Init.InitialState) annotation(
    Placement(transformation(origin = {56, -8}, extent = {{-63, 20}, {-43, 40}})));
  Modelica.Blocks.Interfaces.RealInput Sensor annotation(
    Placement(transformation(origin = {-76, -68}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-38, -30}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Blocks.Interfaces.RealOutput Aktor annotation(
    Placement(transformation(origin = {82, -18}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {52, -18}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(kinematicPTP.y[1], integrator.u) annotation(
    Line(points = {{-15, 22}, {-9, 22}}, color = {0, 0, 127}));
  connect(integrator.y, PI.u_s) annotation(
    Line(points = {{14, 22}, {19, 22}, {19, 3}, {-11, 3}, {-11, -18}, {-2, -18}}, color = {0, 0, 127}));
  connect(PI.u_m, Sensor) annotation(
    Line(points = {{10, -30}, {-24, -30}, {-24, -68}, {-76, -68}}, color = {0, 0, 127}));
  connect(PI.y, Aktor) annotation(
    Line(points = {{22, -18}, {82, -18}}, color = {0, 0, 127}));
  annotation(
    Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(origin = {56, -8}, lineColor = {255, 0, 0}, extent = {{-99, 48}, {-32, 8}}), Text(origin = {56, -8}, textColor = {255, 0, 0}, extent = {{-98, 59}, {-31, 51}}, textString = "reference speed generation"), Text(origin = {56, -8}, textColor = {255, 0, 0}, extent = {{-98, -46}, {-60, -52}}, textString = "PI controller"), Line(origin = {56, -8}, points = {{-76, -44}, {-57, -23}}, color = {255, 0, 0}, arrow = {Arrow.None, Arrow.Filled})}),
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
  __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
  __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"));
end PI_Controller;
