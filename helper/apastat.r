apa.stat <- function(x, stat_name = NULL, n = NULL, standardized = FALSE, ci = 0.95, in_paran = FALSE) {
  # Add alternative method if(is.list(x)) using list names as parameters and values as statistics

  if(in_paran) {
    op <- "["; cp <- "]"
  } else {
    op <- "("; cp <- ")"
  }

  if(class(x) == "htest") {
    if(is.null(stat_name)) stat_name <- names(x$statistic)
    stat <- printnum(x$statistic)

    if(!is.null(x$sample.size)) n <- x$sample.size

    if(!is.null(x$parameter)) {
      if(tolower(names(x$parameter)) == "df") {
        if(x$parameter%%1==0) printdigits <- 0 else printdigits = 2
        if(grepl("X|chi", stat_name, ignore.case = TRUE)) {
          if(is.null(x$sample.size) & is.null(n)) stop("Please provide the sample size to report.")
          stat_name <- paste0(stat_name, op, printnum(x$parameter[grep("df", names(x$parameter), ignore.case = TRUE)], digits = printdigits), ", n = ", n, cp)
        } else {
          stat_name <- paste0(stat_name, op, printnum(x$parameter[grep("df", names(x$parameter), ignore.case = TRUE)], digits = printdigits), cp)
        }
      }
    }

    p <- printnum(x$p.value, digits = 3, gt1 = FALSE, zero = FALSE)
    if(!grepl("<|>", p)) eq <- "= " else eq <- ""
    apa.stat <- paste0("$", stat_name, " = ", stat, "$, $p ", eq, p, "$")
  } else if(class(x) == "summary.lm") {
    coefs <- x$coefficients
    if(is.matrix(ci)) {
      coefs <- cbind(coefs, ci = ci)
    } else stop("Please supply estimates of confidence intervals.")

    p_pos <- grep("Pr|p-value", colnames(coefs))
    if(standardized) stat_name <- "\\beta" else stat_name <- "b"

    apa.stat <- apply(coefs, 1, function(y) { # DF FOR t!!!
      p <- printnum(y[p_pos], digits = 3, gt1 = FALSE, zero = FALSE)
      if(!grepl("<|>", p)) eq <- "= " else eq <- ""
      paste0("$", stat_name, " = ", printnum(y["Estimate"], gt1 = !standardized)
             , paste0("$ $[", paste(printnum(y[tail(names(y), 2)], gt1 = !standardized), collapse = ", "), "]")
             , "$, $t = ",  printnum(y["t value"]), "$, $p ", eq, p, "$"
      )
    })
    p <- printnum(pf(x$fstatistic[1], x$fstatistic[2], x$fstatistic[3], lower.tail = FALSE), digits = 3, gt1 = FALSE, zero = FALSE)
    if(!grepl("<|>", p)) eq <- "= " else eq <- ""
    f <- paste0("$F", op, x$fstatistic["numdf"], ",", x$fstatistic["dendf"], cp, " = ", printnum(x$fstatistic["value"])
                , "$, $p ", eq, p, "$"
    )
    r2 <- paste0("$R^2 = ", printnum(x$r.squared, gt1 = FALSE), "$")
    apa.stat <- c(apa.stat, `F-test` = f, `R^2` = r2)
  } else {
    stop("No method defined for object class ", class(x), ".")
  }

  return(apa.stat)
}