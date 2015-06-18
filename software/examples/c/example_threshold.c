#include <stdio.h>

#include "ip_connection.h"
#include "bricklet_ambient_light_v2.h"

#define HOST "localhost"
#define PORT 4223
#define UID "XYZ" // Change to your UID

// Callback for illuminance greater than 200 Lux
void cb_reached(uint32_t illuminance, void *user_data) {
	(void)user_data; // avoid unused parameter warning

	printf("We have %f Lux.\n", illuminance/100.0);
	printf("Too bright, close the curtains!\n");
}

int main() {
	// Create IP connection
	IPConnection ipcon;
	ipcon_create(&ipcon);

	// Create device object
	AmbientLightV2 al;
	ambient_light_v2_create(&al, UID, &ipcon);

	// Connect to brickd
	if(ipcon_connect(&ipcon, HOST, PORT) < 0) {
		fprintf(stderr, "Could not connect\n");
		exit(1);
	}
	// Don't use device before ipcon is connected

	// Get threshold callbacks with a debounce time of 10 seconds (10000ms)
	ambient_light_v2_set_debounce_period(&al, 10000);

	// Register threshold reached callback to function cb_reached
	ambient_light_v2_register_callback(&al,
	                                   AMBIENT_LIGHT_V2_CALLBACK_ILLUMINANCE_REACHED,
	                                   (void *)cb_reached,
	                                   NULL);

	// Configure threshold for "greater than 200 Lux" (unit is Lux/100)
	ambient_light_v2_set_illuminance_callback_threshold(&al, '>', 200*100, 0);

	printf("Press key to exit\n");
	getchar();
	ipcon_destroy(&ipcon); // Calls ipcon_disconnect internally
}
