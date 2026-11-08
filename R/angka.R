# Indonesian number format for everything the Indonesian sessions display: a comma for the
# decimal mark and a full stop for thousands (UK 1,234.5 is Indonesian 1.234,5).
# Sourced only by the *-id.Rmd sessions. The computed values are never changed, only shown.
# options(OutDec = ",") is not used: in R 4.6 it also changes as.character() and paste(),
# and tibbles ignore it.

# angka(): one number, or a vector, as text in Indonesian format (used in inline R).
angka <- function(x) format(x, big.mark = ".", decimal.mark = ",", trim = TRUE)

# tampil(): show a table or vector with Indonesian numbers. Number columns become text,
# so use it only at the end of a chunk, on what is printed, never on data used later.
tampil <- function(x) {
  fmt <- function(v) format(v, big.mark = ".", decimal.mark = ",")
  if (is.data.frame(x)) return(dplyr::mutate(x, dplyr::across(dplyr::where(is.numeric), fmt)))
  if (is.numeric(x)) return(noquote(fmt(x)))
  x
}

# Plot axes and legends. ggplot looks up its default scales by name, starting in the
# environment where the plot is made, so these versions are also used for axes the code
# never sets. An explicit labels = argument still wins.
label_angka <- scales::label_number(big.mark = ".", decimal.mark = ",")
scale_x_continuous <- function(..., labels = label_angka) ggplot2::scale_x_continuous(..., labels = labels)
scale_y_continuous <- function(..., labels = label_angka) ggplot2::scale_y_continuous(..., labels = labels)
scale_colour_continuous <- function(..., labels = label_angka) ggplot2::scale_colour_continuous(..., labels = labels)
scale_fill_continuous <- function(..., labels = label_angka) ggplot2::scale_fill_continuous(..., labels = labels)
scale_colour_gradient <- function(..., labels = label_angka) ggplot2::scale_colour_gradient(..., labels = labels)
scale_colour_gradient2 <- function(..., labels = label_angka) ggplot2::scale_colour_gradient2(..., labels = labels)
scale_fill_gradient <- function(..., labels = label_angka) ggplot2::scale_fill_gradient(..., labels = labels)
scale_colour_viridis_c <- function(..., labels = label_angka) ggplot2::scale_colour_viridis_c(..., labels = labels)
scale_fill_viridis_c <- function(..., labels = label_angka) ggplot2::scale_fill_viridis_c(..., labels = labels)
scale_size_continuous <- function(..., labels = label_angka) ggplot2::scale_size_continuous(..., labels = labels)
