df <- read.delim("totalMassAdded.txt", header = F, sep = " ")
names(df) <- c("system", "mass", "Model")

df <- df[df$system %in% c(7,8,9,10,11,36,37,38), ]
df$species <- c("RPOP", "LPOP", "RDOP", "LDOP", "PO4T", "LPIP", "RPIP")
df$TPfromTrib <- 1400000
df$percent <- (df$mass / df$TPfromTrib) *100




