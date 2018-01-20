package require vtk
package require vtkinteraction

# --------- Prepare and process the data -----------------------
# Read a vtk file
vtkPolyDataReader plate
    plate SetFileName "plate.vtk"
	#Set the name of the vector data to extract
    plate SetVectorsName "mode1"

vtkWarpVector warp
    warp SetInput [plate GetOutput]
    warp SetScaleFactor 5.0
	
vtkPolyDataNormals normals
    normals SetInput [warp GetOutput]

vtkVectorDot color
    color SetInput [normals GetOutput]

# -------------- Set up the lookup table(s) ------------------------
  
vtkLookupTable lutBR
  lutBR SetHueRange 0.667 0.0
	
	
# --------- Mapper and Acotor of the beam plate ----------------
vtkDataSetMapper plateMapper
    plateMapper SetInput [color GetOutput]
	
	plateMapper SetLookupTable lutBR
	
vtkActor plateActor
	plateActor SetMapper plateMapper
	[plateActor GetProperty] SetOpacity 0.4
	
#
# ---------- Create a scalar bar actor --------------------------
vtkScalarBarActor scalarBar
	scalarBar SetLookupTable [plateMapper GetLookupTable]
	scalarBar SetTitle "Strain"
	[scalarBar GetPositionCoordinate] SetCoordinateSystemToNormalizedViewport
	[scalarBar GetPositionCoordinate] SetValue 0.1 0.01
	scalarBar SetOrientationToHorizontal
	scalarBar SetWidth 0.8
	scalarBar SetHeight 0.17
	
	
# ----------- create the outline actor ---------------------------
vtkOutlineFilter outline
    outline SetInput [plate GetOutput]
vtkPolyDataMapper outlineMapper
    outlineMapper SetInput [outline GetOutput]
vtkActor outlineActor
    outlineActor SetMapper outlineMapper
	[outlineActor GetProperty] SetColor 1 1 1


# ------------ Create the vector actor ---------------------------
vtkThresholdPoints threshold
    threshold SetInput [color GetOutput]
	threshold ThresholdByUpper 0
vtkMaskPoints mask
    mask SetInput [threshold GetOutput]
	mask SetOnRatio 20
vtkConeSource cone
    cone SetResolution 3
	cone SetHeight 2
	cone SetRadius 0.25
vtkGlyph3D cones
    cones SetInput [mask GetOutput]
	cones SetSource [cone GetOutput]
	cones SetScaleFactor 1
	cones SetScaleModeToScaleByVector
vtkLookupTable lutVec
    lutVec SetHueRange 0.667 0.0
	lutBR Build
vtkPolyDataMapper vecMapper
    vecMapper SetInput [cones GetOutput]
	vecMapper SetScalarRange 1 12
	vecMapper SetLookupTable lutVec
vtkActor vecActor
    vecActor SetMapper vecMapper
	

# ------------- Transform actors to right postions -----------------
vtkTransform trans
	trans RotateX 60
	trans RotateZ 190
	trans RotateY 10

	plateActor SetUserTransform trans 
	outlineActor SetUserTransform trans 
	vecActor SetUserTransform trans


# -------- Set Renderer, RenderWindow, and WindowInteractor ---------
vtkRenderer ren1
	ren1 SetBackground 0.2 0.3 0.4
	ren1 AddActor plateActor
	ren1 AddActor outlineActor
	ren1 AddActor scalarBar
	ren1 AddActor vecActor

vtkRenderWindow renWin
	renWin SetSize 900 600
    renWin AddRenderer ren1

vtkInteractorStyleTrackballCamera style

vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin
	iren SetInteractorStyle style
	iren AddObserver UserEvent {wm deiconify .vtkInteract}
	
	iren Initialize

# prevent the tk window from showing up then start the event loop
wm withdraw .

# render the image
renWin Render
after 1000


# ----------- Animate the vibration --------------------------
# Using vector data "mode1"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000

# Using vector data "mode2"
plate SetVectorsName "mode2"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000

# Using vector data "mode3"
plate SetVectorsName "mode3"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000

# Using vector data "mode4"
plate SetVectorsName "mode4"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000

# Using vector data "mode5"
plate SetVectorsName "mode5"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000
