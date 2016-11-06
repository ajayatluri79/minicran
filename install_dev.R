## install script for R(adiant) @ Rady School of Management (MBA)
owd <- setwd(tempdir())

repos <- c("https://radiant-rstats.github.io/minicran/", "https://cran.rstudio.com")
options(repos = c(CRAN = repos))

build <- function() {
	update.packages(lib.loc = .libPaths()[1], ask = FALSE, repos = "https://radiant-rstats.github.io/minicran/", type = "binary")
	install <- function(x) {
		if (!x %in% installed.packages()) install.packages(x, type = 'binary')
	}

	resp <- sapply(
		c("radiant", "devtools", "roxygen2", "testthat", "gitgadget", "lintr", "haven", "readxl", "miniUI"), install
	)

	pkgs <- new.packages(lib.loc = .libPaths()[1], repos = 'https://radiant-rstats.github.io/minicran', type = 'binary', ask = FALSE)
	if (length(pkgs) > 0) install.packages(pkgs, repos = 'https://radiant-rstats.github.io/minicran', type = 'binary')
}

readliner <- function(text, inp = "", resp = "[yYnN]") {
	while (!grepl(resp, inp)) inp <- readline(text)
	inp
}

rv <- R.Version()

if (as.numeric(rv$major) < 3 || as.numeric(rv$minor) < 3) {
	cat("Radiant requires R-3.3.0 or later. Please install the latest\nversion of R from https://cloud.r-project.org/")
} else {

	os <- Sys.info()["sysname"]
	if (os == "Windows") {

		build()

		if (!require("installr")) {
		  install.packages("installr")
		  library("installr")
		}

		installr::install.Rtools()
		installr::install.git()

		## get putty for ssh
		page <- readLines("http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html", warn = FALSE)
		pat <- "//the.earth.li/~sgtatham/putty/latest/x86/putty-[0-9.]+-installer.msi"
		URL <- paste0("http:",regmatches(page,regexpr(pat,page))[1])
		installr::install.URL(URL)

		cat("\n\nInstallation on Windows complete. Close R and start Rstudio\n\n")
	} else if (os == "Darwin") {

		## from http://unix.stackexchange.com/a/712
		resp <- system("sw_vers -productVersion", intern = TRUE)

    if (as.integer(strsplit(resp, "\\.")[[1]][2]) < 9) {
			cat("The version of OSX on your mac is no longer supported by R. You will need to upgrade the OS before proceeding\n\n")
    } else {

			build()

			xc <- system("xcode-select --install", ignore.stderr = TRUE)
			if (xc == 1) {
				cat("\n\nXcode command line tools are already installed\n\n")
			} else {
				cat("\n\nXcode command line tools were successfully installed\n\n")
			}

			hb <- suppressWarnings(system("which brew", intern = TRUE))
			if (length(hb) == 0) {
			  cat("If you are going to use Mac OS for scientific computing we recommend that you install homebrew")
			  inp <- readliner("Type y to install homebrew or n to stop the process: ")
			  if (grepl("[yY]", inp)) {
			    hb_string <- "tell application \"Terminal\"\n\tactivate\n\tdo script \"/usr/bin/ruby -e \\\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\\\"\"\nend tell"
			    cat(hb_string, file="homebrew.scpt",sep="\n")
			    system("osascript homebrew.scpt", wait = TRUE)
		    }
			}

			cat("\n\nInstallation on Mac complete. Close R and start Rstudio\n\n")
		}
	} else {
		cat("\n\nThe install script is not currently supported on your OS")
	}
}

setwd(owd)
