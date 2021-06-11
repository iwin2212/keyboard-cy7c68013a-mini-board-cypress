
#pragma NOIV               // Do not generate interrupt vectors

#include "fx2.h"
#include "fx2regs.h"
#include "syncdly.h"

extern BOOL   GotSUD;         // Received setup data flag
extern BOOL   Sleep;
extern BOOL   Rwuen;
extern BOOL   Selfpwr;
#define	min(a,b) (((a)<(b))?(a):(b))

#define GD_HID	0x21
#define GD_REPORT	0x22
#define CR_SET_REPORT 0x09
#define GD_IF0 0x00
#define GD_IF1 0x01
#define HID_OUTPUT_REPORT 2

#define BTN_ADDR		0x41
extern BOOL	GotSUD;			// Received setup data flag
extern BOOL Sleep;

WORD	pHID1Dscr;
WORD	pHID1ReportDscr;
WORD	pHID1ReportDscrEnd;
extern code HID1Dscr;
extern code HID1ReportDscr;
extern code HID1ReportDscrEnd;

WORD	pHID2Dscr;
WORD	pHID2ReportDscr;
WORD	pHID2ReportDscrEnd;
extern code HID2Dscr;
extern code HID2ReportDscr;
extern code HID2ReportDscrEnd;


BYTE   Configuration;      // Current configuration
BYTE   AlternateSetting;   // Alternate settings

	//-----------------------------------------------------------------------------
	// Task Dispatcher hooks
	//   The following hooks are called by the task dispatcher.
	//-----------------------------------------------------------------------------

	// The two interrupt IN endpoints and the two bulk endpoints are initialized 

void TD_Init(void)             // Called once at startup
	{
	   // set the CPU clock to 48MHz
	CPUCS = ((CPUCS & ~bmCLKSPD) | bmCLKSPD1);

	// set the slave FIFO interface to 48MHz
	//IFCONFIG |= 0x40;
	IFCONFIG = 0x00; // custom
	OEB = 0xF0;
	IOB = 0xF0;

	EZUSB_Delay(2000);


   // Registers which require a synchronization delay, see section 15.14
   // FIFORESET        FIFOPINPOLAR
   // INPKTEND         OUTPKTEND
   // EPxBCH:L         REVCTL
   // GPIFTCB3         GPIFTCB2
   // GPIFTCB1         GPIFTCB0
   // EPxFIFOPFH:L     EPxAUTOINLENH:L
   // EPxFIFOCFG       EPxGPIFFLGSEL
   // PINFLAGSxx       EPxFIFOIRQ
   // EPxFIFOIE        GPIFIRQ
   // GPIFIE           GPIFADRH:L
   // UDMACRCH:L       EPxGPIFTRIG
   // GPIFTRIG

   // Note: The pre-REVE EPxGPIFTCH/L register are affected, as well...
   //      ...these have been replaced by GPIFTC[B3:B0] registers

   // default: all endpoints have their VALID bit set
   // default: TYPE1 = 1 and TYPE0 = 0 --> BULK  
   // default: EP2 and EP4 DIR bits are 0 (OUT direction)
   // default: EP6 and EP8 DIR bits are 1 (IN direction)
   // default: EP2, EP4, EP6, and EP8 are double buffered

   // we are just using the default values, yes this is not necessary...
	EP1INCFG = 0xB0;
	SYNCDELAY;                    // see TRM section 15.14
	EP2CFG = 0xF0;
	SYNCDELAY;
	EP6CFG = 0xA2;
	SYNCDELAY;
	EP8CFG = 0xE2;
	SYNCDELAY;
	EP6BCL = 0x80;                // arm EP6OUT by writing byte count w/skip.
	SYNCDELAY;
	EP6BCL = 0x80;
	SYNCDELAY;

	// enable dual autopointer feature
	AUTOPTRSETUP |= 0x01;
	}

BYTE read_buttons(void) {
	BYTE d;

	while (IOB & 0x40);	//Wait for stop to be done
	I2CS = 0x80;			//Set start condition
	I2DAT = BTN_ADDR;		//Write button address
	while (!(I2CS & 0x01));	//Wait for done
	I2CS = 0x20;			//Set last read
	d = I2DAT;				//Dummy read
	while (!(I2CS & 0x01));	//Wait for done
	I2CS = 0x40;			//Set stop bit
	return(I2DAT);			//Read the data
	}


void TD_Poll(void) 				// Called repeatedly while the device is idle
	{
	WORD i, count;
	if (!(EP1INCS & bmEPBUSY))	// Is the IN1BUF available,
		{
		EP1INBUF[3] = 0x00;
		EP1INBUF[4] = 0x00;

		IOB = 0xE0;
		if (!(IOB & 0x01)) {//1110 0001
			EP1INBUF[3] = 0x1e;//1
			}
		else if (!(IOB & 0x02)) {//1110 0010
			EP1INBUF[3] = 0x1f;// 2
			}
		else if (!(IOB & 0x04)) {//1110 0100
			EP1INBUF[3] = 0x20;//3
			}
		else if (!(IOB & 0x08)) {//1110 1000
			EP1INBUF[3] = 0x04;//A
			}

		IOB = 0xD0;
		if (!(IOB & 0x01)) {//1101 xxxx
			EP1INBUF[3] = 0x21;//4
			}
		else if (!(IOB & 0x02)) {
			EP1INBUF[3] = 0x22;//5
			}
		else if (!(IOB & 0x04)) {
			EP1INBUF[3] = 0x23;//6
			}
		else if (!(IOB & 0x08)) {
			EP1INBUF[3] = 0x05;//B
			}

		IOB = 0xB0;
		if (!(IOB & 0x01)) {//1011 xxxx
			EP1INBUF[3] = 0x24;//7
			}
		else if (!(IOB & 0x02)) {
			EP1INBUF[3] = 0x25;//8
			}
		else if (!(IOB & 0x04)) {
			EP1INBUF[3] = 0x26;//9
			}
		else if (!(IOB & 0x08)) {
			EP1INBUF[3] = 0x06;//C
			}

		IOB = 0x70;
		if (!(IOB & 0x01)) {//0111 xxxx
			EP1INBUF[3] = 0x55;//*
			}
		else if (!(IOB & 0x02)) {
			EP1INBUF[3] = 0x27;//0
			}
		else if (!(IOB & 0x04)) {
			EP1INBUF[3] = 0xCC;//#
			}
		else if (!(IOB & 0x08)) {
			EP1INBUF[3] = 0x07;//d
			}

		}
	EP1INBUF[0] = 0x00;
	EP1INBUF[1] = 0x00;
	EP1INBUF[2] = 0x00;

	EP1INBC = 5;
	// SYNCDELAY;
	//EZUSB_Delay(2000);
	if (!(EP2468STAT & bmEP6EMPTY)) { // check EP6 EMPTY(busy) bit in EP2468STAT (SFR), core set's this bit when FIFO is empty
		if (!(EP2468STAT & bmEP8FULL)) {  // check EP8 FULL(busy) bit in EP2468STAT (SFR), core set's this bit when FIFO is full
			APTR1H = MSB(&EP6FIFOBUF);
			APTR1L = LSB(&EP6FIFOBUF);

			AUTOPTRH2 = MSB(&EP8FIFOBUF);
			AUTOPTRL2 = LSB(&EP8FIFOBUF);

			count = (EP6BCH << 8) + EP6BCL;

			// loop EP6OUT buffer data to EP8IN
			for (i = 0x0000; i < count; i++) {
				   // setup to transfer EP6OUT buffer to EP8IN buffer using AUTOPOINTER(s)
				EXTAUTODAT2 = EXTAUTODAT1;
				EZUSB_Delay(500);
				}
			EP8BCH = EP6BCH;
			SYNCDELAY;
			EP8BCL = EP6BCL;        // arm EP8IN
			SYNCDELAY;
			EP6BCL = 0x80;          // re(arm) EP6OUT
			}
		}
	}


BOOL TD_Suspend(void)          // Called before the device goes into suspend mode
	{
	return(TRUE);
	}

BOOL TD_Resume(void)          // Called after the device resumes
	{
	return(TRUE);
	}

	//-----------------------------------------------------------------------------
	// Device Request hooks
	//   The following hooks are called by the end point 0 device request parser.
	//-----------------------------------------------------------------------------


BOOL DR_ClassRequest(void) {
	return(TRUE);
	}


	// Loading HID/ Report Descriptor
BOOL DR_GetDescriptor(void) {
	BYTE HID1length, i;
	BYTE HID2length;

	pHID1Dscr = (WORD) &HID1Dscr;
	pHID1ReportDscr = (WORD) &HID1ReportDscr;
	pHID1ReportDscrEnd = (WORD) &HID1ReportDscrEnd;

	pHID2Dscr = (WORD) &HID2Dscr;
	pHID2ReportDscr = (WORD) &HID2ReportDscr;
	pHID2ReportDscrEnd = (WORD) &HID2ReportDscrEnd;

	switch (SETUPDAT[3]) {
			case GD_HID:					//HID Descriptor			
				switch (SETUPDAT[4]) {
						case GD_IF0:
							HID1length = SETUPDAT[6];
							AUTOPTR1H = MSB(pHID1Dscr);
							AUTOPTR1L = LSB(pHID1Dscr);
							for (i = 0; i < HID1length; i++)
								EP0BUF[i] = XAUTODAT1;
							EP0BCL = HID1length;
							break;
						case GD_IF1:
							HID2length = SETUPDAT[6];
							AUTOPTR1H = MSB(pHID2Dscr);
							AUTOPTR1L = LSB(pHID2Dscr);
							for (i = 0; i < HID2length; i++)
								EP0BUF[i] = XAUTODAT1;
							EP0BCL = HID2length;
							break;
						default:
							EZUSB_STALL_EP0();
					}
				return (FALSE);
				break;
			case GD_REPORT:					//Report Descriptor
				switch (SETUPDAT[4]) {
						case GD_IF0:
							HID1length = pHID1ReportDscrEnd - pHID1ReportDscr;
							AUTOPTR1H = MSB(pHID1ReportDscr);
							AUTOPTR1L = LSB(pHID1ReportDscr);
							for (i = 0; i < HID1length; i++)
								EP0BUF[i] = XAUTODAT1;
							EP0BCL = HID1length;
							break;
						case GD_IF1:
							HID2length = pHID2ReportDscrEnd - pHID2ReportDscr;
							AUTOPTR1H = MSB(pHID2ReportDscr);
							AUTOPTR1L = LSB(pHID2ReportDscr);
							for (i = 0; i < HID2length; i++)
								EP0BUF[i] = XAUTODAT1;
							EP0BCL = HID2length;
							break;
						default:
							EZUSB_STALL_EP0();
					}
				return (FALSE);
				break;
			default:
				return(TRUE);
		}
	}

BOOL DR_SetConfiguration(void)   // Called when a Set Configuration command is received
	{
	Configuration = SETUPDAT[2];
	return(TRUE);            // Handled by user code
	}

BOOL DR_GetConfiguration(void)   // Called when a Get Configuration command is received
	{
	EP0BUF[0] = Configuration;
	EP0BCH = 0;
	EP0BCL = 1;
	return(TRUE);            // Handled by user code
	}

BOOL DR_SetInterface(void)       // Called when a Set Interface command is received
	{
	AlternateSetting = SETUPDAT[2];
	return(TRUE);            // Handled by user code
	}

BOOL DR_GetInterface(void)       // Called when a Set Interface command is received
	{
	EP0BUF[0] = AlternateSetting;
	EP0BCH = 0;
	EP0BCL = 1;
	return(TRUE);            // Handled by user code
	}

BOOL DR_GetStatus(void) {
	return(TRUE);
	}

BOOL DR_ClearFeature(void) {
	return(TRUE);
	}

BOOL DR_SetFeature(void) {
	return(TRUE);
	}

BOOL DR_VendorCmnd(void) {
	return(TRUE);
	}

	//-----------------------------------------------------------------------------
	// USB Interrupt Handlers
	//   The following functions are called by the USB interrupt jump table.
	//-----------------------------------------------------------------------------

	// Setup Data Available Interrupt Handler
void ISR_Sudav(void) interrupt 0
	{
	GotSUD = TRUE;            // Set flag
	EZUSB_IRQ_CLEAR();
	USBIRQ = bmSUDAV;         // Clear SUDAV IRQ
	}

	// Setup Token Interrupt Handler
void ISR_Sutok(void) interrupt 0
	{
	EZUSB_IRQ_CLEAR();
	USBIRQ = bmSUTOK;         // Clear SUTOK IRQ
	}

void ISR_Sof(void) interrupt 0
	{
	EZUSB_IRQ_CLEAR();
	USBIRQ = bmSOF;            // Clear SOF IRQ
	}

void ISR_Ures(void) interrupt 0
	{
	   // whenever we get a USB reset, we should revert to full speed mode
	pConfigDscr = pFullSpeedConfigDscr;
	((CONFIGDSCR xdata*) pConfigDscr)->type = CONFIG_DSCR;
	pOtherConfigDscr = pHighSpeedConfigDscr;
	((CONFIGDSCR xdata*) pOtherConfigDscr)->type = OTHERSPEED_DSCR;

	EZUSB_IRQ_CLEAR();
	USBIRQ = bmURES;         // Clear URES IRQ
	}

void ISR_Susp(void) interrupt 0
	{
	Sleep = TRUE;
	EZUSB_IRQ_CLEAR();
	USBIRQ = bmSUSP;
	}

void ISR_Highspeed(void) interrupt 0
	{
	if (EZUSB_HIGHSPEED()) {
		pConfigDscr = pHighSpeedConfigDscr;
		((CONFIGDSCR xdata*) pConfigDscr)->type = CONFIG_DSCR;
		pOtherConfigDscr = pFullSpeedConfigDscr;
		((CONFIGDSCR xdata*) pOtherConfigDscr)->type = OTHERSPEED_DSCR;
		}

	EZUSB_IRQ_CLEAR();
	USBIRQ = bmHSGRANT;
	}
void ISR_Ep0ack(void) interrupt 0
	{
	}
void ISR_Stub(void) interrupt 0
	{
	}
void ISR_Ep0in(void) interrupt 0
	{
	}
void ISR_Ep0out(void) interrupt 0
	{
	}
void ISR_Ep1in(void) interrupt 0
	{
	}
void ISR_Ep1out(void) interrupt 0
	{
	}
void ISR_Ep2inout(void) interrupt 0
	{
	}
void ISR_Ep4inout(void) interrupt 0
	{
	}
void ISR_Ep6inout(void) interrupt 0
	{
	}
void ISR_Ep8inout(void) interrupt 0
	{
	}
void ISR_Ibn(void) interrupt 0
	{
	}
void ISR_Ep0pingnak(void) interrupt 0
	{
	}
void ISR_Ep1pingnak(void) interrupt 0
	{
	}
void ISR_Ep2pingnak(void) interrupt 0
	{
	}
void ISR_Ep4pingnak(void) interrupt 0
	{
	}
void ISR_Ep6pingnak(void) interrupt 0
	{
	}
void ISR_Ep8pingnak(void) interrupt 0
	{
	}
void ISR_Errorlimit(void) interrupt 0
	{
	}
void ISR_Ep2piderror(void) interrupt 0
	{
	}
void ISR_Ep4piderror(void) interrupt 0
	{
	}
void ISR_Ep6piderror(void) interrupt 0
	{
	}
void ISR_Ep8piderror(void) interrupt 0
	{
	}
void ISR_Ep2pflag(void) interrupt 0
	{
	}
void ISR_Ep4pflag(void) interrupt 0
	{
	}
void ISR_Ep6pflag(void) interrupt 0
	{
	}
void ISR_Ep8pflag(void) interrupt 0
	{
	}
void ISR_Ep2eflag(void) interrupt 0
	{
	}
void ISR_Ep4eflag(void) interrupt 0
	{
	}
void ISR_Ep6eflag(void) interrupt 0
	{
	}
void ISR_Ep8eflag(void) interrupt 0
	{
	}
void ISR_Ep2fflag(void) interrupt 0
	{
	}
void ISR_Ep4fflag(void) interrupt 0
	{
	}
void ISR_Ep6fflag(void) interrupt 0
	{
	}
void ISR_Ep8fflag(void) interrupt 0
	{
	}
void ISR_GpifComplete(void) interrupt 0
	{
	}
void ISR_GpifWaveform(void) interrupt 0
	{
	}
