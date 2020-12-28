;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

;----------------------------------------------------------------------
; This function returns a precipitation color palette
;----------------------------------------------------------------------
function precip_pal()
local cmap, ncolors
begin
  cmap = (/ (/242, 242, 242/), (/154, 192, 205/), (/178, 223, 238/), \
            (/191, 239, 255/), (/  0, 235, 235/), (/  0, 163, 247/), \
            (/  0, 255,   0/), (/  0, 199,   0/), (/  0, 143,   0/), \
            (/  0,  63,   0/), (/255, 255,   0/), (/255, 143,   0/), \
            (/255,   0,   0/), (/215,   0,   0/), (/191,   0,   0/), \
            (/255,   0, 255/), (/155,  87, 203/), (/ 92,  52, 176/) /)

;---Create RGBA array from RGB array so we can set a couple colors to transparent 
   ncolors          = dimsizes(cmap(:,0))
   cmap_rgba        = new((/ncolors,4/),float)
   cmap_rgba(:,0:2) = cmap/255.
   cmap_rgba(:,3)   = 1.0     ; set all colors to fully opaque
   cmap_rgba(0:1,3) = 0.0     ; set first two colors to fully transparent
   return(cmap_rgba)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;
; Make a list of all files we are interested in
  DATADir = "/data1/storage/subeen/case2011/wrfout/"
  FILES = systemfunc (" ls -1 " + DATADir + "wrfout_d02* ")
  numFILES = dimsizes(FILES)
  print("numFILES = " + numFILES)
  print(FILES)
  print (" ")

dir = "/data1/storage/subeen/case2011/domain/"
 filename1 = "geo_em.d02.nc"
 f1        = addfile(dir+filename1,"r")

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

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  wks = gsn_open_wks(type,"PcpColored")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"

  pltres = True
  mpres = True
  mpres@mpProjection           = "LambertConformal"
  mpres@mpLambertParallel1F    = f1@TRUELAT1
  mpres@mpLambertParallel2F    = f1@TRUELAT2
  mpres@mpLambertMeridianF     = f1@CEN_LON
  mpres@mpLimitMode            = "Corners"   ; Select map limit mode
  mpres@mpLeftCornerLatF       = lat2d1(0,0)  ; limit mode point 1
  mpres@mpLeftCornerLonF       = lon2d1(0,0)  ; limit mode point 2
  mpres@mpRightCornerLatF      = lat2d1(nlat1-1,mlon1-1) ; limit mode point 3
  mpres@mpRightCornerLonF      = lon2d1(nlat1-1,mlon1-1) ; limit mode point 4
  mpres@mpGridAndLimbOn       = True          ; default is every 15 deg
  mpres@mpGridSpacingF        = 5.0          ; change to match labels
  mpres@mpGridLineColor       = "black"
;  mpres@mpGridLineThicknessF  = 2.0
  mpres@mpGridLineDashPattern = 2
  mpres@mpGridMaskMode        = "MaskLand"

  mpres@mpOutlineDrawOrder    = "PostDraw"  ; draw continental outline last
  mpres@mpFillDrawOrder       = "PreDraw"
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
  mpres@mpFillOn              = False       ; turn off map fill
  mpres@mpDataResolution      = "FinestResolution"
  mpres@mpDataBaseVersion     = "Ncarg4_1"  ; map database version : Medium level
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGeophysicalLineThicknessF = 1.5
  mpres@mpNationalLineColor         = "Black"
  mpres@mpNationalLineThicknessF = 1.5
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
 
 
;---Set resources for terrain plot
  res_ter                       = True             ; plot mods desired

  res_ter@gsnFrame              = False
  res_ter@gsnDraw               = False

  res_ter@gsnSpreadColors          = False
  res_ter@cnSpanFillPalette        = True
  res_ter@cnFillOn              = True             ; color plot desired
  res_ter@cnFillPalette         = "gsltod"         ; Select grayscale colormap
  res_ter@cnLinesOn             = False            ; turn off contour lines
  res_ter@cnLineLabelsOn        = False            ; turn off contour labels
  res_ter@cnFillMode            = "RasterFill"
  res_ter@cnFillOpacityF        = 1.
  res_ter@lbLabelBarOn          = False
  ;res_ter@gsnRightString        =  ""

  res_ter@tfDoNDCOverlay        = True

;  res_ter@pmTickMarkDisplayMode = "Always"         ; turn on nicer tickmarks
  res_ter@tmXBLabelFontHeightF  = 0.018
  res_ter@tmYLLabelFontHeightF  = 0.018
  res_ter@tmYLLabelStride       = 2                ; label every other tickmark
  res_ter@tmXBLabelStride       = 2

;---Point the tickmarks inward
  res_ter@tmYRMajorOutwardLengthF = 0
  res_ter@tmYLMajorOutwardLengthF = 0
  res_ter@tmXBMajorOutwardLengthF = 0
  res_ter@tmXBMinorOutwardLengthF = 0
  res_ter@tmXTOn                  = False
  res_ter@tmYROn                  = False
  res_ter@tmYRLabelsOn            = False
  res_ter@tmXTLabelsOn            = False


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  a = addfiles(FILES+".nc","r")

  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file


  ; Get non-convective, convective and total precipitation
  rain_exp = wrf_user_getvar(a,"RAINNC",-1)
  rain_con = wrf_user_getvar(a,"RAINC",-1)
  rain_tot = rain_exp + rain_con
  rain_tot@description = "Total Precipitation"
  HGT = wrf_user_getvar(a, "HGT", -1)
  

  ; just creating new arrays here
  rain_exp_tend = rain_exp 
  rain_con_tend = rain_con 
  rain_tot_tend = rain_tot 
  rain_exp_tend = 0.0 
  rain_con_tend = 0.0 
  rain_tot_tend = 0.0 
  rain_exp_tend@description = "Explicit Precipitation Tendency"
  rain_con_tend@description = "Param  Precipitation Tendency"
  rain_tot_tend@description = "Precipitation Tendency"

  ; Calculate tendency values 
  ; We know our data is available every 3 hours, so setting tend_int to 1 gives 
  ; tendencies for 3 hours, setting it to 2, gives 6hourly tendencies                               
  tend_int = 6
  rain_exp_tend(tend_int:ntimes-1:tend_int,:,:) = rain_exp(tend_int:ntimes-1:tend_int,:,:) - rain_exp(0:ntimes-2:tend_int,:,:)
  rain_con_tend(tend_int:ntimes-1:tend_int,:,:) = rain_con(tend_int:ntimes-1:tend_int,:,:) - rain_con(0:ntimes-2:tend_int,:,:)
  rain_tot_tend(tend_int:ntimes-1:tend_int,:,:) = rain_tot(tend_int:ntimes-1:tend_int,:,:) - rain_tot(0:ntimes-2:tend_int,:,:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = tend_int,ntimes-1,tend_int    ; Let's skip the first time as rain is 0 here

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots


  ; Plotting options for Precipitation

  precip_levels = (/ .01, 0.25, 0.50, 0.75, \
                    1.00, 1.25, 1.50, 2.0, \
                    3.0, 6.0, 12.0, 25.0, \
                    50.0, 60.0, 70.0, 80.0, \
                    90.00, 100.00, 110.00, 120.00, \
                    130.00 /)


    opts_r = res                        
    opts_r@UnitLabel            = "mm"
    opts_r@cnLevelSelectionMode = "ExplicitLevels"
    opts_r@cnLevels             = precip_levels
    opts_r@cnFillPalette        = precip_pal()
    opts_r@gsnSpreadColors          = False
    opts_r@cnSpanFillPalette        = True
    opts_r@cnSmoothingOn        = True
    opts_r@cnSmoothingDistanceF = .005
    opts_r@cnInfoLabelOn        = False
    opts_r@cnConstFLabelOn      = False
    opts_r@cnFillOn             = True
    opts_r@cnFillMode           = "RasterFill"
    opts_r@cnLinesOn            = False            ; turn off contour lines
    opts_r@cnLineLabelsOn       = False            ; turn off contour labels
    opts_r@cnFillOpacityF       = 1.               ; .85 
    opts_r@tmXTOn                  = False
    opts_r@tmYROn                  = False
    opts_r@tmYRLabelsOn            = False
    opts_r@tmXTLabelsOn            = False
    ; opts_r@lbOrientation            = "Vertical"
    ;opts_r@pmLabelBarSide           = "Right"
;    opts_r@pmLabelBarHeightF        = 0.8
;    opts_r@pmLabelBarWidthF         = 0.35
;    opts_r@pmLabelBarOrthogonalPosF = 0.03
;    opts_r@lbBoxMinorExtentF        = 0.4
    opts_r@lbTitleString            = "Total Precipitation"
;    opts_r@lbTitleDirection         = "Down"
;    opts_r@lbTitleJust              = "CenterRight"
    opts_r@lbTitlePosition          = "Bottom"
;    opts_r@lbTitleOffsetF           = 0.07


    

  ; Total Precipitation (color fill)
    contour_ter = wrf_contour(a[it], wks,HGT(it,:,:), res_ter)
    contour_tot = wrf_contour(a[it], wks,rain_tot(it,:,:), opts_r)

  ; MAKE PLOTS                                       
      
      plot = wrf_map_overlays(a[it],wks,(/contour_ter, contour_tot/),pltres, mpres)

    ;plot_terrain = gsn_csm_contour_map(wks,HGT,res_ter)
    ;overlay(plot_terrain, contour_tot)
    ;draw(plot_terrain)
    ;frame(wks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end