upFirst <- function(x)
{
  substr(x,1,1) <- toupper(substr(x,1,1))
  x
}

markThousands <- function(val)
{
  gsub("\\B(?=(\\d{3})+(?!\\d))", ",", val, perl=T)
}