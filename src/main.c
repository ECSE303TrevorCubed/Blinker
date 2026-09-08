#include <stdbool.h> // Used for 'true'
#include <wiringPi.h> // Include WiringPi library!

const int ledPin = 25;

int main(void)
{
    // Setup stuff:
    wiringPiSetupGpio(); // Initialize wiringPi -- using Broadcom pin numbers

    pinMode(ledPin, OUTPUT);     // Set regular LED as output

    while (true) {
        digitalWrite(ledPin, LOW);
        delay(500);
        digitalWrite(ledPin, HIGH);
        delay(500);
    }

    return 0;
}
