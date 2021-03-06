context("export : character")

vec <- c("hello", "world")

test_that("'ext' argument", {
    for (ext in eval(formals(`export,character`)[["ext"]])) {
        file <- paste0("vec", ".", ext)
        x <- export(object = vec, ext = ext)
        expect_identical(x, realpath(file))
        expect_true(file.exists(file))
        expect_identical(
            object = readLines(file),
            expected = vec
        )
        ## Check accidental overwrite support.
        expect_error(
            export(vec, ext = ext, overwrite = FALSE),
            "File exists"
        )
        expect_message(
            export(vec, ext = ext, overwrite = TRUE),
            "Overwriting"
        )
        file.remove(file)
    }
})



context("export : matrix")

test_that("'ext' argument", {
    for (ext in eval(formals(`export,matrix`)[["ext"]])) {
        file <- paste0("mat", ".", ext)
        x <- export(object = mat, ext = ext)
        expect_identical(x, realpath(file))
        expect_true(file.exists(file))
        ## Check that row names stay intact.
        expect_true(grepl(
            pattern = "rowname",
            x = head(readLines(file), n = 1L)
        ))
        ## Check accidental overwrite support.
        expect_error(
            export(mat, ext = ext, overwrite = FALSE),
            "File exists"
        )
        expect_message(
            export(mat, ext = ext, overwrite = TRUE),
            "Overwriting"
        )
        ## Now strip the names, and confirm that export still works.
        mat <- unname(mat)
        x <- export(object = mat, ext = ext)
        expect_identical(x, realpath(file))
        expect_true(file.exists(file))
        expect_true(grepl(
            pattern = "V1",
            x = head(readLines(file), n = 1L)
        ))
        file.remove(file)
    }
})

test_that("acid.export.engine override", {
    for (engine in c("base", "data.table", "readr", "vroom")) {
        options("acid.export.engine" = engine)
        file <- export(object = mat, ext = "csv")
        expect_true(file.exists(file))
        expect_identical(basename(file), "mat.csv")
        unlink(file)
    }
    options("acid.export.engine" = NULL)
})

test_that("Invalid input", {
    expect_error(
        export(object = unname(mat)),
        "symbol"
    )
})



context("export : DataFrame")

test_that("'ext' argument", {
    for (ext in eval(formals(`export,DataFrame`)[["ext"]])) {
        file <- paste0("df", ".", ext)
        x <- export(df, ext = ext)
        expect_identical(x, realpath(file))
        expect_true(file.exists(file))
        ## Check that row names stay intact.
        expect_true(grepl(
            pattern = "rowname",
            x = head(readLines(file), n = 1L)
        ))
        file.remove(file)
    }
})

test_that("'file' argument", {
    x <- export(df, file = "df.csv")
    expect_identical(x, realpath("df.csv"))
    expect_true(file.exists("df.csv"))
    file.remove("df.csv")
})

test_that("Invalid input", {
    ## Note that `unname()` usage will result in a DataFrame error.
    expect_error(
        export(object = as.data.frame(df)),
        "symbol"
    )
})



context("export : sparseMatrix")

test_that("'ext' argument, using gzip compression (default)", {
    x <- export(sparse, ext = "mtx.gz")
    expect_identical(
        x,
        c(
            matrix = realpath("sparse.mtx.gz"),
            barcodes = realpath("sparse.mtx.gz.colnames"),
            genes = realpath("sparse.mtx.gz.rownames")
        )
    )
    expect_true(all(file.exists(x)))
    ## Check accidental overwrite support.
    expect_error(
        export(sparse, ext = "mtx.gz", overwrite = FALSE),
        "File exists"
    )
    expect_message(
        export(sparse, ext = "mtx.gz", overwrite = TRUE),
        "Overwriting"
    )
    file.remove(x)
})

test_that("'file' argument", {
    x <- export(sparse, file = "sparse.mtx")
    expect_identical(
        x,
        c(
            matrix = realpath("sparse.mtx"),
            barcodes = realpath("sparse.mtx.colnames"),
            genes = realpath("sparse.mtx.rownames")
        )
    )
    expect_true(all(file.exists(x)))
    file.remove(x)
})

test_that("Invalid input", {
    expect_error(
        export(object = unname(sparse)),
        "symbol"
    )
})
