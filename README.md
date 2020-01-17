# MSSQL-Export-Stored-Procedures
Collection of TSQL stored procedures, utilizing various binary executables, that enable very simple exporting of data to a number of formats.

## Getting Started

1. Execute each of the scripts in the 'scripts' directory on the desired database.
2. Place the binary for wkhtmlpdf/pdftk/csv2xlsx in any directory included in your PATH variable.
3. If neccesary, uncomment the code at the start of 'exp_CheckDependencies.sql' in order to set the correct configurations for the SQL Server instance.
4. Modify the configuration properties within each script.
5. Export some data!

## Dependencies

* [wkhtmlpdf](https://wkhtmltopdf.org/) - Command-line application used for rendering of HTML to PDF.
* [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) - PDFtk is a simple tool for doing everyday things with PDF documents.
* [csv2xlsx](https://gitlab.com/DerLinkshaender/csv2xlsx) - A simple, single file executable, no runtime libs command line tool to convert a CSV file to XLSX, written in Go.

