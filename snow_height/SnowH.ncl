;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"


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
  wks = gsn_open_wks(type,"SnowColored")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"

  pltres = True


 
 
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
  snowh = wrf_user_getvar(a, "SNOWH", -1)
  HGT = wrf_user_getvar(a, "HGT", -1)
  slp = wrf_user_getvar(a,"slp",-1)  ; slp
    wrf_smooth_2d( slp, 4 )            ; smooth slp

  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = tend_int,ntimes-1,tend_int    ; Let's skip the first time as rain is 0 here

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots


  ; Plotting options for Precipitation
    levels = (/0.1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2/)


    cmap = read_colormap_file("precip3_16lev")
    opts_r = res                        
    opts_r@UnitLabel            = "mm"
    opts_r@cnLevelSelectionMode           = "ExplicitLevels"        ; set manual contour levels
    opts_r@cnLevels                       = levels
    opts_r@cnFillPalette        = cmap(:13,:)
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
    opts_r@lbTitleString            = "Snow Height[m]"
;    opts_r@lbTitleDirection         = "Down"
;    opts_r@lbTitleJust              = "CenterRight"
    opts_r@lbTitlePosition          = "Bottom"
;    opts_r@lbTitleOffsetF           = 0.07

  
  mpres = True
  mpres = wrf_map_resources(f1,mpres)
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
;  mpres@mpGridSpacingF        = 5.0          ; change to match labels
  mpres@mpGridLineColor       = "black"
;  mpres@mpGridLineThicknessF  = 2.0
  mpres@mpGridLineDashPattern = 2
  mpres@mpGridMaskMode        = "MaskLand"

  mpres@mpOutlineDrawOrder    = "PostDraw"  ; draw continental outline last
  mpres@mpFillDrawOrder       = "PreDraw"
  res@mpOutlineBoundarySets = "AllBoundaries" ; state boundaries
  mpres@mpFillOn              = False       ; turn off map fill
  mpres@mpDataResolution      = "FinestResolution"
  mpres@mpDataBaseVersion     = "Ncarg4_1"  ; map database version : Medium level
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGeophysicalLineThicknessF = 0.7
  mpres@mpNationalLineColor         = "Black"
  mpres@mpNationalLineThicknessF = 0.7
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"

  ; Plotting options for Sea Level Pressure
    opts_psl = res          
    opts_psl@ContourParameters = (/ 900., 1100., 4. /)
    opts_psl@cnLineColor       = "NavyBlue"
    opts_psl@cnInfoLabelOn     = False
    opts_psl@cnLineLabelFontHeightF = 0.01
    opts_psl@cnLineLabelPerimOn = False
    opts_psl@gsnContourLineThicknessesScale = 1.5
    contour_psl = wrf_contour(a[it],wks,slp(it,:,:),opts_psl)
    delete(opts_psl)


    

  ; Total Precipitation (color fill)
    contour_ter = wrf_contour(a[it], wks,HGT(it,:,:), res_ter)
    contour_tot = wrf_contour(a[it], wks,snowh(it,:,:), opts_r)

  ; MAKE PLOTS                                       
      
      plot = wrf_map_overlays(a[it],wks,(/contour_psl, contour_tot/),pltres, mpres)

    ;plot_terrain = gsn_csm_contour_map(wks,HGT,res_ter)
    ;overlay(plot_terrain, contour_tot)
    ;draw(plot_terrain)
    ;frame(wks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end