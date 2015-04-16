/* ambient-light-v2-bricklet
 * Copyright (C) 2015 Olaf Lüke <olaf@tinkerforge.com>
 *
 * ambient-light.h: Implementation of Ambient Light Bricklet messages
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

#ifndef AMBIENT_LIGHT_H
#define AMBIENT_LIGHT_H

#include <stdint.h>
#include "bricklib/com/com_common.h"

#define REG_ALS_CONTR     0x80
#define REG_ALS_MEAS_RATE 0x85
#define REG_PART_ID       0x86
#define REG_MANUFAC_ID    0x87
#define REG_ALS_DATA_CH1  0x88 // 2 bytes
#define REG_ALS_DATA_CH0  0x8A // 2 bytes
#define REG_ALS_STATUS    0x8C

#define RANGE_64000LUX 0
#define RANGE_32000LUX 1
#define RANGE_16000LUX 2
#define RANGE_8000LUX  3
#define RANGE_1300LUX  6
#define RANGE_600LUX   7

#define INTEGRATION_TIME_100MS 0
#define INTEGRATION_TIME_50MS  1
#define INTEGRATION_TIME_200MS 2
#define INTEGRATION_TIME_400MS 3
#define INTEGRATION_TIME_150MS 4
#define INTEGRATION_TIME_250MS 5
#define INTEGRATION_TIME_300MS 6
#define INTEGRATION_TIME_350MS 7

#define I2C_EEPROM_ADDRESS_HIGH 84

#define I2C_ADDRESS_LTR329 0x29 // 0b0101001
#define I2C_INTERNAL_ADDRESS_BYTES 1
#define I2C_DATA_LENGTH 1

#define I2C_READ  1
#define I2C_WRITE 0

#define FID_GET_ILLUMINANCE 1
#define FID_SET_ILLUMINANCE_CALLBACK_PERIOD 2
#define FID_GET_ILLUMINANCE_CALLBACK_PERIOD 3
#define FID_SET_ILLUMINANCE_CALLBACK_THRESHOLD 4
#define FID_GET_ILLUMINANCE_CALLBACK_THRESHOLD 5
#define FID_SET_DEBOUNCE_PERIOD 6
#define FID_GET_DEBOUNCE_PERIOD 7
#define FID_SET_CONFIGURATION 8
#define FID_GET_CONFIGURATION 9
#define FID_ILLUMINANCE 10
#define FID_ILLUMINANCE_REACHED 11

#define FID_LAST 9

typedef struct {
	MessageHeader header;
	uint8_t illuminance_range;
	uint8_t integration_time;
} __attribute__((__packed__)) SetConfiguration;

typedef struct {
	MessageHeader header;
} __attribute__((__packed__)) GetConfiguration;

typedef struct {
	MessageHeader header;
	uint8_t illuminance_range;
	uint8_t integration_time;
} __attribute__((__packed__)) GetConfigurationReturn;

void set_configuration(const ComType com, const SetConfiguration *data);
void get_configuration(const ComType com, const GetConfiguration *data);

int32_t new_illuminance(const int32_t value);

void invocation(const ComType com, const uint8_t *data);
void constructor(void);
void destructor(void);
void tick(const uint8_t tick_type);

void update_values(const uint16_t *values, const uint8_t status);
void update_configuration(void);

void ltr_329_read_registers(const uint8_t reg, uint8_t *data, const uint8_t length);
void ltr_329_write_register(const uint8_t reg, const uint8_t value);

bool i2c_scl_value(void);
void i2c_scl_high(void);
void i2c_scl_low(void);
bool i2c_sda_value(void);
void i2c_sda_high(void);
void i2c_sda_low(void);
void i2c_sleep_halfclock(void);
void i2c_stop(void);
void i2c_start(void);
uint8_t i2c_recv_byte(bool ack);
bool i2c_send_byte(const uint8_t value);

#endif
