//
//  mlmlib.c
//  miclightmeter
//
//  Created by Jack Jansen on 31/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#include "mlmlib.h"
#include <stdlib.h>

struct mlm*
mlm_new()
{
    struct mlm *mlm = malloc(sizeof(struct mlm));
    if (mlm) {
        mlm->mlm_samplerate = 0;
        mlm_reset(mlm);
    }
    return mlm;
}

void
mlm_destroy(struct mlm *mlm)
{
    free(mlm);
}

void mlm_samplerate(struct mlm *mlm, long samplerate)
{
    if (samplerate != mlm->mlm_samplerate) {
        mlm_reset(mlm);
        mlm->mlm_samplerate = samplerate;
    }
}

void mlm_threshold(struct mlm *mlm, int threshold)
{
    if (mlm->mlm_threshold != mlm->mlm_threshold) {
        mlm_reset(mlm);
        mlm->mlm_threshold = threshold;
    }
}

void mlm_reset(struct mlm *mlm)
{
    mlm->mlm_curpolarity = 0;
    mlm->mlm_threshold = 1000;
    mlm->mlm_last_to_positive = 0;
    mlm->mlm_initializing = 1;
    mlm->mlm_minstretch = -1;
    mlm->mlm_maxstretch = -1;
    mlm->mlm_allstretch = 0;
    mlm->mlm_nstretch = 0;
}

int mlm_amplitude(struct mlm *mlm, short *data, int len, int channels)
{
    int max = 0;
    int min = 0;
    while((len-=channels)) {
        short sample = *data;
        data += channels;
        if (sample < min) min = sample;
        if (sample > max) max = sample;
    }
    return (max-min)/2;
}

void mlm_feed(struct mlm *mlm, short *data, int len, int channels)
{
    while((len-=channels)) {
        short sample = *data;
        data += channels;
        int curpolarity = (sample < -mlm->mlm_threshold ? -1 :
                           (sample > mlm->mlm_threshold ? 1 : 0));
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
}

int mlm_ready(struct mlm *mlm)
{
    return mlm->mlm_minstretch > 0 && mlm->mlm_maxstretch > 0 && mlm->mlm_nstretch > 0;
}

double mlm_min(struct mlm *mlm)
{
    double rv = mlm->mlm_maxstretch;
    if (mlm->mlm_samplerate) {
        rv = mlm->mlm_samplerate / rv;
    }
    return rv;
}

double mlm_max(struct mlm *mlm)
{
    double rv = mlm->mlm_minstretch;
    if (mlm->mlm_samplerate) {
        rv = mlm->mlm_samplerate / rv;
    }
    return rv;
}

double mlm_average(struct mlm *mlm)
{
    if (mlm->mlm_nstretch <= 0) return 0;
    double rv = (double)mlm->mlm_allstretch / mlm->mlm_nstretch;
    if (mlm->mlm_samplerate) {
        rv = mlm->mlm_samplerate / rv;
    }
    return rv;
}

double mlm_current(struct mlm *mlm)
{
    if (mlm->mlm_nstretch <= 0) return 0;
    double rv = mlm->mlm_laststretch;
    if (mlm->mlm_samplerate) {
        rv = mlm->mlm_samplerate / rv;
    }
    return rv;
}

