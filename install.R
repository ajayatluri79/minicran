## install script for R(adiant) @ Rady School of Management (MBA)
cdir <- getwd()
repos <- c("https://radiant-rstats.github.io/minicran/", "https://cran.rstudio.com")
options(repos = c(CRAN = repos))

build <- function() {
	update.packages(lib.loc = .libPaths()[1], ask = FALSE, repos = "https://radiant-rstats.github.io/minicran/", type = "binary")
	install <- function(x) {
		if (!x %in% installed.packages()) install.packages(x, type = 'binary')
	}

	resp <- sapply(c("radiant", "haven", "readxl", "miniUI", "webshot"), install)

	## needed for windoze
	pkgs <- new.packages(lib.loc = .libPaths()[1], repos = 'https://radiant-rstats.github.io/minicran', type = 'binary', ask = FALSE)
	if (length(pkgs) > 0) install.packages(pkgs, repos = 'https://radiant-rstats.github.io/minicran', type = 'binary')

	# see https://github.com/wch/webshot/issues/25#event-740360519
	if (is.null(webshot:::find_phantom())) webshot::install_phantomjs()
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
		lp <- .libPaths()[grepl("Documents",.libPaths())]
		if (grepl("(Prog)|(PROG)", Sys.getenv("R_HOME"))) {
			rv <- paste(rv$major, rv$minor, sep = ".")
			cat(paste0("It seems you installed R in the Program Files directory.\nPlease uninstall R and re-install into C:\\R\\R-",rv),"\n\n")
		} else if (length(lp) > 0) {

			cat("Installing R-packages in the directory printed below often causes\nproblems on Windows. Please remove the 'Documents/R' directory,\nclose and restart R, and run the script again.\n\n")
			cat(paste0(lp, collapse = "\n"),"\n\n")
		} else {

			build()
			install.packages("installr")
			# page <- readLines("https://www.rstudio.com/ide/download/desktop", warn = FALSE)
			# pat <- "//download1.rstudio.org/RStudio-[0-9.]+.exe";
			## get rstudio - preview
			page <- readLines("https://www.rstudio.com/products/rstudio/download/preview/", warn = FALSE)
			pat <- "//s3.amazonaws.com/rstudio-dailybuilds/RStudio-[0-9.]+.exe"
			URL <- paste0("https:",regmatches(page,regexpr(pat,page))[1])
			installr::install.URL(URL, installer_option = "/S")

			wz <- suppressWarnings(system("where R", intern = TRUE))
			w7z <- suppressWarnings(system("where 7z", intern = TRUE))
			if (!grepl("zip", wz) && !grepl("7-Zip", w7z)) {
				# installr::install.7zip()
				URL <- "https://radiant-rstats.github.io/minicran/bin/7z1602.exe"
				installr::install.URL(URL)
				if (file.exists(file.path(Sys.getenv("ProgramFiles"), "7-Zip"))) {
					shell(paste0("setx PATH \"", paste0(Sys.getenv("ProgramFiles"), "\\7-Zip\"")))
				} else if (file.exists(file.path(Sys.getenv("ProgramFiles(x86)"), "7-Zip"))) {
					shell(paste0("setx PATH \"", paste0(Sys.getenv("ProgramFiles(x86)"), "\\7-Zip\"")))
				} else {
					cat("Couldn't find the location where 7-zip was installed. Update the system path manually\n")
				}
			}

			cat("\nTo generate PDF reports in Radiant you will need MikTex. This is a large\ndownload (approx 100MB).\n")
			inp <- readliner("Proceed with the install? Press y or n and then press return: ")
			if (grepl("[yY]", inp)) {
				ver <- if (grepl("64",Sys.getenv()["PROCESSOR_IDENTIFIER"])) 64 else 32
				installr::install.miktex(ver)
			}
			cat("\n\nInstallation on Windows complete. Close R, start Rstudio, and select Radiant\nfrom the Addins menu to get started\n\n")
		}
	} else if (os == "Darwin") {

    resp <- system("sw_vers -productVersion", intern = TRUE)
    if (as.integer(strsplit(resp, "\\.")[[1]][2]) < 9) {
			cat("The version of OSX on your mac is no longer supported by R. You will need to upgrade the OS before proceeding\n\n")
    } else {

			build()

			## get rstudio
			##  based on https://github.com/talgalili/installr/blob/82bf5b542ce6d2ef4ebc6359a4772e0c87427b64/R/install.R#L805-L813
			# page <- readLines("https://www.rstudio.com/ide/download/desktop", warn = FALSE)
			# pat <- "//download1.rstudio.org/RStudio-[0-9.]+.dmg";
			## get rstudio - preview
			page <- readLines("https://www.rstudio.com/products/rstudio/download/preview/", warn = FALSE)
			pat <- "//s3.amazonaws.com/rstudio-dailybuilds/RStudio-[0-9.]+.dmg"
			URL <- paste0("https:",regmatches(page,regexpr(pat,page))[1])
			tmp <- tempdir()
			setwd(tmp)
			download.file(URL,"Rstudio.dmg")
			system("open RStudio.dmg")

			cat("To generate PDF reports in Radiant you will need MacTex. This is a very large\ndownload (approx 2GB).\n")
			inp <- readliner("Proceed with the install? Press y or n and then press return: ")
			if (grepl("[yY]", inp)) {
				download.file("http://tug.org/cgi-bin/mactex-download/MacTeX.pkg", "MacTex.pkg")
				system("open MacTex.pkg", wait = TRUE)
			}
			cat("\n\nInstallation on Mac complete. Close R, start Rstudio, and select Radiant\nfrom the Addins menu to get started\n\n")
    }
  } else {
		cat("\n\nThe install script is not currently supported on your OS")
	}
}

setwd(cdir)
