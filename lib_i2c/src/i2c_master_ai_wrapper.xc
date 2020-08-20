#include "i2c.h"
#include "i2c_xcore_ai.h"
#include <print.h>
#include <xccompat.h>
#include <string.h>



i2c_res_t i2c_master_write(uint8_t device_addr, uint8_t buf[n], size_t n,
           size_t *num_bytes_sent, int send_stop_bit, 
           i2c_master_config_t *config){
    interface i2c_master_if i_i2c[1];
    i2c_res_t result;
    par{
        {
            result = i_i2c[0].write(device_addr, buf, n, *num_bytes_sent, send_stop_bit);
            i_i2c[0].shutdown();
        }
        [[distribute]]
        i2c_master(i_i2c, 1, config->p_scl, config->p_sda, 100/*config->kbits_per_second*/);
    }
    return result;
}

i2c_res_t i2c_master_read(uint8_t device_addr, uint8_t buf[n], size_t n,
           int send_stop_bit, i2c_master_config_t *config){
    interface i2c_master_if i_i2c[1];
    i2c_res_t result;
    par{
        {
            result = i_i2c[0].read(device_addr, buf, n, send_stop_bit);
            i_i2c[0].shutdown();
        }
        [[distribute]]
        i2c_master(i_i2c, 1, config->p_scl, config->p_sda, 100/*config->kbits_per_second*/);
    }
    return result;
}

void i2c_master_send_stop_bit(i2c_master_config_t *config){
    interface i2c_master_if i_i2c[1];
    par{
        {
            i_i2c[0].send_stop_bit();
            i_i2c[0].shutdown();
        }
        [[distribute]]
        i2c_master(i_i2c, 1, config->p_scl, config->p_sda, 100/*config->kbits_per_second*/);
    }

}

// i2c_regop_res_t i2c_master_write_reg_ai(uint8_t device_addr, uint8_t reg, uint8_t data,
//                                     i2c_master_config_t *config){
//     interface i2c_master_if i_i2c[1];
//     i2c_regop_res_t result;
//     par{
//         {
//             result = i_i2c[0].write_reg(device_addr, reg, data);
//             i_i2c[0].shutdown();
//         }
//         [[distribute]]
//         i2c_master(i_i2c, 1, config->p_scl, config->p_sda, 100/*config->kbits_per_second*/);
//     }
//     return result;
// }

// uint8_t i2c_master_read_reg_ai(uint8_t device_addr, uint8_t reg, i2c_regop_res_t *result,
//                                     i2c_master_config_t *config){
//     interface i2c_master_if i_i2c[1];
//     uint8_t read_data;
//     par{
//         {
//             read_data = i_i2c[0].read_reg(device_addr, reg, *result);
//             i_i2c[0].shutdown();
//         }
//         [[distribute]]
//         i2c_master(i_i2c, 1, config->p_scl, config->p_sda, 100/*config->kbits_per_second*/);
//     }
//     return read_data;
// }