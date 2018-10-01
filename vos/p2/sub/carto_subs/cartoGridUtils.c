#include <math.h>

#include "zmabend.h"
#include "cartoGridUtils.h"
#include "cartoMemUtils.h"

double gridtol;

/*  subroutine cartogetline:
finds the longest row or column of a grid as predicted by successive
neighbors; returns the length of the row -1 (number of areas); returns
0 for any failures, though there are none since you can always have a
row of two points.  the null9 case is for grids that have (-999,-999)
in them as don't cares */

void cartogetline(double *x,double*y,
	     int istart, int inc, int nmax, int bign, int* nfound, int* null9)
{
   int i,ix;
   double x1,y1,x2,y2,x3,y3,xp,yp,d1,d2,dbar;
   
   *nfound = 1;
   *null9 = 0;
   dbar = 0.0;
   x2 = x[istart];
   y2 = y[istart];
   x3 = x[istart+inc];
   y3 = y[istart+inc];
   if (x2<-998.99&&y2<-998.99&&x2>-999.01&&y2>-999.01) { *null9 = 1; return; }
   if (x3<-998.99&&y3<-998.99&&x3>-999.01&&y3>-999.01) { *null9 = 1; return; }
   for (i=0;i<nmax-1;i++)
      {
      x1 = x2; y1 = y2; x2 = x3; y2 = y3;
      ix = istart+(i+2)*inc;
      if (ix>=bign) break;
      x3 = x[ix];
      y3 = y[ix];
      if (x3<-998.99&&y3<-998.99&&x3>-999.01&&y3>-999.01) { *null9 = 1; return; }
      xp = 2*x2-x1;
      yp = 2*y2-y1;
      d1 = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
      d2 = sqrt((xp-x3)*(xp-x3)+(yp-y3)*(yp-y3));
      dbar = (dbar*(double)i+d1)/(double)(i+1);
      if (d2>gridtol*dbar) break;
      (*nfound)++;
      }
   return;
}

/*  subroutine getline2:
the case is for grids that have (-999,-999).  this routine tries to find
the first or last grid row that might end with -999 but finds the first
non-999 on the second row */

void getline2(double *x,double *y, int istart, int inc, int nmax, int bign, int *nfound)
{
   int i,ix,stage;
   double x1,y1,x2,y2;
   
   x2 = x[istart];
   y2 = y[istart];
   if (x2<-998.99&&y2<-998.99&&x2>-999.01&&y2>-999.01) 
      {
      *nfound = 0;
      return;
      }
   *nfound = 1;
   stage = 0;
   for (i=0;i<nmax;i++)
      {
      x1 = x2; y1 = y2;
      ix = istart+(i+1)*inc;
      if (ix>=bign) break;
      x2 = x[ix];
      y2 = y[ix];
      if (x2<-998.99&&y2<-998.99&&x2>-999.01&&y2>-999.01) stage = 1;
         else if (stage==1) { (*nfound)--; return;}
      (*nfound)++;
      }
   *nfound = 0;
   return;
}

/*  subroutine getline3:
the case is for grids that have (-999,-999).  this routine tries to find
the first or last grid row that might end with -999 but finds the first
non-999 on the second row */

void getline3(double *x,double *y, int istart, int inc, int nmax, int bign, int *nfound)
{
   int i,ix,stage;
   double x1,y1,x2,y2;
   
   x2 = x[istart];
   y2 = y[istart];
   if (x2>-998.99||y2>-998.99||x2<-999.01||y2<-999.01) 
      {
      *nfound = 0;
      return;
      }
   *nfound = 1;
   stage = 0;
   for (i=0;i<nmax;i++)
      {
      x1 = x2; y1 = y2;
      ix = istart+(i+1)*inc;
      if (ix>=bign) break;
      x2 = x[ix];
      y2 = y[ix];
      if (x2>-998.99||y2>-998.99||x2<-999.01||y2<-999.01) stage = 1;
         else if (stage==1) { (*nfound)--; return;}
      (*nfound)++;
      }
   *nfound = 0;
   return;
}

/*  subroutine gridfill:
this routine assumes that the grid dimensions have been found and it is desired to
replace the (-999,-999) values with unique grid values avoiding inside-out triangles
the call is for a single line in one direction.  This routine is probably not needed
but is better in case of a plot.  You cannot be inside an inside-out triangle */

void gridfill(double *x,double *y, int istart, int inc, int nmax)
{
   int i;
   double x1,y1,x2,y2,x3,y3;
   
   x2 = x[istart];
   y2 = y[istart];
   x3 = x[istart+inc];
   y3 = y[istart+inc];
   for (i=0;i<nmax-1;i++)
      {
      x1 = x2; y1 = y2; x2 = x3; y2 = y3;
      x3 = x[istart+(i+2)*inc];
      y3 = y[istart+(i+2)*inc];
      if (x3<-998.99&&y3<-998.99&&x3>-999.01&&y3>-999.01&&
         (x2>-998.99||y2>-998.99||x2<-999.01||y2<-999.01)&&
         (x1>-998.99||y1>-998.99||x1<-999.01||y1<-999.01))
         {
         x3 = 2*x2-x1;
         y3 = 2*y2-y1;
         x[istart+(i+2)*inc] = x3;
         y[istart+(i+2)*inc] = y3;
         }
      }
   return;
}

/*  subroutine tgrid:
triangulates a grid, and the four extrapolated points in the last four
positions as generated by polygeov main */

void tgrid(int npoints,
	   int* nlinret,
	   double* ptx,
	   double* pty,
	   int* ntriang,
	   int** tcon1,
	   int** tcon2,
	   int** tcon3,
	   int gridnah,
	   double* csol,
	   double* optx,
	   double* opty,
	   int zgeom)
{
   int i,j,nah,nav,nahp,navp,ptr,n,opoint;
   double ctrx,ctry,x,y,fac;
   
   n = npoints-4;
   nah = gridnah;
   nahp = nah+1;
   navp = n/nahp;
   nav = navp-1;
   if (nahp*navp!=n) zmabend("grid has wrong number of points");
   *ntriang = nah*nav*2+(nah+nav)*2+4;
   *nlinret = (*ntriang*3)/2+2;
           
   mz_alloc1((unsigned char **)tcon1,*ntriang,4);
   mz_alloc1((unsigned char **)tcon2,*ntriang,4);
   mz_alloc1((unsigned char **)tcon3,*ntriang,4);
   
   /* 4 far points may be unsuitable, substitute these */
  
   ctrx = (ptx[0]+ptx[nah]+ptx[n-nah-1]+ptx[n-1])*0.25; 
   ctry = (pty[0]+pty[nah]+pty[n-nah-1]+pty[n-1])*0.25; 
   ptx[n] = ctrx+(ptx[0]+ptx[nah])*10.0;
   pty[n] = ctry+(pty[0]+pty[nah])*10.0;
   ptx[n+3] = ctrx-(ptx[0]+ptx[nah])*10.0;
   pty[n+3] = ctry-(pty[0]+pty[nah])*10.0;
   ptx[n+1] = ctrx+(ptx[nah]+ptx[n-1])*10.0;
   pty[n+1] = ctry+(pty[nah]+pty[n-1])*10.0;
   ptx[n+2] = ctrx-(ptx[nah]+ptx[n-1])*10.0;
   pty[n+2] = ctry-(pty[nah]+pty[n-1])*10.0;

   /* resolve the corner points */

   fac = 0.5;         /* 0 for linear, 1.0 for cubic, 0.5 for 1/2 each */
   for (i=0;i<4;i++)
      {
      x = ptx[n+i]; y = pty[n+i];
      optx[n+i] = csol[0]*x+csol[1]*y+csol[2]+fac*(csol[3]*x*y+
         csol[4]*x*x+csol[5]*y*y+csol[6]*x*x*x+csol[7]*x*x*y+
         csol[8]*x*y*y+csol[9]*y*y*y);
      if (!zgeom) opty[n+i] = csol[10]*x+csol[11]*y+csol[12]+fac*(csol[13]*x*y+
         csol[14]*x*x+csol[15]*y*y+csol[16]*x*x*x+csol[17]*x*x*y+
         csol[18]*x*y*y+csol[19]*y*y*y);
      }
   
   /* edge triangles to top outside point, note pointers are +1 */
    
   ptr = 0;
   opoint = n+1;
   for (i=0;i<nah;i++)
      {
      (*tcon1)[ptr] = opoint;
      (*tcon3)[ptr] = i+2;
      (*tcon2)[ptr++] = i+1;
      }
   (*tcon1)[ptr] = opoint;
   (*tcon3)[ptr] = opoint+1;
   (*tcon2)[ptr++] = nahp;
   (*tcon1)[ptr] = opoint;
   (*tcon3)[ptr] = 1;
   (*tcon2)[ptr++] = opoint+2;
   
   /* grid triangles, contents of arrays are fortran referenced (+1) */
   
   for (i=0;i<nav;i++)
      {
      for (j=0;j<nah;j++)
         {
         /* upper left triangle */
         (*tcon1)[ptr] = i*nahp+j+1;
         (*tcon3)[ptr] = i*nahp+j+2;
         (*tcon2)[ptr++] = (i+1)*nahp+j+1;
         /* lower right triangle */
         (*tcon1)[ptr] = i*nahp+j+2;
         (*tcon3)[ptr] = (i+1)*nahp+j+2;
         (*tcon2)[ptr++] = (i+1)*nahp+j+1;
         }
      /* triangles to outside side points */
      (*tcon1)[ptr] = (i+1)*nahp;
      (*tcon3)[ptr] = opoint+1;
      (*tcon2)[ptr++] = (i+2)*nahp;
      (*tcon1)[ptr] = i*nahp+1;
      (*tcon3)[ptr] = (i+1)*nahp+1;
      (*tcon2)[ptr++] = opoint+2;
      }
   
   /* edge triangles to bottom outside point */
   
   for (i=0;i<nah;i++)
      {
      (*tcon1)[ptr] = nav*nahp+i+1;
      (*tcon3)[ptr] = nav*nahp+i+2;
      (*tcon2)[ptr++] = opoint+3;
      }
   (*tcon1)[ptr] = opoint+1;
   (*tcon3)[ptr] = opoint+3;
   (*tcon2)[ptr++] = nahp*navp;
   
   (*tcon1)[ptr] = opoint+2;
   (*tcon3)[ptr] = nahp*nav+1;
   (*tcon2)[ptr++] = opoint+3;
   /*printf("triB3 %f %f\n %f %f\n%f %f \n",      useful code
     ptx[(*tcon1)[ptr-1]-1]+3388.0,pty[(*tcon1)[ptr-1]-1]+3722.0,
     ptx[(*tcon2)[ptr-1]-1]+3388.0,pty[(*tcon2)[ptr-1]-1]+3722.0,
     ptx[(*tcon3)[ptr-1]-1]+3388.0,pty[(*tcon3)[ptr-1]-1]+3722.0);*/
   
   return;
}

