#include <stdint.h>
#include "ADC.h"
static int16_t Cy_SAR_offset[CY_SAR_NUM_CHANNELS][1];

void Cy_SAR_Init(SAR_Type * base, const cy_stc_sar_config_t * config)
{
    uint8_t chan;
    uint32_t satIntrMsk = 0UL;   /* Saturation interrupt mask */
    uint32_t rangeIntrMsk = 0UL; /* Range interrupt mask */

    SAR_CTRL(base) &= SAR_CTRL_DSI_SYNC_CONFIG_Msk | SAR_CTRL_DSI_MODE_Msk; /* preserve the DSI_SYNC_CONFIG and DSI_MODE fields (and BTW disable the block)  */
    SAR_CTRL(base) |= _VAL2FLD(SAR_CTRL_VREF_SEL, config->vrefSel) |
                        _BOOL2FLD(SAR_CTRL_VREF_BYP_CAP_EN, config->vrefBypCapEn) |
                        _VAL2FLD(SAR_CTRL_NEG_SEL, config->negSel) |
                        _VAL2FLD(SAR_CTRL_SAR_HW_CTRL_NEGVREF, config->negVref) |
                        _BOOL2FLD(SAR_CTRL_BOOSTPUMP_EN, config->boostPump) |
                        _VAL2FLD(SAR_CTRL_ICONT_LV, config->power) |
                        _BOOL2FLD(SAR_CTRL_DEEPSLEEP_ON, config->sarMuxDsEn) |
                        _BOOL2FLD(SAR_CTRL_SWITCH_DISABLE, config->switchDisable);

    SAR_SAMPLE_CTRL(base) &= SAR_SAMPLE_CTRL_DSI_SYNC_TRIGGER_Msk; /* preserve the DSI_SYNC_TRIGGER field  */
    SAR_SAMPLE_CTRL(base) |= _VAL2FLD(SAR_SAMPLE_CTRL_SUB_RESOLUTION, config->subResolution) |
                            _BOOL2FLD(SAR_SAMPLE_CTRL_LEFT_ALIGN, config->leftAlign) |
                            _BOOL2FLD(SAR_SAMPLE_CTRL_SINGLE_ENDED_SIGNED, config->singleEndedSigned) |
                            _BOOL2FLD(SAR_SAMPLE_CTRL_DIFFERENTIAL_SIGNED, config->differentialSigned) |
                                _VAL2FLD(SAR_SAMPLE_CTRL_AVG_CNT, config->avgCnt) |
                            _BOOL2FLD(SAR_SAMPLE_CTRL_AVG_SHIFT, config->avgShift) |
                                _VAL2FLD(SAR_SAMPLE_CTRL_DSI_TRIGGER_EN, config->trigMode) | //SAR_SAMPLE_CTRL_DSI_TRIGGER_MODE
                            _BOOL2FLD(SAR_SAMPLE_CTRL_EOS_DSI_OUT_EN, config->eosEn);

    SAR_SAMPLE_TIME01(base) = _VAL2FLD(SAR_SAMPLE_TIME01_SAMPLE_TIME0, config->sampleTime0) |
                                _VAL2FLD(SAR_SAMPLE_TIME01_SAMPLE_TIME1, config->sampleTime1);
    SAR_SAMPLE_TIME23(base) = _VAL2FLD(SAR_SAMPLE_TIME23_SAMPLE_TIME2, config->sampleTime2) |
                                _VAL2FLD(SAR_SAMPLE_TIME23_SAMPLE_TIME3, config->sampleTime3);
    SAR_RANGE_THRES(base) = _VAL2FLD(SAR_RANGE_THRES_RANGE_LOW, config->rangeThresLow) |
                            _VAL2FLD(SAR_RANGE_THRES_RANGE_HIGH, config->rangeThresHigh);
    SAR_RANGE_COND(base) = _VAL2FLD(SAR_RANGE_COND_RANGE_COND, config->rangeCond);

    SAR_CHAN_EN(base) = _VAL2FLD(SAR_CHAN_EN_CHAN_EN, config->chanEn);

    for (chan = 0u; chan < CY_SAR_NUM_CHANNELS; chan++)
    {
        const cy_stc_sar_channel_config_t * locChanCfg = config->channelConfig[chan];

        if (0 != locChanCfg)
        {
            if (chan <  8u ) //CY_SAR_INJ_CHANNEL
            {
                SAR_CHAN_CONFIG(base, chan) = _VAL2FLD(SAR_CHAN_CONFIG_ADDR, locChanCfg->addr) | //SAR_CHAN_CONFIG_ADDR
                                                _BOOL2FLD(SAR_CHAN_CONFIG_DIFFERENTIAL_EN, locChanCfg->differential) |
                                                _VAL2FLD(SAR_CHAN_CONFIG_RESOLUTION, locChanCfg->resolution) |
                                                _BOOL2FLD(SAR_CHAN_CONFIG_AVG_EN, locChanCfg->avgEn) |
                                                _VAL2FLD(SAR_CHAN_CONFIG_SAMPLE_TIME_SEL, locChanCfg->sampleTimeSel);
            }
            else
            {
                SAR_INJ_CHAN_CONFIG(base) = _VAL2FLD(SAR_CHAN_CONFIG_PIN_ADDR, locChanCfg->addr) |  //SAR_CHAN_CONFIG_ADDR
                                            _BOOL2FLD(SAR_INJ_CHAN_CONFIG_INJ_DIFFERENTIAL_EN, locChanCfg->differential) |
                                            _VAL2FLD(SAR_INJ_CHAN_CONFIG_INJ_RESOLUTION, locChanCfg->resolution) |
                                            _BOOL2FLD(SAR_INJ_CHAN_CONFIG_INJ_AVG_EN, locChanCfg->avgEn) |
                                            _VAL2FLD(SAR_INJ_CHAN_CONFIG_INJ_SAMPLE_TIME_SEL, locChanCfg->sampleTimeSel);
            }

            /* For signed single ended channels with NEG_SEL set to VREF,
                * set the offset to minus half scale to convert results to unsigned format
                */
            if (!(locChanCfg->differential) && (7UL == config->negSel) && (config->singleEndedSigned)) //CY_SAR_NEG_SEL_VREF
            {
                Cy_SAR_offset[chan][0] = (int16_t)0x00001000UL / -2; //CY_SAR_WRK_MAX_12BIT
            }
            else
            {
                Cy_SAR_offset[chan][1] = 0;
            }

            if (chan < CY_SAR_NUM_CHANNELS) /* All except the injection channel */
            {
                if (locChanCfg->rangeIntrEn)
                {
                    rangeIntrMsk |= 1UL << chan;
                }

                if (locChanCfg->satIntrEn)
                {
                    satIntrMsk |= 1UL << chan;
                }
            }
            else
            {
                uint32_t intrMsk = (locChanCfg->rangeIntrEn ? SAR_INTR_INJ_RANGE_INTR_Msk : 0UL) |
                                    (locChanCfg->satIntrEn ? SAR_INTR_INJ_SATURATE_INTR_Msk : 0UL);
                Cy_SAR_ClearInterrupt(base, intrMsk);
                Cy_SAR_SetInterruptMask(base, intrMsk);
            }
        }
    }

    Cy_SAR_ClearSatInterrupt(base, satIntrMsk);
    Cy_SAR_SetSatInterruptMask(base, satIntrMsk);
    Cy_SAR_ClearRangeInterrupt(base, rangeIntrMsk);
    Cy_SAR_SetRangeInterruptMask(base, rangeIntrMsk);



    SAR0->MUX_SWITCH_HW_CTRL = SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P1_Msk;
    SAR0->MUX_SWITCH0 = SAR_MUX_SWITCH0_MUX_FW_P1_VPLUS_Msk;
    SAR0->CTRL |= SAR_CTRL_ENABLED_Msk;

    SAR_MUX_SWITCH0(SAR0) = 0x10000UL; //CY_SAR_MUX_FW_VSSA_VMINUS Close switch between vssa_kelvin and vminus signal. Write with '1' to set bit.
    SAR_MUX_SWITCH_HW_CTRL(SAR0) |= 0x10000UL ; //CY_SAR_MUX_HW_CTRL_VSSA Hardware control masked by firmware setting for vssa switch.
    //HSIOM->AMUX_SPLIT_CTL[1] = HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SL_Msk | HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SR_Msk;
    
    


}

void Cy_SAR_ClearSatInterrupt(SAR_Type * base, uint32_t chanMask)
{
    SAR_SATURATE_INTR(base) = chanMask & CY_SAR_CHANNELS_MASK;
}


void Cy_SAR_Enable(SAR_Type * base)
{
    SAR_CTRL(base) |= 0x80000000UL ; // SAR_CTRL_ENABLED_Msk;
    /* The block is ready to use 2 us after the enable signal is set high. */
    
    for(int i=0;i<50000;i++); //delay
}

void init_cycfg_peripherals(void)
{
    SAR0->MUX_SWITCH_HW_CTRL = SAR_MUX_SWITCH_HW_CTRL_MUX_HW_CTRL_P1_Msk;
    SAR0->MUX_SWITCH0 = SAR_MUX_SWITCH0_MUX_FW_P1_VPLUS_Msk;
    SAR0->CTRL |= SAR_CTRL_ENABLED_Msk;

    SAR_MUX_SWITCH0(SAR0) = 0x10000UL; //CY_SAR_MUX_FW_VSSA_VMINUS Close switch between vssa_kelvin and vminus signal. Write with '1' to set bit.
    SAR_MUX_SWITCH_HW_CTRL(SAR0) |= 0x10000UL ; //CY_SAR_MUX_HW_CTRL_VSSA Hardware control masked by firmware setting for vssa switch.
    //HSIOM->AMUX_SPLIT_CTL[1] = HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SL_Msk | HSIOM_AMUX_SPLIT_CTL_SWITCH_BB_SR_Msk;
}

void Cy_SAR_StartConvert(SAR_Type * base, uint8_t startSelect)
{
    switch(startSelect)
    {
    case 0: 
        SAR_SAMPLE_CTRL(base) |= 0x10000UL; // //CY_SAR_START_CONVERT_CONTINUOUS
        break;
    case 1: 
        SAR_START_CTRL(base) = 0x1UL ; // CY_SAR_START_CONVERT_SINGLE_SHOT - Trigger
        break;
    default:
        /* do nothing */
        break;
    }
}

int16_t Cy_SAR_GetResult16(const SAR_Type * base, uint32_t chan)
{
    uint32_t adcResult = 0UL;
    uint32_t intr = 0;
    //wait till conversion is complete
    while (0UL == intr)
    {
        intr = SAR_INTR(base) & 0x1u;
        
    }
    SAR_INTR(base) |= 0x1u;
    
    //read results
    adcResult = _FLD2VAL(SAR_CHAN_RESULT_RESULT, SAR_CHAN_RESULT(base, chan));

    return (int16_t) adcResult;
}

void Cy_SAR_SetSatInterruptMask(SAR_Type * base, uint32_t chanMask)
{
    SAR_SATURATE_INTR_MASK(base) = chanMask & CY_SAR_CHANNELS_MASK;
}

void Cy_SAR_SetRangeInterruptMask(SAR_Type * base, uint32_t chanMask)
{
    SAR_RANGE_INTR_MASK(base) = chanMask & CY_SAR_CHANNELS_MASK;
}

void Cy_SAR_ClearRangeInterrupt(SAR_Type * base, uint32_t chanMask)
{
    SAR_RANGE_INTR(base) = chanMask & CY_SAR_CHANNELS_MASK;
}
void Cy_SAR_SetInterruptMask(SAR_Type * base, uint32_t intrMask)
{
    SAR_INTR_MASK(base) = intrMask & CY_SAR_INTR;
}
void Cy_SAR_ClearInterrupt(SAR_Type * base, uint32_t intrMask)
{
    SAR_INTR(base) = intrMask & CY_SAR_INTR;
}

int16_t Cy_SAR_CountsTo_mVolts(int16_t adcCounts)
{
    int32_t result_mVolts = (adcCounts * 5000)/2048;
    return (int16_t) result_mVolts;
}