cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Reduce the spatial resolution of the input image (left or right) by doing
c an n x n pixel summation.
c
      subroutine zoomout(l0,l,nl,ns,zoom)
      implicit none
      integer*4 nl,ns,zoom
      integer*2 l0(nl,ns),l(nl/zoom,ns/zoom)

      integer*4 i0,j0,i,j
      integer*4 ii,jj,dn,isum
      real*8 area

      if (zoom.eq.1) then
         do j=1,nl
            do i=1,ns
               l(i,j) = l0(i,j)
            enddo
         enddo
         return
      endif

      area = zoom**2
      j = 0

      do 50 j0=1,nl,zoom
      j = j + 1
      i = 0
      
      do 50 i0=1,ns,zoom
      i = i + 1
      isum = 0
      l(i,j) = 0

      do jj=0,zoom-1
         do ii=0,zoom-1
            dn = l0(i0+ii,j0+jj)
            if (dn.le.0) goto 50	!invalid pixel
            isum = isum + dn
         enddo
      enddo
      l(i,j) = isum/area
   50 continue

      return
      end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Reduce spatial resolution of horizon location.
c
      subroutine zoomhrzn(hrznl,hrznr,hrznl0,hrznr0,ns,zoom)
      implicit none
      integer*4 ns,zoom
      integer*2 hrznl(ns),hrznr(ns)	!input left and right horizons
      integer*2 hrznl0(ns),hrznr0(ns)	!output horizons

      integer*4 i,i0

      do i=1,ns,zoom
         i0 = (i-1)/zoom + 1
         hrznl0(i0) = (hrznl(i)-1)/zoom + 1
         hrznr0(i0) = (hrznr(i)-1)/zoom + 1
      enddo
      return
      end
