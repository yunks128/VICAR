#ifndef M2020ENGCAMPDS_H_
#define M2020ENGCAMPDS_H_

#include "M2020MainInclude.h"
#include "M2020DpMetaData.h"
#include "M2020EngImgPdsLabel.h"

class M2020Edr;
class M2020DpMetaData;

class M2020EngCamPds:public M2020EngImgPdsLabel {

      protected:
   M2020DpMetaData * _dpMeta;
   M2020Edr *_edr;
   M2020Env *_env;

   u_char *_fileName;
   u_int _apid;
   u_short *_partNumber;
   u_int _totalParts;
   u_int _pktNumber;
   int _subType;
   u_int _seqId;
   u_int _seqVer;
   u_int _scftId;
   char *_minErt, *_maxErt;
   int _isSpice;
   int _isOldDp;

      public:
   ~M2020EngCamPds();
    M2020EngCamPds(M2020DpMetaData *, M2020ImgEdr *, char *);

   int write(int);
   int set(M2020Edr *);
   const char *getProductName();

};

#endif
