#include <stdio.h>
#include <stdint.h>

/* PIO map from nios_system.qsys (data master map). */
#define MOTOR_RIGHT_BASE      0x00000000
#define MOTOR_LEFT_BASE       0x00000010
#define SENSOR_READY_BASE     0x00000020
#define SENSOR_THRESHOLD_BASE 0x00000040
#define SENSOR_VECTOR_BASE    0x00000050
#define LED_STATUS_BASE       0x00003000
#define START_SWITCH_BASE     0x00003010

#define REG32(addr) (*(volatile uint32_t *)(addr))

/* Motor frame: bit13 go/stop, bit12 direction, bits11..0 duty cycle. */
static uint16_t pack_motor_cmd(uint16_t duty, uint8_t direction, uint8_t go)
{
    if (duty > 4095U)
    {
        duty = 4095U;
    }

    return (uint16_t)(((go & 0x1U) << 13) | ((direction & 0x1U) << 12) | duty);
}

/* Weighted line position in [-3..3]. Positive means line on right side. */
static int32_t compute_pos_from_vector(uint32_t sensor_vector)
{
    static const int32_t w[7] = {-3, -2, -1, 0, 1, 2, 3};
    int32_t sum = 0;
    int32_t count = 0;
    int i;

    for (i = 0; i < 7; ++i)
    {
        if ((sensor_vector >> i) & 0x1U)
        {
            sum += w[i];
            count++;
        }
    }

    if (count == 0)
    {
        return 0;
    }

    return sum / count;
}

int main(void)
{
    const uint16_t base_speed = 1500U;
    const int32_t kp = 90;
    const uint8_t no_line_limit = 40;

    uint32_t threshold = 104U;
    uint8_t start_sl = 0U;
    uint8_t fin_sl = 0U;
    uint8_t no_line_count = 0U;

    printf("V4 line follow\n");
    REG32(SENSOR_THRESHOLD_BASE) = threshold;

    while (1)
    {
        uint32_t ready = REG32(SENSOR_READY_BASE) & 0x01U;
        start_sl = (uint8_t)(REG32(START_SWITCH_BASE) & 0x01U);

        if (!start_sl)
        {
            fin_sl = 0U;
            no_line_count = 0U;
            REG32(MOTOR_RIGHT_BASE) = pack_motor_cmd(0U, 0U, 0U);
            REG32(MOTOR_LEFT_BASE) = pack_motor_cmd(0U, 0U, 0U);
            REG32(LED_STATUS_BASE) = 0U;
            continue;
        }

        if (ready)
        {
            uint32_t sensor_vector = REG32(SENSOR_VECTOR_BASE) & 0x7FU;

            if (sensor_vector == 0U)
            {
                if (no_line_count < 255U)
                {
                    no_line_count++;
                }
            }
            else
            {
                no_line_count = 0U;
            }

            if (no_line_count >= no_line_limit)
            {
                fin_sl = 1U;
                REG32(MOTOR_RIGHT_BASE) = pack_motor_cmd(0U, 0U, 0U);
                REG32(MOTOR_LEFT_BASE) = pack_motor_cmd(0U, 0U, 0U);
            }
            else
            {
                int32_t pos = compute_pos_from_vector(sensor_vector);
                int32_t bias = kp * pos;
                int32_t right = (int32_t)base_speed + bias;
                int32_t left = (int32_t)base_speed - bias;

                if (right < 0)
                {
                    right = 0;
                }
                if (right > 4095)
                {
                    right = 4095;
                }
                if (left < 0)
                {
                    left = 0;
                }
                if (left > 4095)
                {
                    left = 4095;
                }

                REG32(MOTOR_RIGHT_BASE) = pack_motor_cmd((uint16_t)right, 0U, 1U);
                REG32(MOTOR_LEFT_BASE) = pack_motor_cmd((uint16_t)left, 0U, 1U);
                fin_sl = 0U;
            }

            /* LED[0] = start_SL, LED[1] = fin_SL */
            REG32(LED_STATUS_BASE) = (uint32_t)(start_sl | (fin_sl << 1));
        }
    }

    return 0;
}
