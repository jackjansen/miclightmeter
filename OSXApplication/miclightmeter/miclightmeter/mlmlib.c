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
        _MLM_LOCK_ALLOC;
        mlm->mlm_stretches = NULL;
        mlm->mlm_stretches_size = 0;
        mlm->mlm_stretches_in = 0;
        mlm->mlm_stretches_out = 0;
        mlm_reset(mlm);
    }
    return mlm;
}

void
mlm_destroy(struct mlm *mlm)
{
    _MLM_LOCK_FREE;
    if (mlm->mlm_stretches) {
        free(mlm->mlm_stretches);
        mlm->mlm_stretches = NULL;
    }
    free(mlm);
}

void mlm_reset(struct mlm *mlm)
{
    _MLM_LOCK_ENTER;
    mlm->mlm_curpolarity = 0;
    mlm->mlm_sumsamples = 0;
    mlm->mlm_sumabsdeltas = 0;
    mlm->mlm_nsamples = 0;
    mlm->mlm_last_to_positive = 0;
    mlm->mlm_initializing = 2;
    mlm->mlm_minstretch = -1;
    mlm->mlm_maxstretch = -1;
    mlm->mlm_allstretch = 0;
    mlm->mlm_nstretch = 0;
    _MLM_LOCK_LEAVE;
}

static void _mlm_feedsample(struct mlm *mlm, double sample, long duration)
{
    
    // Update sums, for computing average and amplitude
    mlm->mlm_nsamples += duration;
    mlm->mlm_sumsamples += sample*duration;
    double average = mlm->mlm_sumsamples / mlm->mlm_nsamples;
    double delta = sample - average;
    mlm->mlm_sumabsdeltas += fabs(delta)*duration;
    
    // Compute average and amplitude
    double amplitude = mlm->mlm_sumabsdeltas / mlm->mlm_nsamples;
    if (amplitude > -0.00001 && amplitude < 0.00001) amplitude = 0;
    assert(amplitude >= 0);
    double threshold = amplitude / 10;
    
    // Compute polarity as three-way value, taking average and threshold into account
    int curpolarity = (delta < threshold ? -1 :
                       (delta > threshold ? 1 : 0));
    
    // Check whether we made a negative-to-positive or zero-to-positive transition
    if (curpolarity != mlm->mlm_curpolarity) {
        if (curpolarity > 0) {
            // We have made a zero-to-positive or negative-to-positive transition
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
                    // Record sample point. First make sure there is room.
                    if (mlm->mlm_stretches == NULL || mlm->mlm_stretches_in >= mlm->mlm_stretches_size) {
                        mlm->mlm_stretches_size += 16;
                        mlm->mlm_stretches = realloc(mlm->mlm_stretches, mlm->mlm_stretches_size*sizeof(*mlm->mlm_stretches));
                        assert(mlm->mlm_stretches);
                    }
                    assert(mlm->mlm_stretches_in >= 0);
                    assert(mlm->mlm_stretches_out <= mlm->mlm_stretches_in);
                    assert(mlm->mlm_stretches_in < mlm->mlm_stretches_size);
                    mlm->mlm_stretches[mlm->mlm_stretches_in++] = nsample;
                }
            }
            if (mlm->mlm_initializing > 0) mlm->mlm_initializing--;
        }
        mlm->mlm_curpolarity = curpolarity;
    }
    if (!mlm->mlm_initializing) mlm->mlm_last_to_positive += duration;
}

void mlm_feedfloat(struct mlm *mlm, float *data, int nsamples, int channels)
{
    _MLM_LOCK_ENTER;
    while(nsamples > 0) {
        // Get next sample
        float sample = *data;
        data += channels;
        nsamples -= channels;
        _mlm_feedsample(mlm, sample, 1);
     }
    assert(nsamples == 0);
    _MLM_LOCK_LEAVE;
}

void mlm_feedint(struct mlm *mlm, void *data, int nbytes, int nbytepersample, int channels)
{
    _MLM_LOCK_ENTER;
    while(nbytes > 0) {
        // Get next sample
        double sample;
        if (nbytepersample == 1) {
            int8_t sample_8 = *(int8_t *)data;
            sample = sample_8 / (double)INT8_MAX;
        } else if (nbytepersample == 2) {
            int16_t sample_16 = *(int16_t *)data;
            sample = sample_16 / (double)INT16_MAX;
        } else if (nbytepersample == 4) {
            int32_t sample_32 = *(int32_t *)data;
            sample = sample_32 / (double)INT32_MAX;
        } else {
            assert(0);
        }
        data += channels*nbytepersample;
        nbytes -= channels*nbytepersample;
        _mlm_feedsample(mlm, sample, 1);
    }
    assert(nbytes == 0);
    _MLM_LOCK_LEAVE;
}

void mlm_feedmodulation(struct mlm *mlm, double duration)
{
    _MLM_LOCK_ENTER;
    _mlm_feedsample(mlm, duration, (long)duration);
    _MLM_LOCK_LEAVE;
}

double mlm_amplitude(struct mlm *mlm)
{
    _MLM_LOCK_ENTER;
    // Compute average and amplitude
    double amplitude = mlm->mlm_sumabsdeltas / mlm->mlm_nsamples;
    if (amplitude > -0.00001 && amplitude < 0.00001) amplitude = 0;
    assert(amplitude >= 0);
    _MLM_LOCK_LEAVE;
    return amplitude;
}

int mlm_ready(struct mlm *mlm)
{
    _MLM_LOCK_ENTER;
    int rv = mlm->mlm_minstretch > 0 && mlm->mlm_maxstretch > 0 && mlm->mlm_nstretch > 0;
    _MLM_LOCK_LEAVE;
    return rv;
}

double mlm_min(struct mlm *mlm)
{
    _MLM_LOCK_ENTER;
    double rv = mlm->mlm_minstretch;
    _MLM_LOCK_LEAVE;
    return rv;
}

double mlm_max(struct mlm *mlm)
{
    _MLM_LOCK_ENTER;
    double rv = mlm->mlm_maxstretch;
    _MLM_LOCK_LEAVE;
    return rv;
}

double mlm_average(struct mlm *mlm)
{
    double rv = 0;
    _MLM_LOCK_ENTER;
    if (mlm->mlm_nstretch > 0) {
        rv = (double)mlm->mlm_allstretch / mlm->mlm_nstretch;
    }
    _MLM_LOCK_LEAVE;
    return rv;
}

double mlm_current(struct mlm *mlm)
{
    double rv = 0;
    _MLM_LOCK_ENTER;
    if (mlm->mlm_nstretch > 0) {
        rv = mlm->mlm_laststretch;
    }
    _MLM_LOCK_LEAVE;
    return rv;
}

double mlm_consume(struct mlm *mlm) {
    double rv = -1;
    _MLM_LOCK_ENTER;
    if (mlm->mlm_stretches && mlm->mlm_stretches_in > mlm->mlm_stretches_out) {
        // Consume value from the out pointer
        assert(mlm->mlm_stretches_out >= 0);
        assert(mlm->mlm_stretches_out < mlm->mlm_stretches_size);
        rv = mlm->mlm_stretches[mlm->mlm_stretches_out++];
        // If the out pointer has caught up with the in pointer reset both
        if (mlm->mlm_stretches_out >= mlm->mlm_stretches_in) {
            mlm->mlm_stretches_out = 0;
            mlm->mlm_stretches_in = 0;
        }
    }
    _MLM_LOCK_LEAVE;
    return rv;
}
