# Convert initial conditions from Limnotechs EFDC for Lake Ontario
using NetCDF 
using CSV
using DataFrames
using Chain
using TidierData
using GeoStats
using DelimitedFiles

year = "2018"


file = "loemInit" * year *".csv"
#file = "ic2018.inp"


tpinits = CSV.read(file, DataFrame)

efdcMap = @chain DataFrame(readdlm("/work/GLFBREEZ/LOEM/2013_simulation/inputs/latitudes_longitudes.txt", skipstart = 1), :auto) begin
  @rename(I = x1, J = x2, lat = x3, lon = x4)
  @right_join(tpinits)
  @drop_missing(lat,lon)
  # mutliply by 2 to map it to FVCOM
  @mutate(K = K*2 / 1000)
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
writedlm("../../input/init" * year * ".dat", reshape(fvcomInterp.tp, (:, 20)), " ")

