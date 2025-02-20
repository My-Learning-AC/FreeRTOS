#ifndef MTP_APPLICATION_H_
#define MTP_APPLICATION_H_

#include<stdbool.h>


/* Test Cases for MTP is defined here (User modifiable) */
enum MTP_Test_Cases
{
  MTP_LED,
  MTP_USER_BUTTON,
  MTP_POT,
  MTP_HFLASH,
  MTP_HRAM,
  MTP_TDM,
  MTP_CANFD,
  MTP_LIN,
  MTP_GIGETH,
  MTP_FPD_DISPLAY,
};

/* Test elements/components, each of these components are tested and the results are stored individually */
enum MTP_Test_Components
{
    LED_E,
    BTN_E,
    POT_E,
    HFLASH_E,
    HRAM_E,
    TDM_E,
    CANFD_E,
    LIN_E,
    GIGETH_E,
    FPD_DISPLAY_E,
    WCO_E,
    MTP_TOTAL_TEST_COMPONENTS,
    MIPI_E,
};



/* Test elements strings to be printed as test name in serial terminal window */
char Test_Elements_str[MTP_TOTAL_TEST_COMPONENTS + 1][30]=
{
    "User LEDs",
    "User Buttons",
    "Potentiometer",
    "Hyper_Flash",
    "Hyper_RAM",
    "Audio_TDM",
    "CANFD",
    "LIN",
    "Gigabit_Ethernet",
    "FPD_Display",
    "WCO",
    "MIPI_CAMERA",
};


/* Global variables abd enums related to MTP test */
bool new_test = 0;
bool start_test = false;
bool skip_test = false;
bool test_passed = false;
bool test_failed = false;

enum MTP_Test_Cases current_test;
enum MTP_Test_Components element;


#endif

