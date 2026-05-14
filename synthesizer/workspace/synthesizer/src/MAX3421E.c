/* MAX3421E low-level functions                             */
/* reading, writing registers, reset, host transfer, etc.   */
/* GPIN, GPOUT are as per tutorial, reassign if necessary   */
/* USB power on is GPOUT7, USB power overload is GPIN7      */

#define _MAX3421E_C_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "project_config.h"
#include "xparameters.h"
#include <unistd.h>
#include <xspi.h>
#include <xgpio.h>
#include <xtmrctr.h>
#include "xintc.h"

/* variables and data structures */

/* External variables */

extern BYTE usb_task_state;
static XSpi SpiInstance;
static int Status;
static XGpio Gpio_rst;
static XGpio Gpio_int;
static XSpi_Config *ConfigPtr;	/* Pointer to Configuration data */
XTmrCtr Usb_timer;

//Initialization of SPI port is already done for you
void SPI_init() {


	ConfigPtr = XSpi_LookupConfig(XPAR_SPI_USB_DEVICE_ID);
	if (ConfigPtr == NULL) 
	{
		return XST_DEVICE_NOT_FOUND;
	}

	Status = XSpi_CfgInitialize(&SpiInstance, ConfigPtr, ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) 
	{
		return XST_FAILURE;
	}

	Status = XSpi_SetOptions(&SpiInstance, XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION);


	XSpi_Start(&SpiInstance);
	XSpi_IntrGlobalDisable(&SpiInstance);
}

BYTE SPI_wr(BYTE data) 
{
	return 0; //This function is not needed
}


/* Functions    */
/* Single host register write   */
void MAXreg_wr(BYTE reg, BYTE val) 
{
	//psuedocode:
	//select MAX3421E 
	//write reg + 2 via SPI
	//write val via SPI
	//read return code from SPI peripheral (see Xilinx examples) 
	//if return code != 0 print an error
	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)

	//select MAX3421E 
	XSpi_SetSlaveSelect(&SpiInstance, 0x01);

	//write reg + 2 via SPI
	//write val via SPI
	u8 send[2];//the array that we will send
	send[0] = reg+2;
	send[1] = val;
	int return_code = XSpi_Transfer(&SpiInstance, send, NULL, 2);
	
	//read return code from SPI peripheral (see Xilinx examples) 
	//if return code != 0 print an error

	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x00);
}


/* multiple-byte write */
/* returns a pointer to a memory position after last written */
BYTE* MAXbytes_wr(BYTE reg, BYTE nbytes, BYTE* data) 
{
	//psuedocode:
	//select MAX3421E (may not be necessary if you are using SPI peripheral)
	//write reg + 2 via SPI
	//write data[n] via SPI, where n goes from 0 to nbytes-1
	//read return code from SPI peripheral 
	//if return code != 0 print an error
	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	//return (data + nbytes);

	//select MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x01);

	//write reg + 2 via SPI
	//write data[n] via SPI, where n goes from 0 to nbytes-1
	u8 send[65];//the array that we will send, the max size is 1+64
	send[0] = reg+2;
	for(int n=0; n<nbytes; n++)
	{
		send[n+1]=data[n];
	}	
	int return_code = XSpi_Transfer(&SpiInstance, send, NULL, nbytes+1);

	//read return code from SPI peripheral 
	//if return code != 0 print an error


	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x00);

	//return (data + nbytes);
	return(data+nbytes);
}

/* Single host register read        */
BYTE MAXreg_rd(BYTE reg) 
{
	//psuedocode:
	//select MAX3421E (
	//write reg via SPI
	//read val via SPI
	//read return code from SPI peripheral 
	//if return code != 0 print an error
	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	//return val

	//select MAX3421E (
	XSpi_SetSlaveSelect(&SpiInstance, 0x01);

	//write reg via SPI
	//read val via SPI
	u8 send[2];
	send[0] = reg;
	send[1] = 0X00;
	u8 receive[2];
	int return_code = XSpi_Transfer(&SpiInstance, send, receive, 2);
	
	//read return code from SPI peripheral 
	//if return code != 0 print an error

	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x00);
	//return val
	return receive[1];//receive[0] is the status, not the value
}



/* multiple-bytes register read                             */
/* returns a pointer to a memory position after last read   */
BYTE* MAXbytes_rd(BYTE reg, BYTE nbytes, BYTE* data) 
{
	//psuedocode:
	//select MAX3421E (may not be necessary if you are using SPI peripheral)
	//write reg via SPI
	//read data[n] from SPI, where n goes from 0 to nbytes-1
	//read return code from SPI peripheral 
	//if return code != 0 print an error
	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	//return (data + nbytes);

	//select MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x01);

	//write reg via SPI
	//read data[n] from SPI, where n goes from 0 to nbytes-1
	u8 send[65];
	send[0] = reg;
	for(int n=1;n<=nbytes; n++)
	{
		send[n] = 0X00;
	}
	u8 receive[65];
	int return_code = XSpi_Transfer(&SpiInstance, send, receive, nbytes+1);
	
	//read return code from SPI peripheral 


	//deselect MAX3421E (may not be necessary if you are using SPI peripheral)
	XSpi_SetSlaveSelect(&SpiInstance, 0x00);

	//return (data + nbytes);
	for(int i=0; i<nbytes; i++)
    {
        data[i] = receive[i + 1];
    }
	return (data + nbytes);//receive[0] is the status, not the value
}
/* reset MAX3421E using chip reset bit. SPI configuration is not affected   */
void MAX3421E_reset(void) 
{
	Status = XGpio_Initialize(&Gpio_rst, XPAR_GPIO_USB_RST_DEVICE_ID);
	XGpio_SetDataDirection(&Gpio_rst, 1, 0); //configure reset, and set reset to output
	Status = XGpio_Initialize(&Gpio_int, XPAR_GPIO_USB_INT_DEVICE_ID);
	XGpio_SetDataDirection(&Gpio_int, 1, ~1); //configure int, and set int to input


	//hardware reset, then software reset
	XGpio_DiscreteClear(&Gpio_rst, 1, 0x1);
	for (int delay = 0; delay < 0x7FFFF; delay ++){}
	XGpio_DiscreteSet(&Gpio_rst, 1, 0x1);

	BYTE tmp = 0;

	MAXreg_wr( rUSBCTL, bmCHIPRES);      //Chip (soft) reset. This stops the oscillator
	MAXreg_wr( rUSBCTL, 0x00);           //Remove the reset

	while (!(MAXreg_rd( rUSBIRQ) & bmOSCOKIRQ)) { //wait until the PLL stabilizes
		tmp++;                                      //timeout after 256 attempts
	}
}
/* turn USB power on/off                                                */
/* ON pin of VBUS switch (MAX4793 or similar) is connected to GPOUT0    */
/* OVERLOAD pin of Vbus switch is connected to GPIN7                    */
/* OVERLOAD state low. NO OVERLOAD or VBUS OFF state high.              */
BOOL Vbus_power(BOOL action) {
    BYTE tmp = MAXreg_rd( rIOPINS1 );       //copy of IOPINS2
    if( action ) {                              //turn on by setting GPOUT0
        tmp |= bmGPOUT0;
    }
    else {                                      //turn off by clearing GPOUT0
        tmp &= ~bmGPOUT0;
    }
    MAXreg_wr( rIOPINS1,tmp );                              //send GPOUT0
    for (int delay = 0; delay < 0xFFFFF; delay ++){}		//delay a couple MS

    return( TRUE );                                         // power on/off successful
	return (1);
}

/* probe bus to determine device presence and speed */
void MAX_busprobe(void) {
	BYTE bus_sample;

//  MAXreg_wr(rHCTL,bmSAMPLEBUS);
	bus_sample = MAXreg_rd( rHRSL);            //Get J,K status
	bus_sample &= ( bmJSTATUS | bmKSTATUS);      //zero the rest of the byte

	switch (bus_sample) {                   //start full-speed or low-speed host
	case ( bmJSTATUS):
		/*kludgy*/
		if (usb_task_state != USB_ATTACHED_SUBSTATE_WAIT_RESET_COMPLETE) { //bus reset causes connection detect interrupt
			if (!(MAXreg_rd( rMODE) & bmLOWSPEED)) {
				MAXreg_wr( rMODE, MODE_FS_HOST);         //start full-speed host
			} else {
				MAXreg_wr( rMODE, MODE_LS_HOST);    //start low-speed host

			}
			usb_task_state = ( USB_STATE_ATTACHED); //signal usb state machine to start attachment sequence
		}
		break;
	case ( bmKSTATUS):
		if (usb_task_state != USB_ATTACHED_SUBSTATE_WAIT_RESET_COMPLETE) { //bus reset causes connection detect interrupt
			if (!(MAXreg_rd( rMODE) & bmLOWSPEED)) {
				MAXreg_wr( rMODE, MODE_LS_HOST);   //start low-speed host

			} else {
				MAXreg_wr( rMODE, MODE_FS_HOST);         //start full-speed host

			}
			usb_task_state = ( USB_STATE_ATTACHED); //signal usb state machine to start attachment sequence
		}
		break;
	case ( bmSE1):              //illegal state
		usb_task_state = ( USB_DETACHED_SUBSTATE_ILLEGAL);
		break;
	case ( bmSE0):              //disconnected state
		if (!((usb_task_state & USB_STATE_MASK) == USB_STATE_DETACHED)) //if we came here from other than detached state
			usb_task_state = ( USB_DETACHED_SUBSTATE_INITIALIZE); //clear device data structures
		else {
			MAXreg_wr( rMODE, MODE_FS_HOST); //start full-speed host
			usb_task_state = ( USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE);
		}
		break;
	} //end switch( bus_sample )
}
/* MAX3421E initialization after power-on   */
void MAX3421E_init(void) {
	/* Configure full-duplex SPI, interrupt pulse   */
	SPI_init();
	MAXreg_wr( rPINCTL, (bmFDUPSPI + bmINTLEVEL + bmGPXB)); //Full-duplex SPI, level interrupt, GPX
	MAX3421E_reset();                                //stop/start the oscillator

	//start USB timer
	Status = XTmrCtr_Initialize(&Usb_timer, XPAR_TIMER_USB_AXI_DEVICE_ID);

	XTmrCtr_Start(&Usb_timer, 0);


	for (int i = 0; i < 3; i++)
	{
		u32 current = XTmrCtr_GetValue(&Usb_timer, 0);
		while (XTmrCtr_GetValue(&Usb_timer, 0) - current < 100000000)
		{

		}

	}

	/* configure power switch   */
	Vbus_power( OFF);                                      //turn Vbus power off
	//MAXreg_wr( rGPINIEN, bmGPINIEN7); //enable interrupt on GPIN7 (power switch overload flag)
	Vbus_power( ON);
	/* configure host operation */
	MAXreg_wr( rMODE, bmDPPULLDN | bmDMPULLDN | bmHOST | bmSEPIRQ); // set pull-downs, SOF, Host, Separate GPIN IRQ on GPX
	//MAXreg_wr( rHIEN, bmFRAMEIE|bmCONDETIE|bmBUSEVENTIE );                      // enable SOF, connection detection, bus event IRQs
	MAXreg_wr( rHIEN, bmCONDETIE);                        //connection detection
	/* HXFRDNIRQ is checked in Dispatch packet function */
	MAXreg_wr(rHCTL, bmSAMPLEBUS);        // update the JSTATUS and KSTATUS bits
	MAX_busprobe();                             //check if anything is connected
	MAXreg_wr( rHIRQ, bmCONDETIRQ); //clear connection detect interrupt                 
	MAXreg_wr( rCPUCTL, 0x01);                            //enable interrupt pin
}

/* MAX3421 state change task and interrupt handler */
void MAX3421E_Task(void) {
	if (XGpio_DiscreteRead(&Gpio_int, 1) & 0x01 == 0) {

		MaxIntHandler();
	}
	//if ( IORD_ALTERA_AVALON_PIO_DATA(USB_GPX_BASE) == 1) {
	//	xil_printf("GPX interrupt\n\r");
	//	MaxGpxHandler();
	//}
}

void MaxIntHandler(void) {
	BYTE HIRQ;
	BYTE HIRQ_sendback = 0x00;
	HIRQ = MAXreg_rd( rHIRQ);                  //determine interrupt source
	if (HIRQ & bmFRAMEIRQ) {                   //->1ms SOF interrupt handler
		HIRQ_sendback |= bmFRAMEIRQ;
	}                   //end FRAMEIRQ handling

	if (HIRQ & bmCONDETIRQ) {
		MAX_busprobe();
		HIRQ_sendback |= bmCONDETIRQ;      //set sendback to 1 to clear register
	}
	if (HIRQ & bmSNDBAVIRQ) //if the send buffer is clear (previous transfer completed without issue)
	{
		MAXreg_wr(rSNDBC, 0x00);//clear the send buffer (not really necessary, but clears interrupt)
	}
	if (HIRQ & bmBUSEVENTIRQ) {           //bus event is either reset or suspend
		usb_task_state++;                       //advance USB task state machine
		HIRQ_sendback |= bmBUSEVENTIRQ;
	}
	/* End HIRQ interrupts handling, clear serviced IRQs    */
	MAXreg_wr( rHIRQ, HIRQ_sendback); //write '1' to CONDETIRQ to ack bus state change
}

void MaxGpxHandler(void) {
	BYTE GPINIRQ;
	GPINIRQ = MAXreg_rd( rGPINIRQ);            //read both IRQ registers
}
