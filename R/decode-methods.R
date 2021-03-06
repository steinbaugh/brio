#' Decode column data that uses run-length encoding
#'
#' @name decode
#' @inherit AcidGenerics::decode description return
#' @note Updated 2021-06-09.
#'
#' @inheritParams AcidRoxygen::params
#' @param ... Additional arguments.
#'
#' @return Modified object.
#' Columns will be decoded and no longer `Rle` class.
#'
#' @seealso `S4Vectors::decode()`.
#'
#' @examples
#' data(DFrame, package = "AcidTest")
#' df <- DFrame
#'
#' ## DataFrame ====
#' df <- encode(df)
#' lapply(df, class)
#' x <- decode(df)
#' lapply(x, class)
NULL



## Updated 2021-06-09.
`decode,DataFrame` <-  # nolint
    function(x) {
        if (!(hasCols(x) && hasRows(x))) {
            return(x)
        }
        meta <- metadata(x)
        rn <- rownames(x)
        list <- lapply(
            X = x,
            FUN = function(x) {
                if (is(x, "List")) {
                    return(x)
                }
                ## Decode Rle, if necessary.
                if (is(x, "Rle")) {
                    x <- decode(x)
                }
                ## Adjust (drop) factor levels, if necessary.
                if (is.factor(x)) {
                    x <- droplevels(x)
                }
                x
            }
        )
        out <- as.DataFrame(list)
        rownames(out) <- rn
        metadata(out) <- meta
        out
    }



#' @rdname decode
#' @export
setMethod(
    f = "decode",
    signature = signature("DataFrame"),
    definition = `decode,DataFrame`
)



## Updated 2019-07-20.
`decode,Ranges` <-  # nolint
    function(x) {
        if (!is.null(mcols(x))) {
            mcols(x) <- decode(mcols(x))
        }
        x
    }



#' @rdname decode
#' @export
setMethod(
    f = "decode",
    signature = signature("Ranges"),
    definition = `decode,Ranges`
)
