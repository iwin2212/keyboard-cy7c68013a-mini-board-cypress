;;-----------------------------------------------------------------------------
;;   File:      dscr.a51
;;   Contents:  This file contains descriptor data tables.
;;
;; $Archive: /USB/Examples/Fx2lp/bulkloop/dscr.a51 $
;; $Date: 9/01/03 8:51p $
;; $Revision: 3 $
;;
;;
;;-----------------------------------------------------------------------------
;; Copyright 2003, Cypress Semiconductor Corporation
;;-----------------------------------------------------------------------------;;-----------------------------------------------------------------------------
   
DSCR_DEVICE   equ   1   ;; Descriptor type: Device
DSCR_CONFIG   equ   2   ;; Descriptor type: Configuration
DSCR_STRING   equ   3   ;; Descriptor type: String
DSCR_INTRFC   equ   4   ;; Descriptor type: Interface
DSCR_ENDPNT   equ   5   ;; Descriptor type: Endpoint
DSCR_DEVQUAL  equ   6   ;; Descriptor type: Device Qualifier

DSCR_DEVICE_LEN   equ   18
DSCR_CONFIG_LEN   equ    9
DSCR_INTRFC_LEN   equ    9
DSCR_ENDPNT_LEN   equ    7
DSCR_DEVQUAL_LEN  equ   10

ET_CONTROL   equ   0   ;; Endpoint type: Control
ET_ISO       equ   1   ;; Endpoint type: Isochronous
ET_BULK      equ   2   ;; Endpoint type: Bulk
ET_INT       equ   3   ;; Endpoint type: Interrupt

public      DeviceDscr, DeviceQualDscr, HighSpeedConfigDscr, FullSpeedConfigDscr, StringDscr, UserDscr, HID1Dscr, HID1ReportDscr, HID1ReportDscrEnd
public	    HID2Dscr, HID2ReportDscr, HID2ReportDscrEnd, HID1DscrFS, HID2DscrFS

;;DSCR   SEGMENT   CODE PAGE

;;-----------------------------------------------------------------------------
;; Global Variables
;;-----------------------------------------------------------------------------
;;      rseg DSCR      ;; locate the descriptor table in on-part memory.

CSEG AT 100H

DeviceDscr:   
      db   DSCR_DEVICE_LEN      ;; Descriptor length
      db   DSCR_DEVICE   ;; Decriptor type
      dw   0002H      ;; Specification Version (BCD)
      db   00H        ;; Device class
      db   00H         ;; Device sub-class
      db   00H         ;; Device sub-sub-class
      db   64         ;; Maximum packet size
      dw   0B404H     ;; Vendor ID
      dw   0410H      ;; Product ID
      dw   0100H      ;; Product version ID
      db   0         ;; Manufacturer string index
      db   0         ;; Product string index
      db   0         ;; Serial number string index
      db   1         ;; Number of configurations

DeviceQualDscr:
      db   DSCR_DEVQUAL_LEN   ;; Descriptor length
      db   DSCR_DEVQUAL   ;; Decriptor type
      dw   0002H      ;; Specification Version (BCD)
      db   00H        ;; Device class
      db   00H         ;; Device sub-class
      db   00H         ;; Device sub-sub-class
      db   64         ;; Maximum packet size
      db   1         ;; Number of configurations
      db   0         ;; Reserved

HighSpeedConfigDscr:   
      db   DSCR_CONFIG_LEN               ;; Descriptor length
      db   DSCR_CONFIG                  ;; Descriptor type
      db   (HighSpeedConfigDscrEnd-HighSpeedConfigDscr) mod 256 ;; Total Length (LSB)
      db   (HighSpeedConfigDscrEnd-HighSpeedConfigDscr)  /  256 ;; Total Length (MSB)
      db   3      ;; Number of interfaces
      db   1      ;; Configuration number
      db   0      ;; Configuration string
      db   10000000b   ;; Attributes (b7 - buspwr, b6 - selfpwr, b5 - rwu)
      db   50      ;; Power requirement (div 2 ma)

HID1IntrfcDscr:
		db	HID1IntrfcDscrEnd-HID1IntrfcDscr		;; Descriptor length
		db	DSCR_INTRFC	;; Descriptor type
		db	00H		;; Zero-based index of this interface
		db	0		;; Alternate setting
		db	1		;; Number of end points 
		db	03H		;; Interface class (HID)
		db	00H		;; Boot Interface sub class
		db	02H		;; Interface sub sub class (Mouse)
		db	1		;; Interface descriptor string index
HID1IntrfcDscrEnd:
		
HID1Dscr:	
		db	09h		; length
		db	21h		; type: HID
		db	10h,01h		; release: HID class rev 1.1
		db	00h		; country code (none)
		db	01h		; number of HID class descriptors to follow
		db	22h		; report descriptor type (HID)
		db	(HID1ReportDscrEnd-HID1ReportDscr) ; length of HID descriptor
		db	00h
HID1DscrEnd:


HID1EpInDscr:
		db	HID1EpInDscrEnd-HID1EpInDscr		;; Descriptor length
		db	DSCR_ENDPNT	;; Descriptor type
		db	82H		;; Endpoint number, and direction
		db	ET_INT		;; Endpoint type
		db	40H		;; Maximum packet size (LSB)
		db	00H		;; Max packet size (MSB)
		db	10		;; Polling interval
HID1EpInDscrEnd:

HID2IntrfcDscr:
		db	HID2IntrfcDscrEnd-HID2IntrfcDscr		;; Descriptor length
		db	DSCR_INTRFC	;; Descriptor type
		db	01H		;; Zero-based index of this interface
		db	0		;; Alternate setting
		db	1		;; Number of end points 
		db	03H		;; Interface class (HID)
		db	00H		;; Interface sub class
		db	00H		;; Interface sub sub class
		db	2		;; Interface descriptor string index
HID2IntrfcDscrEnd:
		
HID2Dscr:	
		db	09h		; length
		db	21h		; type: HID
		db	10h,01h		; release: HID class rev 1.0
		db	00h		; country code (none)
		db	01h		; number of HID class descriptors to follow
		db	22h		; report descriptor type (HID)
		db	(HID2ReportDscrEnd-HID2ReportDscr) ; length of HID descriptor
		db	00h
HID2DscrEnd:


HID2EpInDscr:
		db	HID2EpInDscrEnd-HID2EpInDscr		;; Descriptor length
		db	DSCR_ENDPNT	;; Descriptor type
		db	81H		;; Endpoint number, and direction
		db	ET_INT		;; Endpoint type
		db	40H		;; Maximun packet size (LSB)
		db	00H		;; Max packect size (MSB)
		db	10		;; Polling interval
HID2EpInDscrEnd:

;; Interface Descriptor
      db   DSCR_INTRFC_LEN      ;; Descriptor length
      db   DSCR_INTRFC         ;; Descriptor type
      db   02H               ;; Zero-based index of this interface
      db   0               ;; Alternate setting
      db   2               ;; Number of end points 
      db   0ffH            ;; Interface class
      db   00H               ;; Interface sub class
      db   00H               ;; Interface sub sub class
      db   0               ;; Interface descriptor string index
      
;; Endpoint Descriptor
      db   DSCR_ENDPNT_LEN      ;; Descriptor length
      db   DSCR_ENDPNT         ;; Descriptor type
      db   06H               ;; Endpoint number, and direction
      db   ET_BULK            ;; Endpoint type
      db   00H               ;; Maximun packet size (LSB)
      db   02H               ;; Max packect size (MSB)
      db   00H               ;; Polling interval

;; Endpoint Descriptor
      db   DSCR_ENDPNT_LEN      ;; Descriptor length
      db   DSCR_ENDPNT         ;; Descriptor type
      db   88H               ;; Endpoint number, and direction
      db   ET_BULK            ;; Endpoint type
      db   00H               ;; Maximun packet size (LSB)
      db   02H               ;; Max packect size (MSB)
      db   00H               ;; Polling interval

HighSpeedConfigDscrEnd:

org (($ / 2) +1) * 2

FullSpeedConfigDscr:   
      db   DSCR_CONFIG_LEN               ;; Descriptor length
      db   DSCR_CONFIG                  ;; Descriptor type
      db   (FullSpeedConfigDscrEnd-FullSpeedConfigDscr) mod 256 ;; Total Length (LSB)
      db   (FullSpeedConfigDscrEnd-FullSpeedConfigDscr)  /  256 ;; Total Length (MSB)
      db   3      ;; Number of interfaces
      db   1      ;; Configuration number
      db   0      ;; Configuration string
      db   10000000b   ;; Attributes (b7 - buspwr, b6 - selfpwr, b5 - rwu)
      db   50      ;; Power requirement (div 2 ma)

HID1IntrfcDscrFS:
		db	HID1IntrfcDscrEnd-HID1IntrfcDscr		;; Descriptor length
		db	DSCR_INTRFC	;; Descriptor type
		db	00H		;; Zero-based index of this interface
		db	0		;; Alternate setting
		db	1		;; Number of end points 
		db	03H		;; Interface class (HID)
		db	00H		;; Boot Interface sub class
		db	02H		;; Interface sub sub class (Mouse)
		db	0		;; Interface descriptor string index
HID1IntrfcDscrEndFS:
		
HID1DscrFS:	
		db	09h		; length
		db	21h		; type: HID
		db	10h,01h		; release: HID class rev 1.1
		db	00h		; country code (none)
		db	01h		; number of HID class descriptors to follow
		db	22h		; report descriptor type (HID)
		db	(HID1ReportDscrEnd-HID1ReportDscr) ; length of HID descriptor
		db	00h
HID1DscrEndFS:


HID1EpInDscrFS:
		db	HID1EpInDscrEnd-HID1EpInDscr		;; Descriptor length
		db	DSCR_ENDPNT	;; Descriptor type
		db	82H		;; Endpoint number, and direction
		db	ET_INT		;; Endpoint type
		db	40H		;; Maximum packet size (LSB)
		db	00H		;; Max packet size (MSB)
		db	10		;; Polling interval
HID1EpInDscrEndFS:

HID2IntrfcDscrFS:
		db	HID2IntrfcDscrEnd-HID2IntrfcDscr		;; Descriptor length
		db	DSCR_INTRFC	;; Descriptor type
		db	01H		;; Zero-based index of this interface
		db	0		;; Alternate setting
		db	1		;; Number of end points 
		db	03H		;; Interface class (HID)
		db	00H		;; Interface sub class
		db	00H		;; Interface sub sub class
		db	0		;; Interface descriptor string index
HID2IntrfcDscrEndFS:
		
HID2DscrFS:	
		db	09h		; length
		db	21h		; type: HID
		db	10h,01h		; release: HID class rev 1.0
		db	00h		; country code (none)
		db	01h		; number of HID class descriptors to follow
		db	22h		; report descriptor type (HID)
		db	(HID2ReportDscrEnd-HID2ReportDscr) ; length of HID descriptor
		db	00h
HID2DscrEndFS:


HID2EpInDscrFS:
		db	HID2EpInDscrEnd-HID2EpInDscr		;; Descriptor length
		db	DSCR_ENDPNT	;; Descriptor type
		db	81H		;; Endpoint number, and direction
		db	ET_INT		;; Endpoint type
		db	40H		;; Maximun packet size (LSB)
		db	00H		;; Max packect size (MSB)
		db	10		;; Polling interval
HID2EpInDscrEndFS:

;; Interface Descriptor
      db   DSCR_INTRFC_LEN      ;; Descriptor length
      db   DSCR_INTRFC         ;; Descriptor type
      db   02H               ;; Zero-based index of this interface
      db   0               ;; Alternate setting
      db   2               ;; Number of end points 
      db   0ffH            ;; Interface class
      db   00H               ;; Interface sub class
      db   00H               ;; Interface sub sub class
      db   0               ;; Interface descriptor string index
      
;; Endpoint Descriptor
      db   DSCR_ENDPNT_LEN      ;; Descriptor length
      db   DSCR_ENDPNT         ;; Descriptor type
      db   06H               ;; Endpoint number, and direction
      db   ET_BULK            ;; Endpoint type
      db   40H               ;; Maximun packet size (LSB)
      db   00H               ;; Max packect size (MSB)
      db   00H               ;; Polling interval

;; Endpoint Descriptor
      db   DSCR_ENDPNT_LEN      ;; Descriptor length
      db   DSCR_ENDPNT         ;; Descriptor type
      db   88H               ;; Endpoint number, and direction
      db   ET_BULK            ;; Endpoint type
      db   40H               ;; Maximun packet size (LSB)
      db   00H               ;; Max packect size (MSB)
      db   00H               ;; Polling interval

FullSpeedConfigDscrEnd: 

HID1ReportDscr:
	db 05h, 01h     ; 	Usage Page (Generic Desktop),
	db 09h, 02h     ; 	Usage (Mouse),
	db 0A1h, 01h    ; 	Collection (Application),
	db 09h, 01h     ;           Usage (Pointer), 
	db 0A1h, 00h	;	    Collection (Physical),
	db 95h, 03h     ;               Report Count (3),
	db 75h, 01h     ;               Report Size (1),
	db 05h, 09h	;	        Usage Page (Buttons),
	db 19h, 01h	;	        Usage minimum (1)
	db 29h, 03h	;	        Usage maximum (3)
	db 15h, 00h     ;               Logical minimum (0),
	db 25h, 01h     ;               Logical maximum (1),	
	db 81h, 02h     ;               Input (Data, Variable, Absolute), (3 button bits)
	db 95h, 01h     ;               Report Count (1),
	db 75h, 05h     ;               Report Size (5),
	db 81h, 01h     ;               Input (Constant)
	db 75h, 08h	;		Report Size (8)
	db 95h, 02h	;               Report Count (2)              
	db 05h, 01h     ;               Usage Page (Generic Desktop),
	db 09h, 30h     ;               Usage (X),
	db 09h, 31h     ;               Usage (Y),
	db 15h, 81h     ;               Logical Minimum (-127),
	db 25h, 7Fh     ;               Logical Maximum (+127),	
	db 81h, 06h     ;               Input (Data, Variable, Relative), (2 position bytes - X & Y)
	db 0C0h         ;            End Collection
	db 0C0h         ;        End Collection
HID1ReportDscrEnd:

HID2ReportDscr:
	db 05h, 01h     ; Usage Page (Generic Desktop)
	db 09h, 06h     ; Usage (Keyboard)
	db 0A1h, 01h     ; Collection (Application)
	db 05h, 07h     ;       Usage Page (Key codes)
	db 19h, 0E0h	;	Usage minimum (234)
	db 29h, 0E7h	;	Usage maximum (231)
	db 15h, 00h	;	Logical minimum (0)
	db 25h, 01h	;	Logical maximum (1)
	db 75h, 01h	;	Report size (1)
	db 95h, 08h	;	Report count (8)
	db 81h, 02h	;	Input (data, variable, absolute)
	db 95h, 01h	;	Report count (1)
	db 75h, 08h	;	Report size (8)
	db 81h, 01h	;	Input (constant)
	db 95h, 05h	;	Report count (5)
	db 75h, 01h	;	Report size (1)
	db 05h, 08h	;	Usage Page (LED)
	db 19h, 01h	;	Usage minimum (1)
	db 29h, 05h	;	Usage maximum (5)
	db 91h, 02h	;	Output (data, variable, absolute)
	db 95h, 01h	;	Report count (1)
	db 75h, 03h	;	Report size (3)
	db 91h, 01h	;	Output (constant)
	db 95h, 03h	;	Report count (3)
	db 75h, 08h	;	Report size (8)
	db 15h, 00h	;	Logical minimum (0)
	db 25h, 65h	;	Logical maximum (101)
	db 05h, 07h	;	Usage page (key codes)
	db 19h, 00h	;	Usage minimum (0)
	db 29h, 65h	;	Usage maximum (101)
	db 81h, 00h	;	Input (data, array)
	db 0C0h          ; End Collection
HID2ReportDscrEnd:

	db 0		; Added for word alignment

StringDscr:

StringDscr0:   
      db   StringDscr0End-StringDscr0      ;; String descriptor length
      db   DSCR_STRING
      db   09H,04H
StringDscr0End:

StringDscr1:   
      db   StringDscr1End-StringDscr1      ;; String descriptor length
      db   DSCR_STRING
      db   'M',00
      db   'o',00
      db   'u',00
      db   's',00
      db   'e',00
StringDscr1End:

StringDscr2:   
      db   StringDscr2End-StringDscr2      ;; Descriptor length
      db   DSCR_STRING
      db   'K',00
      db   'e',00
      db   'y',00
      db   'B',00
      db   'o',00
      db   'a',00
      db   'r',00
      db   'd',00
StringDscr2End:

UserDscr:      
      dw   0000H
      end
      
