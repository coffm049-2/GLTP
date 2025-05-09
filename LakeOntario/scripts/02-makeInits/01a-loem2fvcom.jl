# Convert initial conditions from Limnotechs EFDC for Lake Ontario
 
using CSV
using DataFrames
using Chain
using TidierData

# taken and reformatted form here
#file = "/work/GLFBREEZ/LOEM/2013_simulation/inputs/ic.inp"
file = "ic2018.inp"
#file = "ic2018.inp"

# first used vim to remove white space after equals signs (both single and doubles)
df = @chain CSV.read(file, DataFrame; delim = " ", header = false) begin
  @rename(analyte = Column1, J=Column9, K=Column10)
  @mutate(
    J = as_integer(J),
    K = as_integer(K),
  )
  # filter to just TP subspecies (already did this in reformatting)
  @pivot_longer(
    cols = [:Column2, :Column3, :Column4, :Column5, :Column6, :Column7, :Column8])
  @drop_missing()
  @group_by(J, K, analyte)
  @mutate(I = 1:n())
  @filter(analyte ∈ ["RPOP", "LPOP", "RDOP", "LDOP", "PO4T", "LPIP", "RPIP", "IPOP"])
  # @mutate(tot = (Column3+ Column4+ Column5+ Column6+ Column7+ Column8) /8 )
  # @group_by(analyte, I, J)
  # @summarize(tot = mean(tot))
  @ungroup()
  @group_by(I,J,K)
  @summarize(tp = sum(value))
  @ungroup()
  #@pull(tp)
end

CSV.write("loemInit2018.csv", df)
# this can then be shared  with tom to impute to FVCOM grid
