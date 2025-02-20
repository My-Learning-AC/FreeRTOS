#ifndef ADC_H
#define ADC_H


#include <stdint.h>
#include <stdbool.h>


#define ADC_H
#define     __IOM    volatile            /*! Defines 'read / write' structure member permissions */
#define     __IM     volatile const      /*! Defines 'read only' structure member permissions */

#define _VAL2FLD(field, value)    (((uint32_t)(value) << field ## _Pos) & field ## _Msk)
#define _FLD2VAL(field, value)    (((uint32_t)(value) & field ## _Msk) >> field ## _Pos)
#define _BOOL2FLD(field, value) (((value) != false) ? (field ## _Msk) : 0UL)

#define CY_SAR_SEQ_NUM_CHANNELS     (8u)
#define CY_SAR_CHANNELS_MASK            ((1UL << CY_SAR_SEQ_NUM_CHANNELS) - 1UL)
typedef uint32_t cy_rslt_t;
/** Resolution */
typedef enum
{
    CY_SAR_MAX_RES               = 0UL,     /**< Maximum 12b resolution */
    CY_SAR_SUB_RES               = 1UL      /**< Reduced resolution, defined by \ref cy_en_sar_sample_ctrl_sub_resolution_t */
} cy_en_sar_channel_ctrl_resolution_t;

typedef struct {
  __IOM uint32_t CTRL;                          /*!< 0x00000000 Analog control register. */
  __IOM uint32_t SAMPLE_CTRL;                   /*!< 0x00000004 Sample control register. */
   __IM uint32_t RESERVED[2];
  __IOM uint32_t SAMPLE_TIME01;                 /*!< 0x00000010 Sample time specification ST0 and ST1 */
  __IOM uint32_t SAMPLE_TIME23;                 /*!< 0x00000014 Sample time specification ST2 and ST3 */
  __IOM uint32_t RANGE_THRES;                   /*!< 0x00000018 Global range detect threshold register. */
  __IOM uint32_t RANGE_COND;                    /*!< 0x0000001C Global range detect mode register. */
  __IOM uint32_t CHAN_EN;                       /*!< 0x00000020 Enable bits for the channels */
  __IOM uint32_t START_CTRL;                    /*!< 0x00000024 Start control register (firmware trigger). */
   __IM uint32_t RESERVED1[2];
  __IOM uint32_t DFT_CTRL;                      /*!< 0x00000030 DFT control register. */
   __IM uint32_t RESERVED2[19];
  __IOM uint32_t CHAN_CONFIG[16];               /*!< 0x00000080 Channel configuration register. */
   __IM uint32_t RESERVED3[16];
   __IM uint32_t CHAN_WORK[16];                 /*!< 0x00000100 Channel working data register */
   __IM uint32_t RESERVED4[16];
   __IM uint32_t CHAN_RESULT[16];               /*!< 0x00000180 Channel result data register */
   __IM uint32_t RESERVED5[16];
   __IM uint32_t CHAN_WORK_VALID;               /*!< 0x00000200 Channel working data register valid bits */
   __IM uint32_t CHAN_RESULT_VALID;             /*!< 0x00000204 Channel result data register valid bits */
   __IM uint32_t STATUS;                        /*!< 0x00000208 Current status of internal SAR registers (mostly for debug) */
   __IM uint32_t AVG_STAT;                      /*!< 0x0000020C Current averaging status (for debug) */
  __IOM uint32_t INTR;                          /*!< 0x00000210 Interrupt request register. */
  __IOM uint32_t INTR_SET;                      /*!< 0x00000214 Interrupt set request register */
  __IOM uint32_t INTR_MASK;                     /*!< 0x00000218 Interrupt mask register. */
   __IM uint32_t INTR_MASKED;                   /*!< 0x0000021C Interrupt masked request register */
  __IOM uint32_t SATURATE_INTR;                 /*!< 0x00000220 Saturate interrupt request register. */
  __IOM uint32_t SATURATE_INTR_SET;             /*!< 0x00000224 Saturate interrupt set request register */
  __IOM uint32_t SATURATE_INTR_MASK;            /*!< 0x00000228 Saturate interrupt mask register. */
   __IM uint32_t SATURATE_INTR_MASKED;          /*!< 0x0000022C Saturate interrupt masked request register */
  __IOM uint32_t RANGE_INTR;                    /*!< 0x00000230 Range detect interrupt request register. */
  __IOM uint32_t RANGE_INTR_SET;                /*!< 0x00000234 Range detect interrupt set request register */
  __IOM uint32_t RANGE_INTR_MASK;               /*!< 0x00000238 Range detect interrupt mask register. */
   __IM uint32_t RANGE_INTR_MASKED;             /*!< 0x0000023C Range interrupt masked request register */
   __IM uint32_t INTR_CAUSE;                    /*!< 0x00000240 Interrupt cause register */
   __IM uint32_t RESERVED6[15];
  __IOM uint32_t INJ_CHAN_CONFIG;               /*!< 0x00000280 Injection channel configuration register. */
   __IM uint32_t RESERVED7[3];
   __IM uint32_t INJ_RESULT;                    /*!< 0x00000290 Injection channel result register */
   __IM uint32_t RESERVED8[27];
  __IOM uint32_t MUX_SWITCH0;                   /*!< 0x00000300 SARMUX Firmware switch controls */
  __IOM uint32_t MUX_SWITCH_CLEAR0;             /*!< 0x00000304 SARMUX Firmware switch control clear */
  __IOM uint32_t MUX_SWITCH1;                   /*!< 0x00000308 SARMUX Firmware switch controls */
  __IOM uint32_t MUX_SWITCH_CLEAR1;             /*!< 0x0000030C SARMUX Firmware switch control clear */
   __IM uint32_t RESERVED9[12];
  __IOM uint32_t MUX_SWITCH_HW_CTRL;            /*!< 0x00000340 SARMUX switch hardware control */
   __IM uint32_t RESERVED10;
   __IM uint32_t MUX_SWITCH_STATUS;             /*!< 0x00000348 SARMUX switch status */
   __IM uint32_t RESERVED11[13];
  __IOM uint32_t PUMP_CTRL;                     /*!< 0x00000380 Switch pump control */
   __IM uint32_t RESERVED12[735];
  __IOM uint32_t ANA_TRIM;                      /*!< 0x00000F00 Analog trim register. */
  __IOM uint32_t WOUNDING;                      /*!< 0x00000F04 SAR wounding register */
} SAR_Type;   
#define CY_SAR_NUM_CHANNELS             17UL
typedef struct
{
    uint32_t muxSwitch;                                   /**< SARMUX firmware switches to connect analog signals to SAR */
    uint32_t muxSwitchHwCtrl;                             /**< Enable SARSEQ control of specific SARMUX switches */
} cy_stc_sar_routing_config_t;
typedef struct
{
    uint32_t addr;           /**< The combined SARMUX port address and pin address value. */
    bool differential;                                    /**< Differential enable for this channel.
                                                           *   - false: The voltage on the addressed pin is measured (Single-ended)
                                                           *   and the resulting value is stored in the corresponding data register.
                                                           *   - true: The differential voltage on the addressed pin pair is measured
                                                           *   and the resulting value is stored in the corresponding data register. (pinAddr[0] is ignored).
                                                           */
    uint8_t resolution;       /**< Resolution for this channel.  When AVG_EN is set this bit is ignored and
                                                           * always a 12-bit resolution (or highest resolution allowed by wounding) is used for this channel.
                                                           */
    bool avgEn;                                           /**< Averaging enable for this channel. If set the avgCnt and avgShift settings are used for sampling the addressed pin(s) */
    uint8_t sampleTimeSel;         /**< Sample time select: select which of the 4 global sample times to use for this channel */
    bool rangeIntrEn;                                     /**< Range detection interrupt enable */
    bool satIntrEn;                                       /**< Saturation detection interrupt enable */
} cy_stc_sar_channel_config_t;

typedef struct
{
    uint8_t vrefSel;                    /**< Internal VREF selection */
    bool vrefBypCapEn;                                    /**< VREF bypass cap enable for when VREF buffer is on */
    uint8_t negSel;                      /**< Internal NEG selection for Single ended conversion */
    bool negVref;             /**< Hardware control of the VREF to NEG switch */
    bool boostPump;                                       /**< Internal pump:
                                                           *   false = disabled/bypassed, pump output is VDDA,
                                                           *   true = enabled, pump output is boosted.
                                                           */
    uint8_t power;                           /**< Power mode */
    bool sarMuxDsEn;                                      /**< Enable SarMux during Deep Sleep cycle */
    bool switchDisable;                                   /**< Disable SAR sequencer from enabling routing switches (note DSI and firmware can always close switches independent of this control) */
    uint8_t subResolution; /**< Conversion resolution for channels that have sub-resolution enabled */
    bool leftAlign;                                       /**< Left align data in data[15:0], default data is right aligned in data[11:0], with sign extension to 16 bits if the channel is differential. */
    bool singleEndedSigned;                               /**< Output data from a single ended conversion as a signed value */
    bool differentialSigned;                              /**< Output data from a differential conversion as a signed value */
    uint8_t avgCnt;               /**< Averaging Count for channels that have over sampling enabled (avgEn = true).
                                                           *   A channel will be sampled back to back avgCnt times before the result is stored and
                                                           *   the next enabled channel is sampled (1st order accumulate and dump filter).
                                                           *   If shifting is not enabled (avgShift = true) then the result is forced to shift right so that is fits in 16 bits,
                                                           *   so right shift is done by max(0,AVG_CNT-3).
                                                           */
    bool avgShift;                                        /**< Averaging shifting: after averaging the result is shifted right to fit in the sample resolution.
                                                           *   For averaging the sample resolution is the highest resolution allowed by wounding.
                                                           */
    uint8_t trigMode;        /**< Trigger Mode: FW only, edge or level sensitive */
    bool eosEn;                                           /**< Enable to output EOS_INTR to trigger output. When enabled each time EOS_INTR is set by the hardware also a pulse is send on the trigger signal. */
    uint32_t sampleTime0;                                 /**< Sample time in ADC clocks for Sample Time 0. 
                                                           *   For all the sampleTimeX fields, valid range is 2 - 1023 cycles.
                                                           *   The minimum aperture time is 167 ns. With an 18 MHz ADC clock, this is
                                                           *   equal to 3 cycles or a value of 4 in this field.
                                                           *   The actual aperture time is one cycle less than the value stored in this field.
                                                           */
    uint32_t sampleTime1;                                 /**< Sample time in ADC clocks for Sample Time 1 */
    uint32_t sampleTime2;                                 /**< Sample time in ADC clocks for Sample Time 2 */
    uint32_t sampleTime3;                                 /**< Sample time in ADC clocks for Sample Time 3 */
    uint32_t rangeThresLow;                               /**< Range detect low threshold for all channels. Used to generate range interrupt. 
                                                           *   Range detection for both rangeThresLow and rangeThresHigh is done after averaging, alignment, and sign extension (if applicable),
                                                           *   i.e. threshold values need to have the same data format as the result data.
                                                           *   The values are interpreted as signed or unsigned according to each channel's configuration */
    uint32_t rangeThresHigh;                              /**< Range detect high threshold for all channels. Used to generate range interrupt */
    uint8_t rangeCond;         /**< Range detect condition (below, inside, output, or above) for all channels. Used to generate range interrupt */
    uint32_t chanEn;                                      /**< Enable bits for the channels.
                                                            *  All the sequential channels bits are within \ref CY_SAR_CHANNELS_MASK,
                                                            *  the injection channel mask is \ref CY_SAR_INJ_CHAN_MASK.
                                                            */
    const cy_stc_sar_channel_config_t * channelConfig[CY_SAR_NUM_CHANNELS]; /**< Pointers to channel configuration structures, NULL means the channel is not configured */
    const cy_stc_sar_routing_config_t * routingConfig;    /**< Pointer to the routing configuration structure. Can be NULL in case of no need to configure the routing */
    uint32_t vrefMvValue;                                 /**< Reference voltage in millivolts used in converting counts to volts */
} cy_stc_sar_config_t;


#define SAR0_BASE                               0x403A0000UL
#define SAR0                                    ((SAR_Type*) SAR0_BASE)    
  
#define SAR_SAMPLE_CTRL(base)               (((SAR_Type *)(base))->SAMPLE_CTRL)
#define SAR_SAMPLE_TIME01(base)             (((SAR_Type *)(base))->SAMPLE_TIME01)
#define SAR_SAMPLE_TIME23(base)             (((SAR_Type *)(base))->SAMPLE_TIME23)

#define SAR_RANGE_THRES(base)               (((SAR_Type *)(base))->RANGE_THRES)
#define SAR_RANGE_COND(base)                (((SAR_Type *)(base))->RANGE_COND)
#define SAR_RANGE_INTR(base)                (((SAR_Type *)(base))->RANGE_INTR)
#define SAR_RANGE_INTR_SET(base)            (((SAR_Type *)(base))->RANGE_INTR_SET)

#define SAR_RANGE_INTR_MASK(base)           (((SAR_Type *)(base))->RANGE_INTR_MASK)
#define SAR_RANGE_INTR_MASKED(base)         (((SAR_Type *)(base))->RANGE_INTR_MASKED)

#define SAR_CHAN_EN(base)                   (((SAR_Type *)(base))->CHAN_EN)
#define SAR_CHAN_CONFIG(base, chan)         (((SAR_Type *)(base))->CHAN_CONFIG[(chan)])
#define SAR_CHAN_RESULT(base, chan)         (((SAR_Type *)(base))->CHAN_RESULT[(chan)])
#define SAR_CHAN_RESULT_VALID(base)         (((SAR_Type *)(base))->CHAN_RESULT_VALID)

#define SAR_INTR(base)                      (((SAR_Type *)(base))->INTR)
#define SAR_INTR_MASK(base)                 (((SAR_Type *)(base))->INTR_MASK)
#define SAR_INTR_MASKED(base)               (((SAR_Type *)(base))->INTR_MASKED)
#define SAR_INTR_SET(base)                  (((SAR_Type *)(base))->INTR_SET)
#define SAR_INTR_CAUSE(base)                (((SAR_Type *)(base))->INTR_CAUSE)

#define SAR_MUX_SWITCH_CLEAR0(base)         (((SAR_Type *)(base))->MUX_SWITCH_CLEAR0)
#define SAR_MUX_SWITCH0(base)               (((SAR_Type *)(base))->MUX_SWITCH0)
#define SAR_MUX_SWITCH_HW_CTRL(base)        (((SAR_Type *)(base))->MUX_SWITCH_HW_CTRL)

#define SAR_ANA_TRIM(base)                  (((SAR_Type *)(base))->ANA_TRIM)
#define SAR_PUMP_CTRL(base)                 (((SAR_Type *)(base))->PUMP_CTRL)
#define SAR_CTRL(base)                      (((SAR_Type *)(base))->CTRL)
#define SAR_STATUS(base)                    (((SAR_Type *)(base))->STATUS)
#define SAR_START_CTRL(base)                (((SAR_Type *)(base))->START_CTRL)

#define SAR_SATURATE_INTR(base)             (((SAR_Type *)(base))->SATURATE_INTR)
#define SAR_SATURATE_INTR_MASK(base)        (((SAR_Type *)(base))->SATURATE_INTR_MASK)
#define SAR_SATURATE_INTR_MASKED(base)      (((SAR_Type *)(base))->SATURATE_INTR_MASKED)
#define SAR_SATURATE_INTR_SET(base)         (((SAR_Type *)(base))->SATURATE_INTR_SET)

#define SAR_INJ_CHAN_CONFIG(base)           (((SAR_Type *)(base))->INJ_CHAN_CONFIG)
#define SAR_INJ_RESULT(base)                (((SAR_Type *)(base))->INJ_RESULT)

/* SAR.CTRL */
#define SAR_CTRL_VREF_SEL_Pos                   4UL
#define SAR_CTRL_VREF_SEL_Msk                   0x70UL
#define SAR_CTRL_VREF_BYP_CAP_EN_Pos            7UL
#define SAR_CTRL_VREF_BYP_CAP_EN_Msk            0x80UL
#define SAR_CTRL_NEG_SEL_Pos                    9UL
#define SAR_CTRL_NEG_SEL_Msk                    0xE00UL
#define SAR_CTRL_SAR_HW_CTRL_NEGVREF_Pos        13UL
#define SAR_CTRL_SAR_HW_CTRL_NEGVREF_Msk        0x2000UL
#define SAR_CTRL_PWR_CTRL_VREF_Pos              14UL
#define SAR_CTRL_PWR_CTRL_VREF_Msk              0xC000UL
#define SAR_CTRL_SPARE_Pos                      16UL
#define SAR_CTRL_SPARE_Msk                      0xF0000UL
#define SAR_CTRL_BOOSTPUMP_EN_Pos               20UL
#define SAR_CTRL_BOOSTPUMP_EN_Msk               0x100000UL
#define SAR_CTRL_ICONT_LV_Pos                   24UL
#define SAR_CTRL_ICONT_LV_Msk                   0x3000000UL
#define SAR_CTRL_DEEPSLEEP_ON_Pos               27UL
#define SAR_CTRL_DEEPSLEEP_ON_Msk               0x8000000UL
#define SAR_CTRL_DSI_SYNC_CONFIG_Pos            28UL
#define SAR_CTRL_DSI_SYNC_CONFIG_Msk            0x10000000UL
#define SAR_CTRL_DSI_MODE_Pos                   29UL
#define SAR_CTRL_DSI_MODE_Msk                   0x20000000UL
#define SAR_CTRL_SWITCH_DISABLE_Pos             30UL
#define SAR_CTRL_SWITCH_DISABLE_Msk             0x40000000UL
#define SAR_CTRL_ENABLED_Pos                    31UL
#define SAR_CTRL_ENABLED_Msk                    0x80000000UL
/* SAR.SAMPLE_CTRL */
#define SAR_SAMPLE_CTRL_SUB_RESOLUTION_Pos      0UL
#define SAR_SAMPLE_CTRL_SUB_RESOLUTION_Msk      0x1UL
#define SAR_SAMPLE_CTRL_LEFT_ALIGN_Pos          1UL
#define SAR_SAMPLE_CTRL_LEFT_ALIGN_Msk          0x2UL
#define SAR_SAMPLE_CTRL_SINGLE_ENDED_SIGNED_Pos 2UL
#define SAR_SAMPLE_CTRL_SINGLE_ENDED_SIGNED_Msk 0x4UL
#define SAR_SAMPLE_CTRL_DIFFERENTIAL_SIGNED_Pos 3UL
#define SAR_SAMPLE_CTRL_DIFFERENTIAL_SIGNED_Msk 0x8UL
#define SAR_SAMPLE_CTRL_AVG_CNT_Pos             4UL
#define SAR_SAMPLE_CTRL_AVG_CNT_Msk             0x70UL
#define SAR_SAMPLE_CTRL_AVG_SHIFT_Pos           7UL
#define SAR_SAMPLE_CTRL_AVG_SHIFT_Msk           0x80UL
#define SAR_SAMPLE_CTRL_CONTINUOUS_Pos          16UL
#define SAR_SAMPLE_CTRL_CONTINUOUS_Msk          0x10000UL
#define SAR_SAMPLE_CTRL_DSI_TRIGGER_EN_Pos      17UL
#define SAR_SAMPLE_CTRL_DSI_TRIGGER_EN_Msk      0x20000UL
#define SAR_SAMPLE_CTRL_DSI_TRIGGER_LEVEL_Pos   18UL
#define SAR_SAMPLE_CTRL_DSI_TRIGGER_LEVEL_Msk   0x40000UL
#define SAR_SAMPLE_CTRL_DSI_SYNC_TRIGGER_Pos    19UL
#define SAR_SAMPLE_CTRL_DSI_SYNC_TRIGGER_Msk    0x80000UL
#define SAR_SAMPLE_CTRL_EOS_DSI_OUT_EN_Pos      31UL
#define SAR_SAMPLE_CTRL_EOS_DSI_OUT_EN_Msk      0x80000000UL
/* SAR.SAMPLE_TIME01 */
#define SAR_SAMPLE_TIME01_SAMPLE_TIME0_Pos      0UL
#define SAR_SAMPLE_TIME01_SAMPLE_TIME0_Msk      0x3FFUL
#define SAR_SAMPLE_TIME01_SAMPLE_TIME1_Pos      16UL
#define SAR_SAMPLE_TIME01_SAMPLE_TIME1_Msk      0x3FF0000UL
/* SAR.SAMPLE_TIME23 */
#define SAR_SAMPLE_TIME23_SAMPLE_TIME2_Pos      0UL
#define SAR_SAMPLE_TIME23_SAMPLE_TIME2_Msk      0x3FFUL
#define SAR_SAMPLE_TIME23_SAMPLE_TIME3_Pos      16UL
#define SAR_SAMPLE_TIME23_SAMPLE_TIME3_Msk      0x3FF0000UL
/* SAR.RANGE_THRES */
#define SAR_RANGE_THRES_RANGE_LOW_Pos           0UL
#define SAR_RANGE_THRES_RANGE_LOW_Msk           0xFFFFUL
#define SAR_RANGE_THRES_RANGE_HIGH_Pos          16UL
#define SAR_RANGE_THRES_RANGE_HIGH_Msk          0xFFFF0000UL
/* SAR.RANGE_COND */
#define SAR_RANGE_COND_RANGE_COND_Pos           30UL
#define SAR_RANGE_COND_RANGE_COND_Msk           0xC0000000UL
/* SAR.CHAN_EN */
#define SAR_CHAN_EN_CHAN_EN_Pos                 0UL
#define SAR_CHAN_EN_CHAN_EN_Msk                 0xFFFFUL
/* SAR.START_CTRL */
#define SAR_START_CTRL_FW_TRIGGER_Pos           0UL
#define SAR_START_CTRL_FW_TRIGGER_Msk           0x1UL
/* SAR.CHAN_CONFIG */
#define SAR_CHAN_CONFIG_PIN_ADDR_Pos            0UL
#define SAR_CHAN_CONFIG_PIN_ADDR_Msk            0x7UL
#define SAR_CHAN_CONFIG_PORT_ADDR_Pos           4UL
#define SAR_CHAN_CONFIG_PORT_ADDR_Msk           0x70UL
#define SAR_CHAN_CONFIG_DIFFERENTIAL_EN_Pos     8UL
#define SAR_CHAN_CONFIG_DIFFERENTIAL_EN_Msk     0x100UL
#define SAR_CHAN_CONFIG_RESOLUTION_Pos          9UL
#define SAR_CHAN_CONFIG_RESOLUTION_Msk          0x200UL
#define SAR_CHAN_CONFIG_AVG_EN_Pos              10UL
#define SAR_CHAN_CONFIG_AVG_EN_Msk              0x400UL
#define SAR_CHAN_CONFIG_SAMPLE_TIME_SEL_Pos     12UL
#define SAR_CHAN_CONFIG_SAMPLE_TIME_SEL_Msk     0x3000UL
#define SAR_CHAN_CONFIG_DSI_OUT_EN_Pos          31UL
#define SAR_CHAN_CONFIG_DSI_OUT_EN_Msk          0x80000000UL

/* SAR.CHAN_RESULT */
#define SAR_CHAN_RESULT_RESULT_Pos              0UL
#define SAR_CHAN_RESULT_RESULT_Msk              0xFFFFUL
#define SAR_CHAN_RESULT_SATURATE_INTR_MIR_Pos   29UL
#define SAR_CHAN_RESULT_SATURATE_INTR_MIR_Msk   0x20000000UL
#define SAR_CHAN_RESULT_RANGE_INTR_MIR_Pos      30UL
#define SAR_CHAN_RESULT_RANGE_INTR_MIR_Msk      0x40000000UL
#define SAR_CHAN_RESULT_CHAN_RESULT_VALID_MIR_Pos 31UL
#define SAR_CHAN_RESULT_CHAN_RESULT_VALID_MIR_Msk 0x80000000UL

/* SAR.AVG_STAT */
#define SAR_AVG_STAT_CUR_AVG_ACCU_Pos           0UL
#define SAR_AVG_STAT_CUR_AVG_ACCU_Msk           0xFFFFFUL
#define SAR_AVG_STAT_CUR_AVG_CNT_Pos            24UL
#define SAR_AVG_STAT_CUR_AVG_CNT_Msk            0xFF000000UL
/* SAR.INTR */
#define SAR_INTR_EOS_INTR_Pos                   0UL
#define SAR_INTR_EOS_INTR_Msk                   0x1UL
#define SAR_INTR_OVERFLOW_INTR_Pos              1UL
#define SAR_INTR_OVERFLOW_INTR_Msk              0x2UL
#define SAR_INTR_FW_COLLISION_INTR_Pos          2UL
#define SAR_INTR_FW_COLLISION_INTR_Msk          0x4UL
#define SAR_INTR_DSI_COLLISION_INTR_Pos         3UL
#define SAR_INTR_DSI_COLLISION_INTR_Msk         0x8UL
#define SAR_INTR_INJ_EOC_INTR_Pos               4UL
#define SAR_INTR_INJ_EOC_INTR_Msk               0x10UL
#define SAR_INTR_INJ_SATURATE_INTR_Pos          5UL
#define SAR_INTR_INJ_SATURATE_INTR_Msk          0x20UL
#define SAR_INTR_INJ_RANGE_INTR_Pos             6UL
#define SAR_INTR_INJ_RANGE_INTR_Msk             0x40UL
#define SAR_INTR_INJ_COLLISION_INTR_Pos         7UL
#define SAR_INTR_INJ_COLLISION_INTR_Msk         0x80UL

/* SAR.MUX_SWITCH0 */
#define SAR_MUX_SWITCH0_MUX_FW_P0_VPLUS_Pos     0UL
#define SAR_MUX_SWITCH0_MUX_FW_P0_VPLUS_Msk     0x1UL
#define SAR_MUX_SWITCH0_MUX_FW_P1_VPLUS_Pos     1UL
#define SAR_MUX_SWITCH0_MUX_FW_P1_VPLUS_Msk     0x2UL
#define SAR_MUX_SWITCH0_MUX_FW_P2_VPLUS_Pos     2UL
#define SAR_MUX_SWITCH0_MUX_FW_P2_VPLUS_Msk     0x4UL
#define SAR_MUX_SWITCH0_MUX_FW_P3_VPLUS_Pos     3UL
#define SAR_MUX_SWITCH0_MUX_FW_P3_VPLUS_Msk     0x8UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_VPLUS_Pos     4UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_VPLUS_Msk     0x10UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_VPLUS_Pos     5UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_VPLUS_Msk     0x20UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_VPLUS_Pos     6UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_VPLUS_Msk     0x40UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_VPLUS_Pos     7UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_VPLUS_Msk     0x80UL
#define SAR_MUX_SWITCH0_MUX_FW_P0_VMINUS_Pos    8UL
#define SAR_MUX_SWITCH0_MUX_FW_P0_VMINUS_Msk    0x100UL
#define SAR_MUX_SWITCH0_MUX_FW_P1_VMINUS_Pos    9UL
#define SAR_MUX_SWITCH0_MUX_FW_P1_VMINUS_Msk    0x200UL
#define SAR_MUX_SWITCH0_MUX_FW_P2_VMINUS_Pos    10UL
#define SAR_MUX_SWITCH0_MUX_FW_P2_VMINUS_Msk    0x400UL
#define SAR_MUX_SWITCH0_MUX_FW_P3_VMINUS_Pos    11UL
#define SAR_MUX_SWITCH0_MUX_FW_P3_VMINUS_Msk    0x800UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_VMINUS_Pos    12UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_VMINUS_Msk    0x1000UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_VMINUS_Pos    13UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_VMINUS_Msk    0x2000UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_VMINUS_Pos    14UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_VMINUS_Msk    0x4000UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_VMINUS_Pos    15UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_VMINUS_Msk    0x8000UL
#define SAR_MUX_SWITCH0_MUX_FW_VSSA_VMINUS_Pos  16UL
#define SAR_MUX_SWITCH0_MUX_FW_VSSA_VMINUS_Msk  0x10000UL
#define SAR_MUX_SWITCH0_MUX_FW_TEMP_VPLUS_Pos   17UL
#define SAR_MUX_SWITCH0_MUX_FW_TEMP_VPLUS_Msk   0x20000UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSA_VPLUS_Pos 18UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSA_VPLUS_Msk 0x40000UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSB_VPLUS_Pos 19UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSB_VPLUS_Msk 0x80000UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSA_VMINUS_Pos 20UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSA_VMINUS_Msk 0x100000UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSB_VMINUS_Pos 21UL
#define SAR_MUX_SWITCH0_MUX_FW_AMUXBUSB_VMINUS_Msk 0x200000UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS0_VPLUS_Pos 22UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS0_VPLUS_Msk 0x400000UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS1_VPLUS_Pos 23UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS1_VPLUS_Msk 0x800000UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS0_VMINUS_Pos 24UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS0_VMINUS_Msk 0x1000000UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS1_VMINUS_Pos 25UL
#define SAR_MUX_SWITCH0_MUX_FW_SARBUS1_VMINUS_Msk 0x2000000UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_COREIO0_Pos   26UL
#define SAR_MUX_SWITCH0_MUX_FW_P4_COREIO0_Msk   0x4000000UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_COREIO1_Pos   27UL
#define SAR_MUX_SWITCH0_MUX_FW_P5_COREIO1_Msk   0x8000000UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_COREIO2_Pos   28UL
#define SAR_MUX_SWITCH0_MUX_FW_P6_COREIO2_Msk   0x10000000UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_COREIO3_Pos   29UL
#define SAR_MUX_SWITCH0_MUX_FW_P7_COREIO3_Msk   0x20000000UL

/* SAR.MUX_SWITCH_HW_CTRL */
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P0_Pos 0UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P0_Msk 0x1UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P1_Pos 1UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P1_Msk 0x2UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P2_Pos 2UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P2_Msk 0x4UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P3_Pos 3UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P3_Msk 0x8UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P4_Pos 4UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P4_Msk 0x10UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P5_Pos 5UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P5_Msk 0x20UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P6_Pos 6UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P6_Msk 0x40UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P7_Pos 7UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P7_Msk 0x80UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_VSSA_Pos 16UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_VSSA_Msk 0x10000UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_TEMP_Pos 17UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_TEMP_Msk 0x20000UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_AMUXBUSA_Pos 18UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_AMUXBUSA_Msk 0x40000UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_AMUXBUSB_Pos 19UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_AMUXBUSB_Msk 0x80000UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_SARBUS0_Pos 22UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_SARBUS0_Msk 0x400000UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_SARBUS1_Pos 23UL
#define SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_SARBUS1_Msk 0x800000UL
/* SAR.INJ_CHAN_CONFIG */
#define SAR_INJ_CHAN_CONFIG_INJ_PIN_ADDR_Pos    0UL
#define SAR_INJ_CHAN_CONFIG_INJ_PIN_ADDR_Msk    0x7UL
#define SAR_INJ_CHAN_CONFIG_INJ_PORT_ADDR_Pos   4UL
#define SAR_INJ_CHAN_CONFIG_INJ_PORT_ADDR_Msk   0x70UL
#define SAR_INJ_CHAN_CONFIG_INJ_DIFFERENTIAL_EN_Pos 8UL
#define SAR_INJ_CHAN_CONFIG_INJ_DIFFERENTIAL_EN_Msk 0x100UL
#define SAR_INJ_CHAN_CONFIG_INJ_RESOLUTION_Pos  9UL
#define SAR_INJ_CHAN_CONFIG_INJ_RESOLUTION_Msk  0x200UL
#define SAR_INJ_CHAN_CONFIG_INJ_AVG_EN_Pos      10UL
#define SAR_INJ_CHAN_CONFIG_INJ_AVG_EN_Msk      0x400UL
#define SAR_INJ_CHAN_CONFIG_INJ_SAMPLE_TIME_SEL_Pos 12UL
#define SAR_INJ_CHAN_CONFIG_INJ_SAMPLE_TIME_SEL_Msk 0x3000UL
#define SAR_INJ_CHAN_CONFIG_INJ_TAILGATING_Pos  30UL
#define SAR_INJ_CHAN_CONFIG_INJ_TAILGATING_Msk  0x40000000UL
#define SAR_INJ_CHAN_CONFIG_INJ_START_EN_Pos    31UL
#define SAR_INJ_CHAN_CONFIG_INJ_START_EN_Msk    0x80000000UL

typedef enum
{
    CY_SAR_ADDR_SARMUX_0         = 0x0UL,  /**< Dedicated SARMUX pin 0 */
    CY_SAR_ADDR_SARMUX_1         = 0x1UL,  /**< Dedicated SARMUX pin 1, valid for single ended channels only */
    CY_SAR_ADDR_SARMUX_2         = 0x2UL,  /**< Dedicated SARMUX pin 2 */
    CY_SAR_ADDR_SARMUX_3         = 0x3UL,  /**< Dedicated SARMUX pin 3, valid for single ended channels only */
    CY_SAR_ADDR_SARMUX_4         = 0x4UL,  /**< Dedicated SARMUX pin 4 */
    CY_SAR_ADDR_SARMUX_5         = 0x5UL,  /**< Dedicated SARMUX pin 5, valid for single ended channels only */
    CY_SAR_ADDR_SARMUX_6         = 0x6UL,  /**< Dedicated SARMUX pin 6 */
    CY_SAR_ADDR_SARMUX_7         = 0x7UL,  /**< Dedicated SARMUX pin 7, valid for single ended channels only */
    CY_SAR_ADDR_CTB0_OA0         = 0x12UL,  /**< CTB0 OA0 output, if present */
    CY_SAR_ADDR_CTB0_OA1         = 0x13UL,  /**< CTB0 OA1 output, if present */
    CY_SAR_ADDR_CTB1_OA0         = 0x22UL,  /**< CTB1 OA0 output, if present */
    CY_SAR_ADDR_CTB1_OA1         = 0x23UL,  /**< CTB1 OA1 output, if present */
    CY_SAR_ADDR_CTB2_OA0         = 0x32UL,  /**< CTB2 OA0 output, if present */
    CY_SAR_ADDR_CTB2_OA1         = 0x33UL,  /**< CTB2 OA1 output, if present */
    CY_SAR_ADDR_CTB3_OA0         = 0x42UL,  /**< CTB3 OA0 output, if present */
    CY_SAR_ADDR_CTB3_OA1         = 0x43UL,  /**< CTB3 OA1 output, if present */
    CY_SAR_ADDR_SARMUX_DIE_TEMP  = 0x70UL,  /**< SARMUX virtual port for DieTemp */
    CY_SAR_ADDR_SARMUX_AMUXBUS_A = 0x72UL,  /**< SARMUX virtual port for AMUXBUSA */
    CY_SAR_ADDR_SARMUX_AMUXBUS_B = 0x73UL   /**< SARMUX virtual port for AMUXBUSB */
} cy_en_sar_chan_config_port_pin_addr_t;

#define SAR_INTR_MASK_EOS_MASK_Pos              0UL
#define SAR_INTR_MASK_EOS_MASK_Msk              0x1UL
#define SAR_INTR_MASK_OVERFLOW_MASK_Pos         1UL
#define SAR_INTR_MASK_OVERFLOW_MASK_Msk         0x2UL
#define SAR_INTR_MASK_FW_COLLISION_MASK_Pos     2UL
#define SAR_INTR_MASK_FW_COLLISION_MASK_Msk     0x4UL
#define SAR_INTR_MASK_DSI_COLLISION_MASK_Pos    3UL
#define SAR_INTR_MASK_DSI_COLLISION_MASK_Msk    0x8UL
#define SAR_INTR_MASK_INJ_EOC_MASK_Pos          4UL
#define SAR_INTR_MASK_INJ_EOC_MASK_Msk          0x10UL
#define SAR_INTR_MASK_INJ_SATURATE_MASK_Pos     5UL
#define SAR_INTR_MASK_INJ_SATURATE_MASK_Msk     0x20UL
#define SAR_INTR_MASK_INJ_RANGE_MASK_Pos        6UL
#define SAR_INTR_MASK_INJ_RANGE_MASK_Msk        0x40UL
#define SAR_INTR_MASK_INJ_COLLISION_MASK_Pos    7UL
#define SAR_INTR_MASK_INJ_COLLISION_MASK_Msk    0x80UL

/* HSIOM.AMUX_SPLIT_CTL */
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_SL_Pos   0UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_SL_Msk   0x1UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_SR_Pos   1UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_SR_Msk   0x2UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_S0_Pos   2UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_AA_S0_Msk   0x4UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SL_Pos   4UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SL_Msk   0x10UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SR_Pos   5UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SR_Msk   0x20UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_S0_Pos   6UL
#define HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_S0_Msk   0x40UL
typedef struct {
  __IOM uint32_t PORT_SEL;                      /*!< 0x00000000 Port selection register */
   __IM uint32_t RESERVED[63];
} HSIOM_PRT_Type_t; 
 
typedef struct {
        HSIOM_PRT_Type_t PRT[16];                 /*!< 0x00000000 HSIOM port registers */
   __IM uint32_t RESERVED[1024];
  __IOM uint32_t PUMP_CTL;                      /*!< 0x00002000 Pump control */
   __IM uint32_t RESERVED1[63];
  __IOM uint32_t AMUX_SPLIT_CTL[8];             /*!< 0x00002100 AMUX splitter cell control */
} HSIOM_Type;  
#define HSIOM_BASE                              0x40020000UL
#define HSIOM                                   ((HSIOM_Type*) HSIOM_BASE)                                        /* 0x40020000 */
/* SAR.INTR_MASKED */
#define CY_SAR_INTR_EOS                 (SAR_INTR_MASK_EOS_MASK_Msk)           /**< Enable end of scan (EOS) interrupt */
#define CY_SAR_INTR_OVERFLOW            (SAR_INTR_MASK_OVERFLOW_MASK_Msk)      /**< Enable overflow interrupt */
#define CY_SAR_INTR_FW_COLLISION        (SAR_INTR_MASK_FW_COLLISION_MASK_Msk)  /**< Enable firmware collision interrupt */
#define CY_SAR_INTR_INJ_EOC             (SAR_INTR_INJ_EOC_INTR_Msk)            /**< Enable injection channel end of conversion (EOC) interrupt */
#define CY_SAR_INTR_INJ_SATURATE        (SAR_INTR_INJ_SATURATE_INTR_Msk)       /**< Enable injection channel saturation interrupt */
#define CY_SAR_INTR_INJ_RANGE           (SAR_INTR_INJ_RANGE_INTR_Msk)          /**< Enable injection channel range detection interrupt */
#define CY_SAR_INTR_INJ_COLLISION       (SAR_INTR_INJ_COLLISION_INTR_Msk)      /**< Enable injection channel firmware collision interrupt */
#define SAR_CHAN_CONFIG_ADDR_Pos  (SAR_CHAN_CONFIG_PIN_ADDR_Pos)
#define SAR_CHAN_CONFIG_ADDR_Msk  (SAR_CHAN_CONFIG_PIN_ADDR_Msk | SAR_CHAN_CONFIG_PORT_ADDR_Msk)
/** Combined interrupt mask */
#define CY_SAR_INTR                     (CY_SAR_INTR_EOS | \
                                         CY_SAR_INTR_OVERFLOW | \
                                         CY_SAR_INTR_FW_COLLISION | \
                                         CY_SAR_INTR_INJ_EOC | \
                                         CY_SAR_INTR_INJ_SATURATE | \
                                         CY_SAR_INTR_INJ_RANGE | \
                                         CY_SAR_INTR_INJ_COLLISION)
  void Cy_SAR_Enable(SAR_Type * base);
  void Cy_SAR_StartConvert(SAR_Type * base, uint8_t startSelect);
  int16_t Cy_SAR_GetResult16(const SAR_Type * base, uint32_t chan);
  void Cy_SAR_Init(SAR_Type * base, const cy_stc_sar_config_t * config);
  void init_cycfg_peripherals(void);
  
  void Cy_SAR_ClearSatInterrupt(SAR_Type * base, uint32_t chanMask);
  void Cy_SAR_SetSatInterruptMask(SAR_Type * base, uint32_t chanMask);
  void Cy_SAR_SetRangeInterruptMask(SAR_Type * base, uint32_t chanMask);
  void Cy_SAR_ClearRangeInterrupt(SAR_Type * base, uint32_t chanMask);
  void Cy_SAR_ClearInterrupt(SAR_Type * base, uint32_t intrMask);
  void Cy_SAR_SetInterruptMask(SAR_Type * base, uint32_t intrMask);
  uint32_t Cy_SAR_GetInterruptStatus(const SAR_Type * base);
  void Cy_SAR_SetInterrupt(SAR_Type * base, uint32_t intrMask);
  int16_t Cy_SAR_CountsTo_mVolts(int16_t adcCounts);


  #endif

  