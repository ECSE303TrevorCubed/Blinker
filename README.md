This is a sample code using WiringPi library.

WiringPi library has already been installed on all pi's. 
When writing C code, don't forget to

    #include <wiringPi.h>

To compile a source code depending on WiringPi library

    gcc blink.c -o blink -lwiringPi

a) At first, we will not using any button, but the sample code requires button input. 
Please modify the code accordingly.

b) Running the code directly, or incorrect modification could freeze the whole RPi. 
Even the basic system interrupts would be ignored. (Keyboard and mouse not scanned by the system.) 
You really have to pull the power cord after RPi is frozen up.

===========================================================================

The sample code is using hardware PWM (Pulse-Width Modulation). 
If you want to use software PWM, please do the following

1.  At the beginning, #include <softPwm.h>

2. Initialize the pin, softPwmCreate(22, 20, 100); // The first parameter, 22, is pin#. 
The second, 20, is "on" time proportion. The third, 100, is maximum "on" proportion. 100 is fully on. 
This function call initializes PWM as 20% duty cycle, 100% duty cycle maximum. 
You can constrain maximum duty cycle by providing a smaller number, 
such as 80, as the third parameter.
    
3. Change duty cycle, softPwmWrite(22, 80, 100); //Change duty cycle to 80%.

Please refer to official documentation for more details.
https://projects.drogon.net/raspberry-pi/wiringpi/software-pwm-library/
