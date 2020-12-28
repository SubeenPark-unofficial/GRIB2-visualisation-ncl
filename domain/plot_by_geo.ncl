
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

 dir = "./"

 filename1 = "geo_em.d01.nc"
 filename2 = "geo_em.d02.nc"

 f1        = addfile(dir+filename1,"r")
 f2        = addfile(dir+filename2,"r")

;; Open Domain 1 file (190*170)
 lat2d1    = f1->XLAT_M(0,:,:)
 lon2d1    = f1->XLONG_M(0,:,:)
 ter1      = f1->HGT_M(0,:,:)
 dimll1    = dimsizes(lat2d1)
 nlat1     = dimll1(0)
 mlon1     = dimll1(1)
 print (lat2d1(0,0))
 print (lat2d1(nlat1-1,0))
 print (lon2d1(0,0))
 print (lon2d1(0,mlon1-1))

;; Open Domain 2 file (157*157)
 lat2d2    = f2->XLAT_M(0,:,:)
 lon2d2    = f2->XLONG_M(0,:,:)
 ter2      = f2->HGT_M(0,:,:)
 dimll2    = dimsizes(lat2d2)
 nlat2     = dimll2(0)
 mlon2     = dimll2(1)
 print (lat2d2(0,0))
 print (lat2d2(nlat2-1,0))
 print (lon2d2(0,0))
 print (lon2d2(0,mlon2-1))

 print(f1@CEN_LON)
 print(f2@CEN_LON)

;;;;;  open wks plot ;;;;;

 wks = gsn_open_wks("png","trial1")

 plot  = new(1,graphic)  ; plot for map
 dum   = new(4,graphic) ; plot for fine domains
 text  = new(2,graphic)  ; plot for text

  res                       = True
  res@tiMainString    	    = "MODEL DOMAIN"
  res@gsnDraw               = False
  res@gsnFrame              = False
;  res@gsnRightString 	    = ""
  res@gsnLeftString 	    = "Topography"
;  res@gsnAddCyclic          = False       ; regional data: not cyclic
  res@tfDoNDCOverlay        = True        ; set True for native projection


  res@mpProjection           = "LambertConformal"
  res@mpLambertParallel1F    = f1@TRUELAT1
  res@mpLambertParallel2F    = f1@TRUELAT2
  res@mpLambertMeridianF     = f1@CEN_LON
  res@mpLimitMode            = "Corners"   ; Select map limit mode
  res@mpLeftCornerLatF       = lat2d1(0,0)  ; limit mode point 1
  res@mpLeftCornerLonF       = lon2d1(0,0)  ; limit mode point 2
  res@mpRightCornerLatF      = lat2d1(nlat1-1,mlon1-1) ; limit mode point 3
  res@mpRightCornerLonF      = lon2d1(nlat1-1,mlon1-1) ; limit mode point 4
  res@mpGridAndLimbOn       = True          ; default is every 15 deg
  res@mpGridSpacingF        = 5.0          ; change to match labels
  res@mpGridLineColor       = "black"
;  res@mpGridLineThicknessF  = 2.0
  res@mpGridLineDashPattern = 2
  res@mpGridMaskMode        = "MaskLand"

  res@mpOutlineDrawOrder    = "PostDraw"  ; draw continental outline last
  res@mpFillDrawOrder       = "PreDraw"
  res@mpOutlineBoundarySets = "AllBoundaries" ; state boundaries
  res@mpFillOn              = False       ; turn off map fill
  res@mpDataResolution      = "FinestResolution"
  res@mpDataBaseVersion     = "Ncarg4_1"  ; map database version : Medium level

  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
  res@tmXTOn                = False            ; turn off top   labels
  res@tmYROn                = False            ; turn off right labels
  res@tmXBLabelFontHeightF  = 0.025
  res@tmYLLabelFontHeightF  = 0.025
  res@cnFillOn              = False
  res@cnLineLabelsOn        = True              ; no contour labels
  res@cnInfoLabelOn         = False              ; no contour info label
  res@cnLineThicknessF      = 0.5
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = (/300,600,900,1200,1500,1800,2100,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000/)   ; m elevation

  plot(0) = gsn_csm_contour_map(wks,ter1,res)


;;; plot for domain locations ;;;
  pres                  = True                ; polyline mods desired
  pres@gsLineThicknessF = 2.0                 ; line thickness
  pres@gsLineColor      = "Black"               ; line color

; plot for Domain 02
  dum(0) = gsn_add_polyline(wks,plot(0), lon2d2(0,:), lat2d2(0,:), pres)             ; lower x
  dum(1) = gsn_add_polyline(wks,plot(0), lon2d2(:,0), lat2d2(:,0), pres)             ; left y
  dum(2) = gsn_add_polyline(wks,plot(0), lon2d2(nlat2-1,:), lat2d2(nlat2-1,:), pres) ; upper x
  dum(3) = gsn_add_polyline(wks,plot(0), lon2d2(:,mlon2-1), lat2d2(:,mlon2-1), pres) ; right y
  
;;; plot for domain texts ;;;
  tres                  = True
  tres@txFontColor      = "Black"
  tres@txFontHeightF    = 0.020
  text(0) = gsn_add_text(wks,plot(0),"D1",lon2d1(nlat1-18,mlon1-20),lat2d1(nlat1-18,mlon1-20),tres)
  text(1) = gsn_add_text(wks,plot(0),"D2",lon2d2(40 , 50),lat2d2(40, 50), tres)
;  text(1) = gsn_add_text(wks, plot(0),"D2", lon2d2(nlat2-40, mlon2-48), lat2d2(nlat2-40, mlon2-48), tres)
  


;***********************************************
; create panel
;***********************************************
  resP                                  = True
  resP@gsnFrame                         = False
;  resP@gsnMaximize                      = True              ; fill the page
  resP@gsnPanelYWhiteSpacePercent       = 5
  resP@gsnPanelXWhiteSpacePercent       = 5
;  resP@gsnPanelTop 			= 0.06
;  resP@gsnPanelBottom                   = 0.06                   ; add space at bottom
  resP@txString                         = ""
  resP@txFontHeightF                    = 0.02
  resP@txFont                           = 22            ;helvetica-bold
;  resP@gsnPanelFigureStrings            = (/"MODEL DOMAIN"/)
;  resP@gsnPanelFigureStringsPerimOn     = False         ; no box
;  resP@gsnPanelFigureStringsBackgroundFillColor = -1
  resP@gsnPanelFigureStringsFontHeightF = 0.016
     
  gsn_panel(wks,plot,(/1,1/),resP)              ; now draw as one plot
  
 frame (wks)

 end
