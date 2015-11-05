//
//  mlmlib.h
//  miclightmeter
//
//  Created by Jack Jansen on 31/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#ifndef mlmlib_h
#define mlmlib_h

struct mlm {
    int mlm_curpolarity;
    double mlm_sumsamples;
    double mlm_sumabssamples;
    long mlm_nsamples;
    
    long mlm_last_to_positive;
    int mlm_initializing;
    long mlm_minstretch;
    long mlm_maxstretch;
    long mlm_laststretch;
    long mlm_allstretch;
    long mlm_nstretch;
};

struct mlm* mlm_new();
void mlm_destroy(struct mlm *mlm);
void mlm_reset(struct mlm *mlm);
void mlm_feedfloat(struct mlm *mlm, float *data, int nsamples, int channels);
void mlm_feedint(struct mlm *mlm, void *data, int nbytes, int nbytepersample, int channels);
void mlm_feedone(struct mlm *mlm, float sample);

int mlm_ready(struct mlm *mlm);
double mlm_amplitude(struct mlm *mlm);
double mlm_min(struct mlm *mlm);
double mlm_max(struct mlm *mlm);
double mlm_average(struct mlm *mlm);
double mlm_current(struct mlm *mlm);

#endif /* mlmlib_h */
