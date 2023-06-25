.label CREEPLOAD_START = $C000

#import "castle.asm"

// Generate the disk image
.disk [filename="bin/The Castles of Dr. Creep.d64", name="DUNGEONMASTER",id="AX22A" ]
{
	[name="CASTLE", type="prg", segments="CASTLE" ],
	[name="CREEPLOAD", type="prg", prgFiles="bin/creepload.prg" ],
	[name="OBJECT", type="prg", prgFiles="bin/object.prg" ],

	[name="ZTUTORIAL", type="prg", prgFiles="files/ztutorial.prg" ],
	[name="ZSYLVANIA", type="prg", prgFiles="files/zsylvania.prg" ],
	[name="ZCALLANWOLDE", type="prg", prgFiles="files/zcallanwolde.prg" ],
	[name="ZTANNENBAUM", type="prg", prgFiles="files/ztannenbaum.prg" ],
	[name="ZALTERNATION", type="prg", prgFiles="files/zalternation.prg" ],
	[name="ZFREEDONIA", type="prg", prgFiles="files/zfreedonia.prg" ],
	[name="ZCARPATHIA", type="prg", prgFiles="files/zcarpathia.prg" ],
	[name="ZPARTHENIA", type="prg", prgFiles="files/zparthenia.prg" ],
	[name="ZTEASDALE", type="prg", prgFiles="files/zteasdale.prg" ],
	[name="ZRITTENHOUSE", type="prg", prgFiles="files/zrittenhouse.prg" ],
	[name="ZROMANIA", type="prg", prgFiles="files/zromania.prg" ],
	[name="ZDOUBLECROSS", type="prg", prgFiles="files/zdoublecross.prg" ],
	[name="ZBASKERVILLE", type="prg", prgFiles="files/zbaskerville.prg" ],
	[name="ZLOVECRAFT", type="prg", prgFiles="files/zlovecraft.prg" ],

	[name="YTUTORIAL", type="prg", prgFiles="files/ytutorial.prg" ],
	[name="YFREEDONIA", type="prg", prgFiles="files/yfreedonia.prg" ],
	[name="YCALLANWOLDE", type="prg", prgFiles="files/ycallanwolde.prg" ],

	[name="MUSIC0", type="prg", prgFiles="files/music0.prg" ],
	[name="MUSIC1", type="prg", prgFiles="files/music1.prg" ],
	[name="MUSIC2", type="prg", prgFiles="files/music2.prg" ],
	[name="MUSIC3", type="prg", prgFiles="files/music3.prg" ],
	[name="MUSIC4", type="prg", prgFiles="files/music4.prg" ],
	[name="MUSIC5", type="prg", prgFiles="files/music5.prg" ],
	[name="MUSIC6", type="prg", prgFiles="files/music6.prg" ],
	[name="MUSIC7", type="prg", prgFiles="files/music7.prg" ],
	[name="MUSIC8", type="prg", prgFiles="files/music8.prg" ],

	[name=@"\$81PIC A TITLE   ", type="prg", prgFiles="files/title.koa" ],
}
