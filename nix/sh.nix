{
  writeShellApplication,
  wiringpi,
  ...
}:
writeShellApplication {
  name = "blink";
  text = builtins.readFile ../sh/main.sh;
  runtimeInputs = [
    wiringpi
  ];
}
