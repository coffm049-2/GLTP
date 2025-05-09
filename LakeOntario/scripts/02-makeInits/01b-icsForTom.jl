# Convert initial conditions from Limnotechs EFDC for Lake Ontario
 
using CSV
using DataFrames
using Chain
using TidierData

# taken and reformatted form here
#file = "/work/GLFBREEZ/LOEM/2013_simulation/inputs/ic.inp"
file = "loemInit2013.csv"
#file = "ic2018.inp"

# first used vim to remove white space after equals signs (both single and doubles)
df = @chain CSV.read(file, DataFrame) begin
  @group_by(I, J)
  @summarize(tp = mean(tp))
  @ungroup()
  #@pull(tp)
end

CSV.write("loem2013ForTom.csv", df)

