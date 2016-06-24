repos <- c("https://radiant-rstats.github.io/minicran/", "https://cloud.r-project.org")
options(repos = c(CRAN = repos))

install.packages("radiant", repos = "https://radiant-rstats.github.io/minicran/", type = 'binary')
install.packages("webshot", repos = "http://cran.rstudio.com", type = "binary")
if (Sys.which("phantomjs") == "") eval(parse(text = "webshot::install_phantomjs()"))

os <- Sys.info()["sysname"]

if (os == "Windows") {
	if (grepl("Pr", Sys.getenv("R_HOME"))) {
		stop("It seems you installed R in the Program Files directory. Please uninstall R and install it into C:\\R\\R-3.3.1")
	} else {
		install.packages("installr")
	  installr::install.miktex(ver)
		installr::install.rstudio()
		ver <- if (grepl("64",Sys.getenv()["PROCESSOR_IDENTIFIER"])) 64 else 32
		installr::install.MikTek(ver)
		installr::install.Rtools()
	}
} else if (os == "Darwin") {

	tmp <- tempdir()
	setwd(tmp)
	download.file("https://download1.rstudio.org/RStudio-0.99.902.dmg","Rstudio.dmg")
	system("open RStudio.dmg")
	download.file("http://tug.org/cgi-bin/mactex-download/MacTeX.pkg", "MacTex.pkg")
	system("open MacTex.pkg")
} else {
	stop("Your OS is not currently supported")
}

