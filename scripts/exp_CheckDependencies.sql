if object_id('exp_CheckDependencies') is not null
	exec ('drop procedure exp_CheckDependencies')
GO

create procedure [dbo].[exp_CheckDependencies] as

set nocount on;

---- to allow advanced options to be changed.  
--exec sp_configure 'show advanced options', 1;  
--reconfigure;  

---- to enable the feature.  
--exec sp_configure 'xp_cmdshell', 1;  
--reconfigure;  

---- to allow advanced options to be changed. 
--exec sp_configure 'show advanced options', 1;  
--reconfigure;  

---- to enable the feature. 
--exec sp_configure 'ole automation procedures', 1;  
--reconfigure;  

if object_id('exp_htmlEncode') is null
begin
	exec('
	create function dbo.exp_htmlEncode (@input varchar(max))
	returns varchar(MAX)
	as begin
		declare @result varchar(MAX) = @input;
		select @result = replace(@result collate Latin1_General_CS_AS, nchar(UnicodeDec), htmlEntity) from exp_htmlEntities option (maxrecursion 32000)
		return isnull(@result, '''')
	end')
end

if object_id('exp_ExportToHTML') is null
begin

	create table exp_htmlEntities(
		charValue nchar(1),
		htmlEntity nvarchar(20),
		CodePointHex nvarchar(12),
		UnicodeHex nvarchar(12),
		UnicodeDec int,
		descr nvarchar(200)
	)

	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'&', N'&amp;', N'0026', N'&#0026;', 38, N'ampersand')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'"', N'&quot;', N'0022', N'&#0022;', 34, N'quotation markÂ (APL quote)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'''', N'&apos;', N'0027', N'&#0027;', 39, N'apostropheÂ (apostrophe-quote); seeÂ below')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'<', N'&lt;', N'003C', N'&#003C;', 60, N'less-than sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'>', N'&gt;', N'003E', N'&#003E;', 62, N'greater-than sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¡', N'&iexcl;', N'00A1', N'&#00A1;', 161, N'inverted exclamation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¢', N'&cent;', N'00A2', N'&#00A2;', 162, N'cent sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'£', N'&pound;', N'00A3', N'&#00A3;', 163, N'pound sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¤', N'&curren;', N'00A4', N'&#00A4;', 164, N'currency sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¥', N'&yen;', N'00A5', N'&#00A5;', 165, N'yen signÂ (yuanÂ sign)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¦', N'&brvbar;', N'00A6', N'&#00A6;', 166, N'broken barÂ (broken vertical bar)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'§', N'&sect;', N'00A7', N'&#00A7;', 167, N'section sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¨', N'&uml;', N'00A8', N'&#00A8;', 168, N'diaeresisÂ (spacing diaeresis); seeÂ Germanic umlaut')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'©', N'&copy;', N'00A9', N'&#00A9;', 169, N'copyright symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ª', N'&ordf;', N'00AA', N'&#00AA;', 170, N'feminineÂ ordinal indicator')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'«', N'&laquo;', N'00AB', N'&#00AB;', 171, N'left-pointing double angle quotation markÂ (left pointingÂ guillemet)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¬', N'&not;', N'00AC', N'&#00AC;', 172, N'not sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'­', N'&shy;', N'00AD', N'&#00AD;', 173, N'soft hyphenÂ (discretionary hyphen)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'®', N'&reg;', N'00AE', N'&#00AE;', 174, N'registered signÂ (registered trademark symbol)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¯', N'&macr;', N'00AF', N'&#00AF;', 175, N'macronÂ (spacing macron, overline, APL overbar)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'°', N'&deg;', N'00B0', N'&#00B0;', 176, N'degree symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'±', N'&plusmn;', N'00B1', N'&#00B1;', 177, N'plus-minus signÂ (plus-or-minus sign)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'²', N'&sup2;', N'00B2', N'&#00B2;', 178, N'superscript twoÂ (superscript digit two, squared)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'³', N'&sup3;', N'00B3', N'&#00B3;', 179, N'superscript threeÂ (superscript digit three, cubed)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'´', N'&acute;', N'00B4', N'&#00B4;', 180, N'acute accentÂ (spacing acute)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'µ', N'&micro;', N'00B5', N'&#00B5;', 181, N'micro sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¶', N'&para;', N'00B6', N'&#00B6;', 182, N'pilcrowÂ signÂ (paragraph sign)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'·', N'&middot;', N'00B7', N'&#00B7;', 183, N'middle dotÂ (Georgian comma, Greek middle dot)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¸', N'&cedil;', N'00B8', N'&#00B8;', 184, N'cedillaÂ (spacing cedilla)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¹', N'&sup1;', N'00B9', N'&#00B9;', 185, N'superscript oneÂ (superscript digit one)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'º', N'&ordm;', N'00BA', N'&#00BA;', 186, N'masculineÂ ordinal indicator')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'»', N'&raquo;', N'00BB', N'&#00BB;', 187, N'right-pointing double angle quotation markÂ (right pointing guillemet)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¼', N'&frac14;', N'00BC', N'&#00BC;', 188, N'vulgar fraction one quarterÂ (fraction one quarter)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'½', N'&frac12;', N'00BD', N'&#00BD;', 189, N'vulgar fraction one halfÂ (fraction one half)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¾', N'&frac34;', N'00BE', N'&#00BE;', 190, N'vulgar fraction three quartersÂ (fraction three quarters)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'¿', N'&iquest;', N'00BF', N'&#00BF;', 191, N'inverted question markÂ (turned question mark)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'À', N'&Agrave;', N'00C0', N'&#00C0;', 192, N'Latin capital letter A withÂ grave accentÂ (Latin capital letter A grave)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Á', N'&Aacute;', N'00C1', N'&#00C1;', 193, N'Latin capital letter A withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Â', N'&Acirc;', N'00C2', N'&#00C2;', 194, N'Latin capital letter A withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ã', N'&Atilde;', N'00C3', N'&#00C3;', 195, N'Latin capital letter A withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ä', N'&Auml;', N'00C4', N'&#00C4;', 196, N'Latin capital letter A withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Å', N'&Aring;', N'00C5', N'&#00C5;', 197, N'Latin capital letter A with ring aboveÂ (Latin capital letter A ring)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Æ', N'&AElig;', N'00C6', N'&#00C6;', 198, N'Latin capital letter AEÂ (Latin capital ligature AE)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ç', N'&Ccedil;', N'00C7', N'&#00C7;', 199, N'Latin capital letter C withÂ cedilla')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'È', N'&Egrave;', N'00C8', N'&#00C8;', 200, N'Latin capital letter E withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'É', N'&Eacute;', N'00C9', N'&#00C9;', 201, N'Latin capital letter E withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ê', N'&Ecirc;', N'00CA', N'&#00CA;', 202, N'Latin capital letter E withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ë', N'&Euml;', N'00CB', N'&#00CB;', 203, N'Latin capital letter E withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ì', N'&Igrave;', N'00CC', N'&#00CC;', 204, N'Latin capital letter I withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Í', N'&Iacute;', N'00CD', N'&#00CD;', 205, N'Latin capital letter I withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Î', N'&Icirc;', N'00CE', N'&#00CE;', 206, N'Latin capital letter I withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ï', N'&Iuml;', N'00CF', N'&#00CF;', 207, N'Latin capital letter I withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Þ', N'&THORN;', N'00DE', N'&#00DE;', 222, N'Latin capital letterÂ THORN')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ð', N'&ETH;', N'00D0', N'&#00D0;', 208, N'Latin capital letterÂ Eth')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ñ', N'&Ntilde;', N'00D1', N'&#00D1;', 209, N'Latin capital letter N withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ò', N'&Ograve;', N'00D2', N'&#00D2;', 210, N'Latin capital letter O withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ó', N'&Oacute;', N'00D3', N'&#00D3;', 211, N'Latin capital letter O withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ô', N'&Ocirc;', N'00D4', N'&#00D4;', 212, N'Latin capital letter O withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Õ', N'&Otilde;', N'00D5', N'&#00D5;', 213, N'Latin capital letter O withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ö', N'&Ouml;', N'00D6', N'&#00D6;', 214, N'Latin capital letter O withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'×', N'&times;', N'00D7', N'&#00D7;', 215, N'multiplication sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ø', N'&Oslash;', N'00D8', N'&#00D8;', 216, N'Latin capital letter O with strokeÂ (Latin capital letter O slash)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ù', N'&Ugrave;', N'00D9', N'&#00D9;', 217, N'Latin capital letter U withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ú', N'&Uacute;', N'00DA', N'&#00DA;', 218, N'Latin capital letter U withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Û', N'&Ucirc;', N'00DB', N'&#00DB;', 219, N'Latin capital letter U withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ü', N'&Uuml;', N'00DC', N'&#00DC;', 220, N'Latin capital letter U withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ý', N'&Yacute;', N'00DD', N'&#00DD;', 221, N'Latin capital letter Y withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ß', N'&szlig;', N'00DF', N'&#00DF;', 223, N'Latin small letter sharp sÂ (ess-zed); see GermanÂ Eszett')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'à', N'&agrave;', N'00E0', N'&#00E0;', 224, N'Latin small letter a withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'á', N'&aacute;', N'00E1', N'&#00E1;', 225, N'Latin small letter a withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'â', N'&acirc;', N'00E2', N'&#00E2;', 226, N'Latin small letter a withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ã', N'&atilde;', N'00E3', N'&#00E3;', 227, N'Latin small letter a withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ä', N'&auml;', N'00E4', N'&#00E4;', 228, N'Latin small letter a withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'å', N'&aring;', N'00E5', N'&#00E5;', 229, N'Latin small letter a with ring above')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'æ', N'&aelig;', N'00E6', N'&#00E6;', 230, N'Latin small letter aeÂ (Latin small ligature ae)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ç', N'&ccedil;', N'00E7', N'&#00E7;', 231, N'Latin small letter c withÂ cedilla')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'è', N'&egrave;', N'00E8', N'&#00E8;', 232, N'Latin small letter e withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'é', N'&eacute;', N'00E9', N'&#00E9;', 233, N'Latin small letter e withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ê', N'&ecirc;', N'00EA', N'&#00EA;', 234, N'Latin small letter e withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ë', N'&euml;', N'00EB', N'&#00EB;', 235, N'Latin small letter e withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ì', N'&igrave;', N'00EC', N'&#00EC;', 236, N'Latin small letter i withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'í', N'&iacute;', N'00ED', N'&#00ED;', 237, N'Latin small letter i withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'î', N'&icirc;', N'00EE', N'&#00EE;', 238, N'Latin small letter i withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ï', N'&iuml;', N'00EF', N'&#00EF;', 239, N'Latin small letter i withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'þ', N'&thorn;', N'00FE', N'&#00FE;', 254, N'Latin small letterÂ thorn')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ð', N'&eth;', N'00F0', N'&#00F0;', 240, N'Latin small letterÂ eth')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ñ', N'&ntilde;', N'00F1', N'&#00F1;', 241, N'Latin small letter n withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ò', N'&ograve;', N'00F2', N'&#00F2;', 242, N'Latin small letter o withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ó', N'&oacute;', N'00F3', N'&#00F3;', 243, N'Latin small letter o withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ô', N'&ocirc;', N'00F4', N'&#00F4;', 244, N'Latin small letter o withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'õ', N'&otilde;', N'00F5', N'&#00F5;', 245, N'Latin small letter o withÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ö', N'&ouml;', N'00F6', N'&#00F6;', 246, N'Latin small letter o withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'÷', N'&divide;', N'00F7', N'&#00F7;', 247, N'division signÂ (obelus)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ø', N'&oslash;', N'00F8', N'&#00F8;', 248, N'Latin small letter o with strokeÂ (Latin small letter o slash)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ù', N'&ugrave;', N'00F9', N'&#00F9;', 249, N'Latin small letter u withÂ grave accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ú', N'&uacute;', N'00FA', N'&#00FA;', 250, N'Latin small letter u withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'û', N'&ucirc;', N'00FB', N'&#00FB;', 251, N'Latin small letter u withÂ circumflex')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ü', N'&uuml;', N'00FC', N'&#00FC;', 252, N'Latin small letter u withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ý', N'&yacute;', N'00FD', N'&#00FD;', 253, N'Latin small letter y withÂ acute accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ÿ', N'&yuml;', N'00FF', N'&#00FF;', 255, N'Latin small letter y withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Œ', N'&OElig;', N'0152', N'&#0152;', 338, N'Latin capital ligature oe[e]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'œ', N'&oelig;', N'0153', N'&#0153;', 339, N'Latin small ligature oe[e]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Š', N'&Scaron;', N'0160', N'&#0160;', 352, N'Latin capital letter s withÂ caron')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'š', N'&scaron;', N'0161', N'&#0161;', 353, N'Latin small letter s withÂ caron')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ÿ', N'&Yuml;', N'0178', N'&#0178;', 376, N'Latin capital letter y withÂ diaeresis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ƒ', N'&fnof;', N'0192', N'&#0192;', 402, N'Latin small letter f with hookÂ (function, florin)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ˆ', N'&circ;', N'02C6', N'&#02C6;', 710, N'modifier letterÂ circumflexÂ accent')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'˜', N'&tilde;', N'02DC', N'&#02DC;', 732, N'smallÂ tilde')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Α', N'&Alpha;', N'0391', N'&#0391;', 913, N'Greek capital letter Alpha')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Β', N'&Beta;', N'0392', N'&#0392;', 914, N'Greek capital letter Beta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Γ', N'&Gamma;', N'0393', N'&#0393;', 915, N'Greek capital letter Gamma')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Δ', N'&Delta;', N'0394', N'&#0394;', 916, N'Greek capital letter Delta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ε', N'&Epsilon;', N'0395', N'&#0395;', 917, N'Greek capital letter Epsilon')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ζ', N'&Zeta;', N'0396', N'&#0396;', 918, N'Greek capital letter Zeta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Η', N'&Eta;', N'0397', N'&#0397;', 919, N'Greek capital letter Eta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Θ', N'&Theta;', N'0398', N'&#0398;', 920, N'Greek capital letter Theta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ι', N'&Iota;', N'0399', N'&#0399;', 921, N'Greek capital letter Iota')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Κ', N'&Kappa;', N'039A', N'&#039A;', 922, N'Greek capital letter Kappa')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Λ', N'&Lambda;', N'039B', N'&#039B;', 923, N'Greek capital letter Lambda')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Μ', N'&Mu;', N'039C', N'&#039C;', 924, N'Greek capital letter Mu')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ν', N'&Nu;', N'039D', N'&#039D;', 925, N'Greek capital letter Nu')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ξ', N'&Xi;', N'039E', N'&#039E;', 926, N'Greek capital letter Xi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ο', N'&Omicron;', N'039F', N'&#039F;', 927, N'Greek capital letter Omicron')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Π', N'&Pi;', N'03A0', N'&#03A0;', 928, N'Greek capital letter Pi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ρ', N'&Rho;', N'03A1', N'&#03A1;', 929, N'Greek capital letter Rho')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Σ', N'&Sigma;', N'03A3', N'&#03A3;', 931, N'Greek capital letter Sigma')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Τ', N'&Tau;', N'03A4', N'&#03A4;', 932, N'Greek capital letter Tau')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Υ', N'&Upsilon;', N'03A5', N'&#03A5;', 933, N'Greek capital letter Upsilon')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Φ', N'&Phi;', N'03A6', N'&#03A6;', 934, N'Greek capital letter Phi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Χ', N'&Chi;', N'03A7', N'&#03A7;', 935, N'Greek capital letter Chi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ψ', N'&Psi;', N'03A8', N'&#03A8;', 936, N'Greek capital letter Psi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'Ω', N'&Omega;', N'03A9', N'&#03A9;', 937, N'Greek capital letter Omega')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'α', N'&alpha;', N'03B1', N'&#03B1;', 945, N'Greek small letter alpha')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'β', N'&beta;', N'03B2', N'&#03B2;', 946, N'Greek small letter beta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'γ', N'&gamma;', N'03B3', N'&#03B3;', 947, N'Greek small letter gamma')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'δ', N'&delta;', N'03B4', N'&#03B4;', 948, N'Greek small letter delta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ε', N'&epsilon;', N'03B5', N'&#03B5;', 949, N'Greek small letter epsilon')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ζ', N'&zeta;', N'03B6', N'&#03B6;', 950, N'Greek small letter zeta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'η', N'&eta;', N'03B7', N'&#03B7;', 951, N'Greek small letter eta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'θ', N'&theta;', N'03B8', N'&#03B8;', 952, N'Greek small letter theta')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ι', N'&iota;', N'03B9', N'&#03B9;', 953, N'Greek small letter iota')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'κ', N'&kappa;', N'03BA', N'&#03BA;', 954, N'Greek small letter kappa')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'λ', N'&lambda;', N'03BB', N'&#03BB;', 955, N'Greek small letter lambda')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'μ', N'&mu;', N'03BC', N'&#03BC;', 956, N'Greek small letter mu')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ν', N'&nu;', N'03BD', N'&#03BD;', 957, N'Greek small letter nu')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ξ', N'&xi;', N'03BE', N'&#03BE;', 958, N'Greek small letter xi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ο', N'&omicron;', N'03BF', N'&#03BF;', 959, N'Greek small letter omicron')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'π', N'&pi;', N'03C0', N'&#03C0;', 960, N'Greek small letter pi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ρ', N'&rho;', N'03C1', N'&#03C1;', 961, N'Greek small letter rho')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ς', N'&sigmaf;', N'03C2', N'&#03C2;', 962, N'Greek small letter final sigma')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'σ', N'&sigma;', N'03C3', N'&#03C3;', 963, N'Greek small letter sigma')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'τ', N'&tau;', N'03C4', N'&#03C4;', 964, N'Greek small letter tau')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'υ', N'&upsilon;', N'03C5', N'&#03C5;', 965, N'Greek small letter upsilon')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'φ', N'&phi;', N'03C6', N'&#03C6;', 966, N'Greek small letter phi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'χ', N'&chi;', N'03C7', N'&#03C7;', 967, N'Greek small letter chi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ψ', N'&psi;', N'03C8', N'&#03C8;', 968, N'Greek small letter psi')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ω', N'&omega;', N'03C9', N'&#03C9;', 969, N'Greek small letter omega')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ϑ', N'&thetasym;', N'03D1', N'&#03D1;', 977, N'Greek theta symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ϒ', N'&upsih;', N'03D2', N'&#03D2;', 978, N'Greek Upsilon with hook symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ϖ', N'&piv;', N'03D6', N'&#03D6;', 982, N'Greek pi symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'–', N'&ndash;', N'2013', N'&#2013;', 8211, N'en dash')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'—', N'&mdash;', N'2014', N'&#2014;', 8212, N'em dash')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‘', N'&lsquo;', N'2018', N'&#2018;', 8216, N'left singleÂ quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'’', N'&rsquo;', N'2019', N'&#2019;', 8217, N'right singleÂ quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‚', N'&sbquo;', N'201A', N'&#201A;', 8218, N'single low-9Â quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'“', N'&ldquo;', N'201C', N'&#201C;', 8220, N'left doubleÂ quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'”', N'&rdquo;', N'201D', N'&#201D;', 8221, N'right doubleÂ quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'„', N'&bdquo;', N'201E', N'&#201E;', 8222, N'double low-9Â quotation mark')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'†', N'&dagger;', N'2020', N'&#2020;', 8224, N'dagger, obelisk')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‡', N'&Dagger;', N'2021', N'&#2021;', 8225, N'double dagger, double obelisk')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'•', N'&bull;', N'2022', N'&#2022;', 8226, N'bulletÂ (black small circle)[f]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'…', N'&hellip;', N'2026', N'&#2026;', 8230, N'horizontalÂ ellipsisÂ (three dot leader)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‰', N'&permil;', N'2030', N'&#2030;', 8240, N'per milleÂ sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'′', N'&prime;', N'2032', N'&#2032;', 8242, N'primeÂ (minutes, feet)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'″', N'&Prime;', N'2033', N'&#2033;', 8243, N'double primeÂ (seconds, inches)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‹', N'&lsaquo;', N'2039', N'&#2039;', 8249, N'single left-pointing angle quotation mark[g]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'›', N'&rsaquo;', N'203A', N'&#203A;', 8250, N'single right-pointing angle quotation mark[g]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'‾', N'&oline;', N'203E', N'&#203E;', 8254, N'overlineÂ (spacing overscore)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⁄', N'&frasl;', N'2044', N'&#2044;', 8260, N'fraction slashÂ (solidus)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'€', N'&euro;', N'20AC', N'&#20AC;', 8364, N'euro sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ℑ', N'&image;', N'2111', N'&#2111;', 8465, N'black-letter capital IÂ (imaginary part)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'℘', N'&weierp;', N'2118', N'&#2118;', 8472, N'script capital PÂ (power set,Â Weierstrass p)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ℜ', N'&real;', N'211C', N'&#211C;', 8476, N'black-letter capital RÂ (real part symbol)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'™', N'&trade;', N'2122', N'&#2122;', 8482, N'trademark symbol')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'ℵ', N'&alefsym;', N'2135', N'&#2135;', 8501, N'alef symbolÂ (first transfinite cardinal)[h]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'←', N'&larr;', N'2190', N'&#2190;', 8592, N'leftwards arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'↑', N'&uarr;', N'2191', N'&#2191;', 8593, N'upwards arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'→', N'&rarr;', N'2192', N'&#2192;', 8594, N'rightwards arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'↓', N'&darr;', N'2193', N'&#2193;', 8595, N'downwards arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'↔', N'&harr;', N'2194', N'&#2194;', 8596, N'left right arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'↵', N'&crarr;', N'21B5', N'&#21B5;', 8629, N'downwards arrow with corner leftwardsÂ (carriage return)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⇐', N'&lArr;', N'21D0', N'&#21D0;', 8656, N'leftwards double arrow[i]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⇑', N'&uArr;', N'21D1', N'&#21D1;', 8657, N'upwards double arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⇒', N'&rArr;', N'21D2', N'&#21D2;', 8658, N'rightwards double arrow[j]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⇓', N'&dArr;', N'21D3', N'&#21D3;', 8659, N'downwards double arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⇔', N'&hArr;', N'21D4', N'&#21D4;', 8660, N'left right double arrow')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∀', N'&forall;', N'2200', N'&#2200;', 8704, N'for all')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∂', N'&part;', N'2202', N'&#2202;', 8706, N'partial differential')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∃', N'&exist;', N'2203', N'&#2203;', 8707, N'there exists')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∅', N'&empty;', N'2205', N'&#2205;', 8709, N'empty setÂ (null set); see alsoÂ U+8960, ?')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∇', N'&nabla;', N'2207', N'&#2207;', 8711, N'delÂ orÂ nablaÂ (vector differential operator)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∈', N'&isin;', N'2208', N'&#2208;', 8712, N'element of')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∉', N'&notin;', N'2209', N'&#2209;', 8713, N'not an element of')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∋', N'&ni;', N'220B', N'&#220B;', 8715, N'contains as member')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∏', N'&prod;', N'220F', N'&#220F;', 8719, N'n-ary productÂ (product sign)[k]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∑', N'&sum;', N'2211', N'&#2211;', 8721, N'n-ary summation[l]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'−', N'&minus;', N'2212', N'&#2212;', 8722, N'minus sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∗', N'&lowast;', N'2217', N'&#2217;', 8727, N'asterisk operator')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'√', N'&radic;', N'221A', N'&#221A;', 8730, N'square rootÂ (radical sign)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∝', N'&prop;', N'221D', N'&#221D;', 8733, N'proportional to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∞', N'&infin;', N'221E', N'&#221E;', 8734, N'infinity')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∠', N'&ang;', N'2220', N'&#2220;', 8736, N'angle')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∧', N'&and;', N'2227', N'&#2227;', 8743, N'logical andÂ (wedge)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∨', N'&or;', N'2228', N'&#2228;', 8744, N'logical orÂ (vee)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∩', N'&cap;', N'2229', N'&#2229;', 8745, N'intersectionÂ (cap)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∪', N'&cup;', N'222A', N'&#222A;', 8746, N'unionÂ (cup)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∫', N'&int;', N'222B', N'&#222B;', 8747, N'integral')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∴', N'&there4;', N'2234', N'&#2234;', 8756, N'therefore sign')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'∼', N'&sim;', N'223C', N'&#223C;', 8764, N'tilde operatorÂ (varies with, similar to)[m]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≅', N'&cong;', N'2245', N'&#2245;', 8773, N'congruent to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≈', N'&asymp;', N'2248', N'&#2248;', 8776, N'almost equal toÂ (asymptotic to)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≠', N'&ne;', N'2260', N'&#2260;', 8800, N'not equal to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≡', N'&equiv;', N'2261', N'&#2261;', 8801, N'identical to; sometimes used for equivalent to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≤', N'&le;', N'2264', N'&#2264;', 8804, N'less-than or equal to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'≥', N'&ge;', N'2265', N'&#2265;', 8805, N'greater-than or equal to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊂', N'&sub;', N'2282', N'&#2282;', 8834, N'subset of')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊃', N'&sup;', N'2283', N'&#2283;', 8835, N'superset of[n]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊄', N'&nsub;', N'2284', N'&#2284;', 8836, N'not a subset of')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊆', N'&sube;', N'2286', N'&#2286;', 8838, N'subset of or equal to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊇', N'&supe;', N'2287', N'&#2287;', 8839, N'superset of or equal to')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊕', N'&oplus;', N'2295', N'&#2295;', 8853, N'circled plusÂ (direct sum)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊗', N'&otimes;', N'2297', N'&#2297;', 8855, N'circled timesÂ (vector product)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⊥', N'&perp;', N'22A5', N'&#22A5;', 8869, N'up tackÂ (orthogonal to,Â perpendicular)[o]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⋅', N'&sdot;', N'22C5', N'&#22C5;', 8901, N'dot operator[p]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⋮', N'&vellip;', N'22EE', N'&#22EE;', 8942, N'verticalÂ ellipsis')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⌈', N'&lceil;', N'2308', N'&#2308;', 8968, N'left ceilingÂ (APL upstile)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⌉', N'&rceil;', N'2309', N'&#2309;', 8969, N'right ceiling')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⌊', N'&lfloor;', N'230A', N'&#230A;', 8970, N'left floorÂ (APL downstile)')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'⌋', N'&rfloor;', N'230B', N'&#230B;', 8971, N'right floor')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'〈', N'&lang;', N'2329', N'&#2329;', 9001, N'left-pointing angle bracketÂ (bra)[q]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'〉', N'&rang;', N'232A', N'&#232A;', 9002, N'right-pointing angle bracketÂ (ket)[r]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'◊', N'&loz;', N'25CA', N'&#25CA;', 9674, N'lozenge')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'♠', N'&spades;', N'2660', N'&#2660;', 9824, N'black spade suit[f]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'♣', N'&clubs;', N'2663', N'&#2663;', 9827, N'black club suitÂ (shamrock)[f]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'♥', N'&hearts;', N'2665', N'&#2665;', 9829, N'black heart suitÂ (valentine)[f]')
	insert into exp_htmlEntities (charValue, htmlEntity, CodePointHex, UnicodeHex, UnicodeDec, descr) values (N'♦', N'&diams;', N'2666', N'&#2666;', 9830, N'black diamond suit[f]')

end

declare @binary_name varchar(1000)
declare @command_response table (line varchar(max))

begin
	set @binary_name = 'wkhtmltopdf'
	insert into @command_response exec xp_cmdshell @binary_name
	if exists (select line from @command_response where line like '%is not recognized as an internal or external command%')
	begin
		print 'Error: "' + @binary_name + '" binary not found, please download into PATH before running this procedure.'
		return 0;
	end
	delete from @command_response
end

begin
	set @binary_name = 'pdftk'
	insert into @command_response exec xp_cmdshell @binary_name
	if exists (select line from @command_response where line like '%is not recognized as an internal or external command%')
	begin
		print 'Error: "' + @binary_name + '" binary not found, please download into PATH before running this procedure.'
		return 0;
	end
	delete from @command_response
end

begin
	set @binary_name = 'csv2xlsx'
	insert into @command_response exec xp_cmdshell @binary_name
	if exists (select line from @command_response where line like '%is not recognized as an internal or external command%')
	begin
		print 'Error: "' + @binary_name + '" binary not found, please download into PATH before running this procedure.'
		return 0;
	end
	delete from @command_response
end

return 1;

GO
