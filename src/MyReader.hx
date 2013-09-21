package ;
import format.swf.Reader;
import format.swf.Data;
import format.swf.Constants;
import neko.Lib;
/**
 * ...
 * @author ADong
 */

class MyReader extends Reader
{

	private var needDelete = false;
	
	override public function readTag() : SWFTag {
		var h = i.readUInt16();
		var id = h >> 6;
		var len = h & 63;
		var ext = false;
		if( len == 63 ) {
			len = readInt();
			if( len < 63 ) ext = true;
		}

		var old_i = i;
		var old_bits = bits;
		i = new haxe.io.BytesInput(i.read(len));
		bits = new format.tools.BitsInput(i);
		needDelete = false;
		if (id == 0x52 //doabc
			|| id == 0x4c //symbol class
		) {
			needDelete = true;
		}
		var tag = switch( id ) {
			case TagId.End:
				null;
			case TagId.SymbolClass:
				TSymbolClass(readSymbols());

			default:
				var data = i.read(len);
				TUnknown(id,data);
		}

        i = old_i;
        bits = old_bits;

        return tag;
	}
	
	override public function readTagList() {
		var a = new Array();
		while( true ) {
			var t = readTag();
			
			if( t == null )
				break;
			if (!needDelete) {
				a.push(t);
			}
			
		}
		return a;
	}
	
}