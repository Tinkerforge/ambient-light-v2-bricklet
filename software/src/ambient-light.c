/* ambient-light-v2-bricklet
 * Copyright (C) 2015 Olaf Lüke <olaf@tinkerforge.com>
 *
 * ambient-light.c: Implementation of Ambient Light Bricklet messages
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include "ambient-light.h"

#include "bricklib/bricklet/bricklet_communication.h"
#include "bricklib/utility/util_definitions.h"
#include "bricklib/drivers/adc/adc.h"
#include "brickletlib/bricklet_entry.h"
#include "brickletlib/bricklet_simple.h"
#include "config.h"

#define CH0 1
#define CH1 0

#define I2C_HALF_CLOCK_400KHZ 1250  // 2.5us per clock

#define SIMPLE_UNIT_ILLUMINANCE 0

const SimpleMessageProperty smp[] = {
	{SIMPLE_UNIT_ILLUMINANCE, SIMPLE_TRANSFER_VALUE, SIMPLE_DIRECTION_GET}, // TYPE_GET_ILLUMINANCE
	{SIMPLE_UNIT_ILLUMINANCE, SIMPLE_TRANSFER_PERIOD, SIMPLE_DIRECTION_SET}, // TYPE_SET_ILLUMINANCE_CALLBACK_PERIOD
	{SIMPLE_UNIT_ILLUMINANCE, SIMPLE_TRANSFER_PERIOD, SIMPLE_DIRECTION_GET}, // TYPE_GET_ILLUMINANCE_CALLBACK_PERIOD
	{SIMPLE_UNIT_ILLUMINANCE, SIMPLE_TRANSFER_THRESHOLD, SIMPLE_DIRECTION_SET}, // TYPE_SET_ILLUMINANCE_CALLBACK_THRESHOLD
	{SIMPLE_UNIT_ILLUMINANCE, SIMPLE_TRANSFER_THRESHOLD, SIMPLE_DIRECTION_GET}, // TYPE_GET_ILLUMINANCE_CALLBACK_THRESHOLD
	{0, SIMPLE_TRANSFER_DEBOUNCE, SIMPLE_DIRECTION_SET}, // TYPE_SET_DEBOUNCE_PERIOD
	{0, SIMPLE_TRANSFER_DEBOUNCE, SIMPLE_DIRECTION_GET}, // TYPE_GET_DEBOUNCE_PERIOD
};

const SimpleUnitProperty sup[] = {
	{NULL, SIMPLE_SIGNEDNESS_INT, FID_ILLUMINANCE, FID_ILLUMINANCE_REACHED, SIMPLE_UNIT_ILLUMINANCE}, // illuminance
};

const uint8_t smp_length = sizeof(smp);

void invocation(const ComType com, const uint8_t *data) {
	switch(((SimpleStandardMessage*)data)->header.fid) {
		case FID_SET_CONFIGURATION: {
			set_configuration(com, (SetConfiguration*)data);
			return;
		}

		case FID_GET_CONFIGURATION: {
			get_configuration(com, (GetConfiguration*)data);
			return;
		}

		default: {
			simple_invocation(com, data);
			break;
		}
	}

	if(((MessageHeader*)data)->fid > FID_LAST) {
		BA->com_return_error(data, sizeof(MessageHeader), MESSAGE_ERROR_CODE_NOT_SUPPORTED, com);
	}
}

void constructor(void) {
	_Static_assert(sizeof(BrickContext) <= BRICKLET_CONTEXT_MAX_SIZE, "BrickContext too big");

	PIN_SCL.type = PIO_INPUT;
	PIN_SCL.attribute = PIO_PULLUP;
	BA->PIO_Configure(&PIN_SCL, 1);

	PIN_SDA.type = PIO_INPUT;
	PIN_SDA.attribute = PIO_PULLUP;
	BA->PIO_Configure(&PIN_SCL, 1);

	BC->data_counter = 0;
	BC->integration_time = INTEGRATION_TIME_200MS;
	BC->illuminance_range = RANGE_8000LUX;
	BC->throw_next_data_away = false;
	// Sleep 100ms before and 10ms after initial init (see p22)
	SLEEP_MS(100);
	update_configuration();
	SLEEP_MS(10);

	simple_constructor();
}

void destructor(void) {
	simple_destructor();
}

void tick(const uint8_t tick_type) {
	if(tick_type & TICK_TASK_TYPE_CALCULATION) {
		BC->data_counter++;
		if(BC->data_counter >= 10) {
			uint8_t status;
			ltr_329_read_registers(REG_ALS_STATUS, &status, 1);

			// Check if new data is available and valid
			if((status & (1 << 2)) /*&& (!(status & (1 << 7)))*/) {
				// Read both channels
				uint16_t data[2];
				ltr_329_read_registers(REG_ALS_DATA_CH1, (uint8_t *)&data, 4);
				if(BC->throw_next_data_away) {
					BC->throw_next_data_away = false;
				} else {
					update_values(data, status);
				}
			}
		}
	}

	simple_tick(tick_type);
}

void update_values(const uint16_t values[2], const uint8_t status) {
	// See Appendix A for Lux calculation from channel 0 and 1 measurements

	uint32_t lux = 0;
	uint32_t ratio = (values[CH1]*1000)/(values[CH0]+values[CH1]);
	if(ratio < 450) {
		lux = (values[CH0]*17743 + values[CH1]*11059);
	} else if(ratio < 640 && ratio >= 450) {
		lux = (values[CH0]*42785 - values[CH1]*19548);
	} else if(ratio < 850 && ratio >= 640) {
		lux = (values[CH0]*5926 + values[CH1]*1185);
	}

	uint32_t divider = 1;
	uint32_t multiplier = 1;

	switch((status >> 4) & 0x7) {
		case RANGE_64000LUX: divider = 1;     break;
		case RANGE_32000LUX: divider = 2;     break;
		case RANGE_16000LUX: divider = 4;     break;
		case RANGE_8000LUX:  divider = 8;     break;
		case RANGE_1300LUX:  divider = 48;    break;
		case RANGE_600LUX:   divider = 96;    break;
	}

	switch(BC->integration_time) {
		case 0:               multiplier = 2; break;
		case 1:                               break;
		case 2: divider *= 3; multiplier = 2; break;
		case 3: divider *= 2;                 break;
		case 4: divider *= 5; multiplier = 2; break;
		case 5: divider *= 3;                 break;
		case 6: divider *= 7; multiplier = 2; break;
		case 7: divider *= 4;                 break;
	}

	BC->value[0] = lux/(divider*100/multiplier);  // Calculate lux

	// Cap lux measurement for each range to defined maximum if data invalid bit is set
	if(status & (1 << 7)) {
		switch(BC->illuminance_range) {
			case 5: BC->value[0] = MIN(BC->value[0],   60000); break;
			case 4: BC->value[0] = MIN(BC->value[0],  130000); break;
			case 3: BC->value[0] = MIN(BC->value[0],  800000); break;
			case 2: BC->value[0] = MIN(BC->value[0], 1600000); break;
			case 1: BC->value[0] = MIN(BC->value[0], 3200000); break;
			case 0: BC->value[0] = MIN(BC->value[0], 6400000); break;
		}
	}
}

void set_configuration(const ComType com, const SetConfiguration *data) {
	if((data->integration_time > 7) || (data->illuminance_range > 5)) {
		BA->com_return_error(data, sizeof(MessageHeader), MESSAGE_ERROR_CODE_INVALID_PARAMETER, com);
		return;
	}

	BC->integration_time = data->integration_time;
	BC->illuminance_range = data->illuminance_range;
	update_configuration();
	BC->throw_next_data_away = true;

	BA->com_return_setter(com, data);
}

void get_configuration(const ComType com, const GetConfiguration *data) {
	GetConfigurationReturn gcr;
	gcr.header            = data->header;
	gcr.header.length     = sizeof(GetConfigurationReturn);
	gcr.integration_time  = BC->integration_time;
	gcr.illuminance_range = BC->illuminance_range;

	BA->send_blocking_with_timeout(&gcr, sizeof(GetConfigurationReturn), com);
}

void update_configuration(void) {
	uint8_t range = RANGE_8000LUX;
	switch(BC->illuminance_range) {
		case 0: range = RANGE_64000LUX; break;
		case 1: range = RANGE_32000LUX; break;
		case 2: range = RANGE_16000LUX; break;
		case 3: range = RANGE_8000LUX; break;
		case 4: range = RANGE_1300LUX; break;
		case 5: range = RANGE_600LUX; break;
	}

	uint8_t time = INTEGRATION_TIME_200MS;
	switch(BC->integration_time) {
		case 0: time = INTEGRATION_TIME_50MS; break;
		case 1: time = INTEGRATION_TIME_100MS; break;
		case 2: time = INTEGRATION_TIME_150MS; break;
		case 3: time = INTEGRATION_TIME_200MS; break;
		case 4: time = INTEGRATION_TIME_250MS; break;
		case 5: time = INTEGRATION_TIME_300MS; break;
		case 6: time = INTEGRATION_TIME_350MS; break;
		case 7: time = INTEGRATION_TIME_400MS; break;
	}

	// Enable ALS and set gain
	ltr_329_write_register(REG_ALS_CONTR, (range << 2) | (1 << 0));
	// Set integration time
	ltr_329_write_register(REG_ALS_MEAS_RATE, (time << 3));
}

void ltr_329_read_registers(const uint8_t reg, uint8_t *data, const uint8_t length) {
	i2c_start();
	i2c_send_byte((I2C_ADDRESS_LTR329 << 1) | I2C_WRITE);
	i2c_send_byte(reg);
	i2c_stop();

	i2c_start();
	i2c_send_byte((I2C_ADDRESS_LTR329 << 1) | I2C_READ);
	for(uint8_t i = 0; i < length; i++) {
		data[i] = i2c_recv_byte(i != (length - 1));
	}
	i2c_stop();
}

void ltr_329_write_register(const uint8_t reg, const uint8_t value) {
	i2c_start();
	i2c_send_byte((I2C_ADDRESS_LTR329 << 1) | I2C_WRITE);
	i2c_send_byte(reg);
	i2c_send_byte(value);
	i2c_stop();
}

bool i2c_scl_value(void) {
	return PIN_SCL.pio->PIO_PDSR & PIN_SCL.mask;
}

void i2c_scl_high(void) {
	PIN_SCL.pio->PIO_ODR = PIN_SCL.mask;
	while(!i2c_scl_value()); // allow slave to clock-stretch
}

void i2c_scl_low(void) {
	PIN_SCL.pio->PIO_OER = PIN_SCL.mask;
}

bool i2c_sda_value(void) {
	return PIN_SDA.pio->PIO_PDSR & PIN_SDA.mask;
}

void i2c_sda_high(void) {
	PIN_SDA.pio->PIO_ODR = PIN_SDA.mask;
}

void i2c_sda_low(void) {
	PIN_SDA.pio->PIO_OER = PIN_SDA.mask;
}

void i2c_sleep_halfclock(void) {
	SLEEP_NS(I2C_HALF_CLOCK_400KHZ);
}

void i2c_stop(void) {
	i2c_scl_low();
	i2c_sda_low();
	i2c_sleep_halfclock();
	i2c_scl_high();
	i2c_sleep_halfclock();
	i2c_sda_high();
	i2c_sleep_halfclock();
}

void i2c_start(void) {
	i2c_scl_high();
	i2c_sleep_halfclock();
	i2c_sda_low();
	i2c_sleep_halfclock();
}

uint8_t i2c_recv_byte(bool ack) {
	uint8_t value = 0;

	for(int8_t i = 7; i >= 0; i--) {
		i2c_scl_low();
		i2c_sda_high(); // allow slave to read
		i2c_sleep_halfclock();
		i2c_scl_high();
		if(i2c_sda_value()) {
			value |= (1 << i);
		}
		i2c_sleep_halfclock();
	}

	// ACK
	i2c_scl_low();
	if(ack) {
		i2c_sda_low();
	} else {
		i2c_sda_high();
	}
	i2c_sleep_halfclock();
	i2c_scl_high();
	i2c_sleep_halfclock();

	return value;
}

bool i2c_send_byte(const uint8_t value) {
	for(int8_t i = 7; i >= 0; i--) {
		i2c_scl_low();
		if((value >> i) & 1) {
			i2c_sda_high();
		} else {
			i2c_sda_low();
		}
		i2c_sleep_halfclock();
		i2c_scl_high();
		i2c_sleep_halfclock();
	}

	i2c_sda_high(); // Make sure SDA is always released

	// Wait for ACK
	bool ret = false;

	i2c_scl_low();
	i2c_sleep_halfclock();
	i2c_scl_high();
	if(!i2c_sda_value()) {
		ret = true;
	}

	i2c_sleep_halfclock();

	return ret;
}
