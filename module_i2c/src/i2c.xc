///////////////////////////////////////////////////////////////////////////////
//
// I2C master

#include <xs1.h>
#include <stdio.h>
#include "i2c.h"

#ifndef I2C_TI_COMPATIBILITY
int i2c_rd(int addr, int device, struct i2c_data_info &i2c_data, struct r_i2c &i2c)
{
  //   int result;
   timer gt;
   unsigned time;
   int Temp, CtlAdrsData, i,j;
   // three device ACK
   int ack[3];
   int rdData;



   // initial values.
   i2c.scl <: 1;
   i2c.sda  <: 1;
   sync(i2c.sda);
   gt :> time;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> int _;
   // start bit on SDI
   i2c.scl <: 1;
   i2c.sda  <: 0;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;
   // shift 7bits of address and 1bit R/W (fixed to write).
   // WARNING: Assume MSB first.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (device >> (7 - i)) & 0x1;
      i2c.sda <: Temp;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 1;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 0;
   }
   // turn the data to input
   i2c.sda :> Temp;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 1;
   // sample first ACK.
   i2c.sda :> ack[0];
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;

   CtlAdrsData = (addr & 0xFF);

   // shift first 8 bits.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
      i2c.sda <: Temp;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 1;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 0;
   }
   // turn the data to input
   i2c.sda :> Temp;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 1;
   // sample second ACK.
   i2c.sda :> ack[1];
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;


   // stop bit
   gt :> time;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> int _;
   // start bit on SDI
   i2c.scl <: 1;
   i2c.sda  <: 1;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> int _;


   // send address and read
   i2c.scl <: 1;
   i2c.sda  <: 1;
   sync(i2c.sda);
   gt :> time;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> int _;
   // start bit on SDI
   i2c.scl <: 1;
   i2c.sda  <: 0;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;
   // shift 7bits of address and 1bit R/W (fixed to write).
   // WARNING: Assume MSB first.
   for (i = 0; i < 8; i += 1)
   {
      int deviceAddr = device | 1;
      Temp = (deviceAddr >> (7 - i)) & 0x1;
      i2c.sda <: Temp;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 1;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> int _;
      i2c.scl <: 0;
   }
   // turn the data to input
   i2c.sda :> Temp;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 1;
   // sample first ACK.
   i2c.sda :> ack[0];
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 0;


   rdData = 0;
   // shift second 8 bits.
   for (j=0; j < i2c_data.data_len; j++){
	   for (i = 0; i < 8; i += 1)
	   {
		   gt :> time;
		   time += (I2C_BIT_TIME / 2);
		   gt when timerafter(time) :> int _;
		   i2c.scl <: 1;

		   i2c.sda :> Temp;
		   rdData = (rdData << 1) | (Temp & 1);

		   gt :> time;
		   time += (I2C_BIT_TIME / 2);
		   gt when timerafter(time) :> int _;
		   i2c.scl <: 0;

		   //Send ACK
		   if(j <(i2c_data.data_len-1)){
			   i2c.sda <: 0;

			   gt :> time;
			   time += (I2C_BIT_TIME / 2);
			   gt when timerafter(time) :> int _;
			   i2c.scl <: 1;

			   gt :> time;
			   time += (I2C_BIT_TIME / 2);
			   gt when timerafter(time) :> int _;
			   i2c.scl <: 0;
		   }
	   }
	   i2c_data.data[j]=rdData;
   }

   //Send Stop
   i2c.sda <: 0;

   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> int _;
   i2c.scl <: 1;

   gt :> time;
   time += (I2C_BIT_TIME / 4);
   gt when timerafter(time) :> int _;
   i2c.sda <: 1;


   return rdData;
}
#endif

//int i2c_wr(int addr, int data, int device, struct r_i2c &i2c)
int i2c_wr(int addr, int device, struct i2c_data_info &i2c_data,  struct r_i2c &i2c)
{
   timer gt;
   unsigned time;
   int Temp, CtlAdrsData, i;
   // three device ACK
   int ack[3];
   unsigned int data;
   unsigned int j;

   // initial values.
   i2c.scl <: 1;
   i2c.sda  <: 1;
   sync(i2c.sda);

   gt :> time;
   time += I2C_BIT_TIME;
   gt when timerafter(time) :> void;

   // start bit on SDI
   i2c.scl <: 1;
   i2c.sda  <: 0;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 0;

   // shift 7bits of address and 1bit R/W (fixed to write).
   // WARNING: Assume MSB first.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (device >> (7 - i)) & 0x1;
      i2c.sda <: Temp;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> void;
      i2c.scl <: 1;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> void;
      i2c.scl <: 0;
   }

   // turn the data to input
   i2c.sda :> Temp;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 1;

   // sample first ACK.
   i2c.sda :> ack[0];
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 0;

#ifdef I2C_TI_COMPATIBILITY
   CtlAdrsData = ((addr & 0x7F) << 9) | (data & 0x1FF);
#else
   CtlAdrsData = (addr & 0xFF);
#endif

   // shift first 8 bits.
   for (i = 0; i < 8; i += 1)
   {
#ifdef I2C_TI_COMPATIBILITY
      Temp = (CtlAdrsData >> (15 - i)) & 0x1;
#else
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
#endif
      i2c.sda <: Temp;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> void;
      i2c.scl <: 1;
      gt :> time;
      time += (I2C_BIT_TIME / 2);
      gt when timerafter(time) :> void;
      i2c.scl <: 0;
   }
   // turn the data to input
   i2c.sda :> Temp;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 1;
   // sample second ACK.
   i2c.sda :> ack[1];
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 0;

#ifdef I2C_TI_COMPATIBILITY

#else
   CtlAdrsData = (data & 0xFF);
#endif
   // shift second 8 bits.
   for(j=0; j < i2c_data.data_len; j++){
	   CtlAdrsData = (i2c_data.data[j] & 0xFF);
	   for (i = 0; i < 8; i += 1)
	   {
		   Temp = (CtlAdrsData >> (7 - i)) & 0x1;
		   i2c.sda <: Temp;
		   gt :> time;
		   time += (I2C_BIT_TIME / 2);
		   gt when timerafter(time) :> void;
		   i2c.scl <: 1;
		   gt :> time;
		   time += (I2C_BIT_TIME / 2);
		   gt when timerafter(time) :> void;
		   i2c.scl <: 0;
	   }
	   // turn the data to input
	   i2c.sda :> Temp;
	   gt :> time;
	   time += (I2C_BIT_TIME / 2);
	   gt when timerafter(time) :> void;
	   i2c.scl <: 1;
	   // sample second ACK.
	   i2c.sda :> ack[2];
	   gt :> time;
	   time += (I2C_BIT_TIME / 2);
	   gt when timerafter(time) :> void;
	   i2c.scl <: 0;
	   //ack[2]=0;
	   if(ack[2] == 1)
		   break;
   }
   i2c.sda <: 0;
   gt :> time;
   time += (I2C_BIT_TIME / 2);
   gt when timerafter(time) :> void;
   i2c.scl <: 1;
   // put the data to a good value for next round.
   time += (I2C_BIT_TIME / 4);
   gt when timerafter(time) :> void;
   i2c.sda  <: 1;
   printf("\n Value of ack = %d\n", ack[2]);
   return ((ack[0]==0) && (ack[1]==0) && (ack[2]==0));   
}
