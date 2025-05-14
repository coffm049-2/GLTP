# Convert initial conditions from Limnotechs EFDC for Lake Ontario
using NetCDF 
using CSV
using DataFrames
using Chain
using TidierData
using GeoStats
using DelimitedFiles

# file = "/work/GLFBREEZ/Lake_Ontario/Initial_Conditions/2013/Initial_Conditions_2013_final.nc"
file = "/work/GLFBREEZ/Lake_Ontario/Initial_Conditions/2018/Initial_Conditions_2018.nc"

x = ncread(file, "X")
y = ncread(file, "Y")
z = ncread(file, "Z")
tp = reshape(ncread(file, "TP"), (256 * 133 *10, 1))[:,1] .* 1000
#tp = reshape(mean(tp, dims = 3)[begin:end,begin:end,1], (256*133, 1))

tpInits = DataFrame(I = repeat(1:256, inner = 133*10), J = repeat(1:133, outer = 256*10), K = repeat(1:2:20, inner = 256, outer= 133) ./ 1000, tp = tp)

efdcMap = @chain DataFrame(readdlm("/work/GLFBREEZ/LOEM/2013_simulation/inputs/latitudes_longitudes.txt", skipstart = 1), :auto) begin
  @rename(I = x1, J = x2, lat = x3, lon = x4)
  @right_join(tpInits)
  @drop_missing(lat,lon)
  # mutliply by 2 to map it to FVCOM
end

EFDCgeotable = georef((tp=efdcMap[:,"tp"], lon=efdcMap[:,"lon"], lat=efdcMap[:,"lat"], sigma=efdcMap[:,"K"]), (:lon, :lat, :sigma))



fvgrid = readdlm("/work/GLHABS/GreatLakesHydro/LakeOntario/input/2018/loofs_for_epa/fvcom_grd.dat",  header=  false, skipstart = 2)
fvgrid = DataFrame(fvgrid[fvgrid[:,2] .< 0, :], :auto)
rename!(fvgrid, [:node, :longitude, :latitude, :bad])
select!(fvgrid, [:longitude, :latitude])

fvtest = [fvgrid; fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid;fvgrid]

fvtest[:, "sigma"] .= repeat(1:20, inner = 34395) ./1000
pset = PointSet(Matrix(fvtest[:, 1:3])')


fvcomInterp = EFDCgeotable |> Interpolate(pset, NN())
writedlm("../../input/initLOTP2018.dat", reshape(fvcomInterp.tp, (34395, 20)), " ")

