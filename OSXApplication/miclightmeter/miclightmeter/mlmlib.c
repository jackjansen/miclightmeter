//
//  mlmlib.c
//  miclightmeter
//
//  Created by Jack Jansen on 31/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#include "mlmlib.h"
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <stdint.h>
#include <limits.h>

struct mlm*
mlm_new()
{
    struct mlm *mlm = malloc(sizeof(struct mlm));
    if (mlm) {
        mlm_reset(mlm);
    }
    return mlm;
}

void
mlm_destroy(struct mlm *mlm)
{
    free(mlm);
}

void mlm_reset(struct mlm *mlm)
{
    mlm->mlm_curpolarity = 0;
    mlm->mlm_sumsamples = 0;
    mlm->mlm_sumabssamples = 0;
    mlm->mlm_nsamples = 0;
    mlm->mlm_last_to_positive = 0;
    mlm->mlm_initializing = 1;
    mlm->mlm_minstretch = -1;
    mlm->mlm_maxstretch = -1;
    mlm->mlm_allstretch = 0;
    mlm->mlm_nstretch = 0;
}

void mlm_feedfloat(struct mlm *mlm, float *data, int nsamples, int channels)
{
    while(nsamples > 0) {
        // Get next sample
        float sample = *data;
        data += channels;
        nsamples -= channels;
        
        // Update sums, for computing average and amplitude
        mlm->mlm_sumsamples += sample;
        mlm->mlm_sumabssamples += fabsf(sample);
        mlm->mlm_nsamples++;
        
        // Compute average and amplitude
        double average = mlm->mlm_sumsamples / mlm->mlm_nsamples;
        double amplitude = (mlm->mlm_sumabssamples-(average*mlm->mlm_nsamples)) / mlm->mlm_nsamples;
        if (amplitude > -0.00001 && amplitude < 0.00001) amplitude = 0;
        assert(amplitude >= 0);
        double threshold = amplitude / 10;
        
        // Compute polarity as three-way value, taking average and threshold into account
        int curpolarity = ((sample-average) < threshold ? -1 :
                           ((sample-average) > threshold ? 1 : 0));
        
        // Check whether we made a negative-to-positive or zero-to-positive transition
        if (curpolarity != mlm->mlm_curpolarity) {
            if (curpolarity > 0) {
                // We have made a zero-to-positive or megative-to-positive transition
                // Record duration of whole phase, if there was one
                if (mlm->mlm_last_to_positive) {
                    long nsample = mlm->mlm_last_to_positive;
                    mlm->mlm_last_to_positive = 0;
                    mlm->mlm_laststretch = nsample;
                    if (!mlm->mlm_initializing) {
                        // Record cur/min/max/average
                        mlm->mlm_allstretch += nsample;
                        mlm->mlm_nstretch++;
                        if (nsample < mlm->mlm_minstretch || mlm->mlm_minstretch < 0) mlm->mlm_minstretch = nsample;
                        if (nsample > mlm->mlm_maxstretch || mlm->mlm_maxstretch < 0) mlm->mlm_maxstretch = nsample;
                    }
                }
                mlm->mlm_initializing = 0;
            }
            mlm->mlm_curpolarity = curpolarity;
        }
        if (!mlm->mlm_initializing) mlm->mlm_last_to_positive++;
    }
    assert(nsamples == 0);
}

void mlm_feedint(struct mlm *mlm, void *data, int nbytes, int nbytepersample, int channels)
{
    while(nbytes > 0) {
        // Get next sample
        float sample;
        if (nbytepersample == 1) {
            int8_t sample_8 = *(int8_t *)data;
            sample = sample_8 / (float)INT8_MAX;
        } else if (nbytepersample == 2) {
            int16_t sample_16 = *(int16_t *)data;
            sample = sample_16 / (float)INT16_MAX;
        } else if (nbytepersample == 4) {
            int32_t sample_32 = *(int32_t *)data;
            sample = sample_32 / (float)INT32_MAX;
        } else {
            assert(0);
        }
        data += channels*nbytepersample;
        nbytes -= channels*nbytepersample;
        
        // Update sums, for computing average and amplitude
        mlm->mlm_sumsamples += sample;
        mlm->mlm_sumabssamples += fabsf(sample);
        mlm->mlm_nsamples++;
        
        // Compute average and amplitude
        double average = mlm->mlm_sumsamples / mlm->mlm_nsamples;
        double amplitude = (mlm->mlm_sumabssamples-(average*mlm->mlm_nsamples)) / mlm->mlm_nsamples;
        if (amplitude > -0.00001 && amplitude < 0.00001) amplitude = 0;
        assert(amplitude >= 0);
        double threshold = amplitude / 10;
        if (threshold == 0) threshold = 1;
        
        // Compute polarity as three-way value, taking average and threshold into account
        int curpolarity = ((sample-average) < threshold ? -1 :
                           ((sample-average) > threshold ? 1 : 0));
        
        // Check whether we made a negative-to-positive or zero-to-positive transition
        if (curpolarity != mlm->mlm_curpolarity) {
            if (curpolarity > 0) {
                // We have made a zero-to-positive or megative-to-positive transition
                // Record duration of whole phase, if there was one
                if (mlm->mlm_last_to_positive) {
                    long nsample = mlm->mlm_last_to_positive;
                    mlm->mlm_last_to_positive = 0;
                    mlm->mlm_laststretch = nsample;
                    if (!mlm->mlm_initializing) {
                        // Record cur/min/max/average
                        mlm->mlm_allstretch += nsample;
                        mlm->mlm_nstretch++;
                        if (nsample < mlm->mlm_minstretch || mlm->mlm_minstretch < 0) mlm->mlm_minstretch = nsample;
                        if (nsample > mlm->mlm_maxstretch || mlm->mlm_maxstretch < 0) mlm->mlm_maxstretch = nsample;
                    }
                }
                mlm->mlm_initializing = 0;
            }
            mlm->mlm_curpolarity = curpolarity;
        }
        if (!mlm->mlm_initializing) mlm->mlm_last_to_positive++;
    }
    assert(nbytes == 0);
}

void mlm_feedone(struct mlm *mlm, float sample)
{
    mlm_feedfloat(mlm, &sample, 1, 1);
}

double mlm_amplitude(struct mlm *mlm)
{
    // Compute average and amplitude
    double average = mlm->mlm_sumsamples / mlm->mlm_nsamples;
    double amplitude = (mlm->mlm_sumabssamples-(average*mlm->mlm_nsamples)) / mlm->mlm_nsamples;
    if (amplitude > -0.00001 && amplitude < 0.00001) amplitude = 0;
    assert(amplitude >= 0);
    return amplitude;
}

int mlm_ready(struct mlm *mlm)
{
    return mlm->mlm_minstretch > 0 && mlm->mlm_maxstretch > 0 && mlm->mlm_nstretch > 0;
}

double mlm_min(struct mlm *mlm)
{
    double rv = mlm->mlm_minstretch;
    return rv;
}

double mlm_max(struct mlm *mlm)
{
    double rv = mlm->mlm_maxstretch;
    return rv;
}

double mlm_average(struct mlm *mlm)
{
    if (mlm->mlm_nstretch <= 0) return 0;
    double rv = (double)mlm->mlm_allstretch / mlm->mlm_nstretch;
    return rv;
}

double mlm_current(struct mlm *mlm)
{
    if (mlm->mlm_nstretch <= 0) return 0;
    double rv = mlm->mlm_laststretch;
    return rv;
}

