; Archivo: main.S
; Dispositivo: PIC16F887
; Autor: Diana Alvarado
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: Incrementar en RB0 y decrementar en RB1
; Hardware: LEDs en el puerto A, push pull down en RB0 y RB1
;
; Creado: 27 jul, 2021
; Última modificación: 27 jul, 2021

 ; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

PSECT udata_bank0 ;common memory
  cont_small: DS 1 ; 1 byte
  cont_big: DS 1
    
PSECT resVect, class=CODE, abs, delta=2
;--------vector reset------------
ORG 00h  ;posición 0000h para el reset
resetVec:
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
ORG 100h  
 
 ; posición para el código 
 ; -------configuración---------
main: 
    call config_io
    call config_reloj
    banksel PORTA
    banksel PORTC
    banksel PORTD
   
 ;--------loop principal------------
 loop: 
    btfsc PORTB, 0
    call inc_porta
    btfsc PORTB, 1
    call dec_porta
    btfsc PORTB, 3
    call inc_portc
    btfsc PORTB, 4
    call dec_portc
    btfsc PORTB, 2
    call suma
    goto loop	; loop forever
    
;-------sub rutinas---------
config_io:
    bsf STATUS, 5 ;banco 11
    bsf STATUS, 6
    clrf ANSEL ; pines digitales
    clrf ANSELH 
    
    bsf STATUS, 5 ; banco 01
    bcf STATUS, 6
    clrf TRISA ; port A como salida 
    clrf TRISC; port C como salida 
    bsf TRISB, 0
    bsf TRISB, 1
    bsf TRISB, 2
    bsf TRISB, 3
    bsf TRISB, 4
    
    clrf TRISD; port D como salida
   
    
    bcf STATUS, 5 ;banco 00
    bcf STATUS, 6
    clrf PORTA 
    clrf PORTC
    clrf PORTD
    return
    
config_reloj:
    banksel OSCCON
    bsf IRCF2 ; OSCCON, 6 (0) 500KHz
    bsf IRCF1  ;          (1)
    bcf IRCF0 ;           (1)
    bsf SCS ; reloj interno
    return
    
inc_porta: 
    call delay_small
    btfsc PORTB, 0
    goto $-1
    incf PORTA
    btfsc PORTA, 4
    clrf PORTA
    return
    
dec_porta: 
    call delay_small
    btfsc PORTB, 1
    goto $-1
    decf PORTA
    call cont 
    return

delay_big: 
    movlw 200 ;valor inicial del contador (200*0.5ms=100)
    movwf cont_big
    call delay_small  ; rutina del delay
    decfsz cont_big, 1 ; decrementar el contador
    goto $-2 ; ejecutar dos líneas atrás
    return

delay_small:
    movlw 165 ; valor inicial del contador (((500-1-1-1)/3=165)
    movwf cont_small
    decfsz cont_small, 1 ; decrementar el contador 
    goto $-1 ; ejecutar línea anterior
    return

cont:
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTA, 6
    bcf PORTA, 7
    return   

inc_portc: 
    call delay_small
    btfsc PORTB, 3
    goto $-1
    incf PORTC
    btfsc PORTC, 4
    clrf PORTC
    return
    
dec_portc:
    call delay_small
    btfsc PORTB, 4
    goto $-1
    decf PORTC
    call cont2
    return
    
cont2:
    bcf PORTC, 4
    bcf PORTC, 5
    bcf PORTC, 6
    bcf PORTC, 7
    return
    
suma:
    call delay_small
    btfsc PORTB, 2
    clrw
    movf PORTA, W
    addwf PORTC, W
    movwf PORTD
    btfsc PORTD, 5
    clrf PORTD
    return

END 
    
   

