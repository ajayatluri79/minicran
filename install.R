repos <- c("https://radiant-rstats.github.io/minicran/", "https://cloud.r-project.org")
options(repos = c(CRAN = repos))

build <- function() {
	install.packages("radiant", repos = "https://radiant-rstats.github.io/minicran/", type = 'binary')
	install.packages("webshot", repos = "https://cran.rstudio.com", type = "binary")
	if (Sys.which("phantomjs") == "") eval(parse(text = "webshot::install_phantomjs()"))
}

rv <- R.Version()

if (as.numeric(rv$major) < 3 || as.numeric(rv$minor) < 3) {
  cat("Radiant requires R-3.3.0 or later. Please install the latest version of R from https://cloud.r-project.org/")
} else {

	os <- Sys.info()["sysname"]

	if (os == "Windows") {
		if (grepl("(Prog)|(PROG)", Sys.getenv("R_HOME"))) {
	    rv <- paste(rv$major, rv$minor, sep = ".")
			cat(paste0("It seems you installed R in the Program Files directory. Please uninstall R and re-install into C:\\R\\R-",rv))
		} else {
			build()
			install.packages("installr")
			installr::install.rstudio()
			installr::install.Rtools()

		  cat("To generate PDF reports in Radiant you will need MicTex. This is a large download (approx 100MB).\n")
		  inp <- readline("Proceed with the install? y/n ")
		  if (inp %in% c("y","yes","Yes","yes","YES")) {
			  ver <- if (grepl("64",Sys.getenv()["PROCESSOR_IDENTIFIER"])) 64 else 32
			  installr::install.MikTex(ver)
			}
		}

		cat("Installation on Windows complete. Start Rstudio and select Radiant from the Addins menu to get started")
	} else if (os == "Darwin") {
		build()
		tmp <- tempdir()
		setwd(tmp)
		download.file("https://download1.rstudio.org/RStudio-0.99.902.dmg","Rstudio.dmg")
		system("open RStudio.dmg")

		cat("To generate PDF reports in Radiant you will need MacTex. This is a large download (approx 2GB).\n")
		inp <- readline("Proceed with the install? y/n ")
		if (inp %in% c("y","yes","Yes","yes","YES")) {
			download.file("http://tug.org/cgi-bin/mactex-download/MacTeX.pkg", "MacTex.pkg")
			system("open MacTex.pkg")
		}
		cat("Installation on Mac complete. Start Rstudio and select Radiant from the Addins menu to get started")
	} else {
		cat("Your OS is not currently supported")
	}
}

