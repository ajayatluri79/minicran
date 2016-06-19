###############################################################
### RUN OUTSIDE OF RADIANT
###############################################################

# is local_dir is not in the library path (e.g., when usig brew in mac)
local_dir <- Sys.getenv("R_LIBS_USER")
if (!file.exists(local_dir)) {
	dir.create(local_dir, recursive = TRUE)
	.libPaths(local_dir)
}

local_dir <- .libPaths()[1]
global_dir <- .libPaths()[2]
# local_dir
# global_dir

# installing packages to global_dir
repos <- "http://cran.rstudio.com"
options(repos = c(CRAN = repos))

# remove.packages('devtools', global_dir)
# install.packages("devtools", lib = global_dir)
library(devtools)
# devtools::install_github("andrie/miniCRAN@dev")
# install.packages("miniCRAN", lib = global_dir)
# install.packages("miniCRAN")
# install.packages("rmarkdown", lib = global_dir)
library(miniCRAN)
# install.packages("miniCRAN")

# Specify list of packages to download
# source('~/gh/radiant_miniCRAN/pkgs.R')

# devtools::source_url("https://raw.githubusercontent.com/mostly-harmless/radiant_miniCRAN/gh-pages/pkgs.R")

# cleanup to start
# for (i in pkgs_all)
# 	remove.packages(i, lib = local_dir)
#
# for (i in pkgs_all)
# 	remove.packages(i, lib = global_dir)

# install github packages locally
# from http://stackoverflow.com/questions/24646065/how-to-specify-lib-directory-when-installing-development-version-r-packages-from
# installing radiant from github (with dependencies - hopefully :) )
# for (i in pkgs_ghrepos)
# 	with_libpaths(new = local_dir, install_github(i))

# create the local / github repo based on radiant's dependencies
# gh_repos <- "http://mostly-harmless.github.io/radiant_miniCRAN/"
# pkgs <- "radiant"
# pkgList <- pkgDep(pkgs, repos=gh_repos, type="source", suggests = FALSE)
# str(pkgList)
# pkgList[order(pkgList)]

# building the gh packages is now done in build_mac_win.sh
# library(miniCRAN)
# repos <- "http://cran.rstudio.com"
# options(repos = c(CRAN = repos))

# pth <- "~/gh/radiant_miniCRAN"
# pkgs_cran = c("htmlwidgets")
# pkgs_cran = c("radiant")
# pkgs_cran = c("radiant", "shiny", "dplyr", "DT")
# pkgs_cran = c("shiny", "dplyr", "DT", "readr", "rmarkdown")
# pkgs_cran = c("DiagrammeR")
# pkgs_cran = c("radiant")
# repos <- "http://cran.rstudio.com"

# options(repos = c(CRAN = repos))
pth <- "~/gh/radiant_miniCRAN"
pkgs_cran = c('knitr','import','shiny')
pkgs_cran = c('sourcetools')
# pkgs_cran = c("readr")
# repos <- "http://vnijs.github.io/radiant_miniCRAN/"
# repos <- c("https://vnijs.github.io/radiant_miniCRAN/", "https://cran.rstudio.com")
# repos <- "http://cran.rstudio.com"
repos <- "https://cloud.r-project.org"
# install.packages("miniCRAN")
# library(miniCRAN)

# building minicran for source packages
pkgList <- pkgDep(pkgs_cran, repos = repos, type = "source", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "source")

# building minicran for windows binaries
pkgList <- pkgDep(pkgs_cran, repos = repos, type = "win.binary", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "win.binary")

# building minicran for mac binaries
pkgList <- pkgDep(pkgs_cran, repos = repos, type = "mac.binary", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "mac.binary")

# building minicran for mac mavericks binaries
pkgList <- pkgDep(pkgs_cran, repos = repos, type = "mac.binary.mavericks", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "mac.binary.mavericks")

library(dplyr)
library(magrittr)

pdirs <- c("src/contrib", "bin/windows/contrib/3.3", "bin/macosx/contrib/3.3",
           "bin/macosx/mavericks/contrib/3.3")

for(pdir in pdirs) {
  list.files(file.path(pth, pdir)) %>%
    data.frame(fn = ., stringsAsFactors=FALSE) %>%
    mutate(pkg_file = fn, pkg_name = strsplit(fn, "_") %>% sapply("[",1),
    			 pkg_version = strsplit(fn, "_") %>% sapply("[",2)) %>%
    group_by(pkg_name) %>%
    arrange(desc(pkg_version)) %>%
    summarise(old = n(), pkg_file_new = first(pkg_file), pkg_file_old = last(pkg_file)) %>%
    filter(old > 1) %T>% print -> old

  if(nrow(old) > 0) {
    for(pf in old$pkg_file_old) {
    	unlink(file.path(pth, pdir, pf))
    }
  }
}

for (pdir in pdirs[-1]) {
  from <- paste0(file.path(pth, pdir),"/")
  to <- gsub("3.3","3.2", from)
  system(paste("rsync -vax", from, to))
}

## needed to update PACKAGES after deleting old versions
library(tools)
write_PACKAGES(file.path(pth, "bin/macosx/contrib/3.2/"), type = "mac.binary")
write_PACKAGES(file.path(pth, "bin/macosx/contrib/3.3/"), type = "mac.binary")

write_PACKAGES(file.path(pth, "bin/windows/contrib/3.2/"), type = "win.binary")
write_PACKAGES(file.path(pth, "bin/windows/contrib/3.3/"), type = "win.binary")

write_PACKAGES(file.path(pth, "bin/macosx/mavericks/contrib/3.3/"), type = "mac.binary")
write_PACKAGES(file.path(pth, "bin/macosx/mavericks/contrib/3.2/"), type = "mac.binary")
write_PACKAGES(file.path(pth, "src/contrib/"), type = "source")



