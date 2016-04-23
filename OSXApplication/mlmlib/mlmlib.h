//
//  mlmlib.h
//  miclightmeter
//
//  Created by Jack Jansen on 31/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#ifndef mlmlib_h
#define mlmlib_h

#define _MLM_LOCK_DATASTRUCT /* nothing */
#define _MLM_LOCK_ALLOC /* nothing */
#define _MLM_LOCK_ENTER /* nothing */
#define _MLM_LOCK_LEAVE /* nothing */
#define _MLM_LOCK_FREE /* nothing */

struct mlm {
    int mlm_curpolarity;
    double mlm_sumsamples;
    double mlm_sumabsdeltas;
    long mlm_nsamples;
    
    long mlm_last_to_positive;
    long mlm_last_to_negative;
    int mlm_initializing;
    long mlm_minstretch;
    long mlm_maxstretch;
    long mlm_laststretch;
    long mlm_allstretch;
    long mlm_nstretch;
    
    long *mlm_stretches;
    int mlm_stretches_size;
    int mlm_stretches_in;
    int mlm_stretches_out;
    _MLM_LOCK_DATASTRUCT
};

struct mlm* mlm_new();
void mlm_destroy(struct mlm *mlm);
void mlm_reset(struct mlm *mlm);
void mlm_feedfloat(struct mlm *mlm, float *data, int nsamples, int channels);
void mlm_feedint(struct mlm *mlm, void *data, int nbytes, int nbytepersample, int channels);
void mlm_feedmodulation(struct mlm *mlm, double duration);

int mlm_ready(struct mlm *mlm);
double mlm_amplitude(struct mlm *mlm);
double mlm_min(struct mlm *mlm);
double mlm_max(struct mlm *mlm);
double mlm_average(struct mlm *mlm);
double mlm_current(struct mlm *mlm);
double mlm_consume(struct mlm *mlm);

int mlm_generate(short *buffer, int bufferSize, float minLevel, float maxLevel, float sweepFreq, int wantWAVheader);
#endif /* mlmlib_h */
