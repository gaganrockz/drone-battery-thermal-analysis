/*********************************************************************
   UDF for temperature-dependent heat generation in LiPo battery
   Based on lumped battery model
**********************************************************************/

#include "udf.h"

DEFINE_SOURCE(battery_heat_source, cell, thread, dS, eqn)
{
    real T = C_T(cell, thread);           /* Cell temperature (K) */
    real T_celsius = T - 273.15;           /* Convert to Celsius */
    
    /* Battery parameters */
    real current = 50.0;                   /* Discharge current (A) - adjust per scenario */
    real R_ref = 0.02;                      /* Reference internal resistance at 25°C (Ω) */
    
    /* Temperature-dependent resistance (increases with temperature) */
    real R = R_ref * (1 + 0.005 * (T_celsius - 25));
    
    /* Heat generation: I²R (Joule heating) */
    real heat_source = pow(current, 2) * R;  /* Watts */
    
    /* Volume of battery cell (m³) */
    real cell_volume = 0.0000693;            /* 22mm × 45mm × 70mm */
    
    /* Volumetric heat source (W/m³) */
    real source_term = heat_source / cell_volume;
    
    /* Derivative for source term linearization */
    dS[eqn] = 2 * current * R * 0.005 / cell_volume;
    
    return source_term;
}