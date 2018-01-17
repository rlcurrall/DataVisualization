# Starting code
# CSCI B466

# Step 11 (Why the "displacement plot" method is better the method implmented
#                    in "vtkElevationFilter" for this application?)
# Using the vtkElevationFilter uses the elevation of the points from an origin
# where anything below the origin will have the same color as the origin and
# anything above the highest difined point will have that same color. The 
# displacement plot scheme uses displacement from the origin to define the color
# so a point at 0.5 will have the same color as a point at -0.5. Since the bar
# is swinging in both directions in the simulation it makes more sense to use 
# displacement rather than elevation so that the stress upwards will be the same
# as the stress downwards.
#

package require vtk
package require vtkinteraction

# --------- Prepare and process the data -----------------------
# Read a vtk file
#   The output of this reader is a single vtkPolyData data object
#   and it can be accessed by [plate GetOutput]
vtkPolyDataReader plate
    plate SetFileName "plate.vtk"
	#Set the name of the vector data to extract
	#  The vector data can be found in the data file
	#  There are 5 sets of vector data, i.e., mode1, mode2, mode3,
	#     mode4, and mode5
	#  Here we use the vector data named as "mode1"
    plate SetVectorsName "mode1"

#vtkWarpVector is a filter that modifies point coordinates by moving
#  points along vector times the scale factor. Useful for showing flow
#  profiles or mechanical deformation.
vtkWarpVector warp
    warp SetInput [plate GetOutput]
	# A positive factor (0.9) means the motion is in the direction of
	#   the surface normal (i.e., positive displacement)
    warp SetScaleFactor 5.0
	# A negtive factor (-0.9) means the motion is in the opposite
	#   direction of the surface normal (i.e., negative displacement)
	#warp SetScaleFactor -0.9
	
#vtkPolyDataNormals is a filter that computes point normals for a
#  polygonal mesh
vtkPolyDataNormals normals
    normals SetInput [warp GetOutput]

#vtkVectorDot is a filter to generate scalar values from a dataset
#  The scalar value at a point is created by computing the dot product
#  between the normal and vector at that point 
#  i.e. the "displacement plots" algorithm introduced in Lecture10
vtkVectorDot color
    color SetInput [normals GetOutput]


# -------- generate scalar values using Elevation algorithm ------------
#Step 2: Generate the color scalar value for each point from 
#        its vector using “vtkElevationFilter” which is
#        covered in Lecture08 and used in "hawaii.tcl"
#Step 3: Comment out the statements created in step 2 (but keep the code
#        for grading purpose) so the code would be the same as that
#        before step 2.
if 0 {
vtkElevationFilter colorIt
  colorIt SetInput [warp GetOutput]
  colorIt SetLowPoint 0 0 0
  colorIt SetHighPoint 0 0 0
  colorIt SetScalarRange 0.2 1.0
}


# -------------- Set up the lookup table(s) ------------------------
#Step 4: Create one black white color lookup table with 256 colors 
#        and add it into the pipeline
#        Lookup table is covered in Lecture08

vtkLookupTable lut
  lut SetNumberOfColors 256

  lut Build
  for {set i 0} {$i<256} {incr i} {
	  lut SetTableValue $i [expr $i/256.0] [expr $i/256.0] [expr $i/256.0] 1 
  }
  
#Step 5: Comment out the single statement for adding the black 
#        white color table to the pipeline. Create another color
#        table which is not black and white 
vtkLookupTable lutBR
  lutBR SetHueRange 0.667 0.0
	
	
# --------- Mapper and Acotor of the beam plate ----------------
vtkDataSetMapper plateMapper
# Map the tright dataset
    plateMapper SetInput [color GetOutput]
	
#Step 4 and step 5: Add the required lookup table to the pipeline
	plateMapper SetLookupTable lutBR
	
vtkActor plateActor
	plateActor SetMapper plateMapper
#Step 10: Set the opacity “plateActor” as 0.4 or 0.5 so we 
#         can see through the beam and glyphs can be shown easily
	[plateActor GetProperty] SetOpacity 0.4
	## This line of code somehow changes the colors of the scalar bar
	
#
# ---------- Create a scalar bar actor --------------------------
#Step 8: Add a scalar bar based on your color lookup table
#        (Refer to “scalarBar.tcl” and VTK online documentation)
#        The scalar bar’s title should be “Strain”.
#        The sclar bar's value changes from 0.0 (blue) to 1.0 (red).
vtkScalarBarActor scalarBar
	scalarBar SetLookupTable [plateMapper GetLookupTable]
	scalarBar SetTitle "Strain"
	[scalarBar GetPositionCoordinate] SetCoordinateSystemToNormalizedViewport
	[scalarBar GetPositionCoordinate] SetValue 0.1 0.01
	scalarBar SetOrientationToHorizontal
	scalarBar SetWidth 0.8
	scalarBar SetHeight 0.17
	
	
# ----------- create the outline actor ---------------------------
#Step 1: create an outline for the beam plate
#        (Refer to "VisQuad.tcl" in Lecture06)
vtkOutlineFilter outline
    outline SetInput [plate GetOutput]
vtkPolyDataMapper outlineMapper
    outlineMapper SetInput [outline GetOutput]
vtkActor outlineActor
    outlineActor SetMapper outlineMapper
	[outlineActor GetProperty] SetColor 1 1 1


# ------------ Create the vector actor ---------------------------
#Step 9: Using vtkMaskPoints, vtkConeSource, and vtkGlyph3D to create
#        a visualization consisting of oriented glyphs representing
#        the given vector field. The number of glyphs must be less
#        than the number of vertices of the beam plate because we 
#        don’t want to clutter the display 
#        (refer to “thrshldV.tcl” in Lecture10’s sample code).
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
# #Step 1: Transform the beam and the outline actors to a similar position and angle as the following figure so the vibration can be seen clearly
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
	# ################################
	# ***** Your code here **********
	# ################################


# ---------- Ajust the active camera if necessary --------------
	# ################################
	# ***** Your code here **********
	# ################################
	
# set thedisplay window
vtkRenderWindow renWin
	renWin SetSize 900 600
    renWin AddRenderer ren1

# Set the interactor style
vtkInteractorStyleTrackballCamera style

# Set the window interactor
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin
	iren SetInteractorStyle style
	iren AddObserver UserEvent {wm deiconify .vtkInteract}
	# Prepare for handling events. This must be called
	#   before the interactor will work.
	iren Initialize

# prevent the tk window from showing up then start the event loop
wm withdraw .

# render the image
renWin Render
after 1000


# ----------- Animate the vibration --------------------------
#Step 6: Animate the vibration in both positive and negative 
#        directions by changing the scale factor of “vtkWarpVector”
#        in [0.0, 3.0] (Call function “SetScaleFactor”)
#*********************************************************
# Using vector data "mode1"
for {set i 0} {$i<=30} {incr i} {
	warp SetScaleFactor [expr ($i/10.0)*pow(-1,$i)]
	renWin Render
	after 400
}
after 1000


#Step 7: Repeat step 6 for vector sets “mode2”, “mode3”, “mode4”, and “mode5” separately
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
