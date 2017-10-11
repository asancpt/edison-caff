updatelib:
	Rscript -e "update.packages(.libPaths()[1], ask = FALSE)"

ziplib:
	zip -FSr lib-tidyverse.zip lib/*
