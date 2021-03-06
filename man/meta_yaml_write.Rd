% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/yaml_meta_write.R
\name{meta_yaml_write}
\alias{meta_yaml_write}
\title{Write table metadata to a YAML file}
\usage{
meta_yaml_write(x = NULL, filename, path = NULL)
}
\arguments{
\item{x}{The input table. This can be a data frame, a tibble, a \code{tbl_dbi}
object, or a \code{tbl_spark} object.}

\item{filename}{The name of the YAML file to create on disk. It is
recommended that either the \code{.yaml} or \code{.yml} extension be used for this
file.}

\item{path}{An optional path to which the YAML file should be saved (combined
with \code{filename}).}
}
\description{
With \code{meta_yaml_write()} we can take a data table and generate
a metadata YAML file. With that \strong{pointblank} metadata YAML file, we can
further modify the YAML markup and add informational fields. Once that file
has been edited, we can get a tabular reporting object with the
\code{\link[=get_metadata_report]{get_metadata_report()}} function.
}
\examples{
# Generate a metadata YAML file
# for the `small_table` dataset
# meta_yaml_write(
#   small_table,
#   filename = "meta-small_table.yml"
# )

# The `meta-small_table.yml` file
# looks like this when written

#> label: '[2020-09-06|13:37:38]'
#> table:
#>   name: small_table
#> _columns: 8
#> _rows: 13
#> _type: tbl_df
#> columns:
#>   date_time:
#>     _type: POSIXct, POSIXt
#>   date:
#>     _type: Date
#>   a:
#>     _type: integer
#>   b:
#>     _type: character
#>   c:
#>     _type: numeric
#>   d:
#>     _type: numeric
#>   e:
#>     _type: logical
#>   f:
#>     _type: character

# We can add keys and values to
# enrich the metadata with more
# pertinent information; with some
# direct editing of the file we get:

#> label: '[2020-09-06|13:37:38]'
#> table:
#>   name: small_table
#>   _columns: 8
#>   _rows: 13
#>   _type: tbl_df
#> columns:
#>   date_time:
#>     _type: POSIXct, POSIXt
#>     info: Date-time values.
#>   date:
#>     _type: Date
#>     info: Date values (the date part of `date_time`).
#>   a:
#>     _type: integer
#>     info: Small integer values (no missing values).
#>   b:
#>     _type: character
#>     info: Strings with a common pattern.
#>   c:
#>     _type: numeric
#>     info: Small numeric values (contains missing values).
#>   d:
#>     _type: numeric
#>     info: Large numeric values (much greater than `c`).
#>   e:
#>     _type: logical
#>     info: TRUE and FALSE values.
#>   f:
#>     _type: character
#>     info: Strings of the set `"low"`, `"mid"`, and `"high"`.

# We can visualize this metadata
# into a report table by using the
# `get_metadata_report()` function

#> get_metadata_report(
#>   system.file(
#>     "meta-small_table.yml",
#>     package = "pointblank"
#>   )
#> )

}
