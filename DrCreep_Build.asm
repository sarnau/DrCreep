.label CREEPLOAD_START = $C000

#import "castle.asm"

// Generate the disk image
.disk [filename="bin/The Castles of Dr. Creep.d64", name="DUNGEONMASTER",id="AX22A" ]
{
	[name="CASTLE", type="prg", segments="CASTLE" ],
	[name="CREEPLOAD", type="prg", prgFiles="bin/creepload.prg" ],
	[name="OBJECT", type="prg", prgFiles="bin/object.prg" ],

	[name="ztutorial", type="prg", prgFiles="files/ztutorial.prg" ],
	[name="zsylvania", type="prg", prgFiles="files/zsylvania.prg" ],
	[name="zcallanwolde", type="prg", prgFiles="files/zcallanwolde.prg" ],
	[name="ztannenbaum", type="prg", prgFiles="files/ztannenbaum.prg" ],
	[name="zalternation", type="prg", prgFiles="files/zalternation.prg" ],
	[name="zfreedonia", type="prg", prgFiles="files/zfreedonia.prg" ],
	[name="zcarpathia", type="prg", prgFiles="files/zcarpathia.prg" ],
	[name="zparthenia", type="prg", prgFiles="files/zparthenia.prg" ],
	[name="zteasdale", type="prg", prgFiles="files/zteasdale.prg" ],
	[name="zrittenhouse", type="prg", prgFiles="files/zrittenhouse.prg" ],
	[name="zromania", type="prg", prgFiles="files/zromania.prg" ],
	[name="zdoublecross", type="prg", prgFiles="files/zdoublecross.prg" ],
	[name="zbaskerville", type="prg", prgFiles="files/zbaskerville.prg" ],
	[name="zlovecraft", type="prg", prgFiles="files/zlovecraft.prg" ],

	[name="ytutorial", type="prg", prgFiles="files/ytutorial.prg" ],
	[name="yfreedonia", type="prg", prgFiles="files/yfreedonia.prg" ],
	[name="ycallanwolde", type="prg", prgFiles="files/ycallanwolde.prg" ],

	[name="music0", type="prg", prgFiles="files/music0.prg" ],
	[name="music1", type="prg", prgFiles="files/music1.prg" ],
	[name="music2", type="prg", prgFiles="files/music2.prg" ],
	[name="music3", type="prg", prgFiles="files/music3.prg" ],
	[name="music4", type="prg", prgFiles="files/music4.prg" ],
	[name="music5", type="prg", prgFiles="files/music5.prg" ],
	[name="music6", type="prg", prgFiles="files/music6.prg" ],
	[name="music7", type="prg", prgFiles="files/music7.prg" ],
	[name="music8", type="prg", prgFiles="files/music8.prg" ],

	[name=@"\$81PIC A TITLE   ", type="prg", prgFiles="files/title.koa" ],
}
