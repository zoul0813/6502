#ifndef __LCD_H
#define __LCD_H

#define LCD_DM_CURSOR_NOBLINK 0b00000000
#define LCD_DM_CURSOR_BLINK   0b00000001
#define LCD_DM_CURSOR_OFF     0b00000000
#define LCD_DM_CURSOR_ON      0b00000010
#define LCD_DM_DISPLAY_OFF    0b00000000
#define LCD_DM_DISPLAY_ON     0b00000100

/*
        .import _lcd_get_position
        .import _lcd_set_position
        .import _lcd_define_char
*/

extern void __fastcall__ lcd_init(void);
extern void __fastcall__ lcd_print(const unsigned char string[]);
extern void __fastcall__ lcd_print_char(const unsigned char c);
extern void __fastcall__ lcd_clear(void);
extern void __fastcall__ lcd_backspace(void);
extern void __fastcall__ lcd_newline(void);
extern void __fastcall__ lcd_display_mode(const unsigned char mode);
extern void __fastcall__ lcd_scroll_up(void);
extern void __fastcall__ lcd_scroll_down(void);

#endif