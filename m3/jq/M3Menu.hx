package m3.jq;

import m3.jq.JQ;
import m3.widget.Widgets;
import m3.exception.Exception;

using m3.helper.StringHelper;
using m3.jq.JQMenu;

typedef MenuOption = {
	var label: String;
	@:optional var icon: String;
	@:optional var iconJq: JQ;
	var action: JQEvent->M3Menu->Void;
}

typedef M3MenuOptions = {
	var menuOptions: Array<MenuOption>;	
	@:optional var width: Int;
	@:optional var close: Void->Void;
	@:optional var classes: String;
	@:optional var wrapLabelInAtag: Bool;
}

typedef M3MenuWidgetDef = {
	var options: M3MenuOptions;
	var _create: Void->Void;
	var destroy: Void->Void;
	// var _closeOnDocumentClick: JQEvent->Bool;

	@:optional var _super: Dynamic;
}

@:native("$")
extern class M3Menu extends JQMenu {
	
	@:overload(function<T>(cmd : String):T{})
	@:overload(function<T>(cmd:String, opt:String, ?newVal: Dynamic):T{})
	function m3menu(opts: M3MenuOptions): M3Menu;

	static var cur(get, null): M3Menu;
	private static inline function get_cur() : M3Menu {
		return untyped __js__("$(this)");
	}

	private static function __init__(): Void {
		var defineWidget: Void->M3MenuWidgetDef = function(): M3MenuWidgetDef {
			return {
		        options: {
		        	menuOptions: null
			        , width: 200
			        , classes: ""
		        },

		        _create: function(): Void {
		        	var self: M3MenuWidgetDef = Widgets.getSelf();
					var selfElement: M3Menu = Widgets.getSelfElement();

					if(!selfElement.is("ul")) {
						throw new Exception("Root of M3Menu should be a ul");
					}

					selfElement.css("position", "absolute");

					selfElement.addClass("m3menu nonmodalPopup");
					if(self.options.classes.isNotBlank()) {
						selfElement.addClass(self.options.classes);
					}
					selfElement.width(self.options.width);

					for(menuOption in self.options.menuOptions) {
						var icon: String = {
							if(menuOption.icon.isNotBlank()) "<span class='ui-icon " + menuOption.icon + "'></span>"; 
							else "";
						};
						var label: String = {
							if(self.options.wrapLabelInAtag) "<a>" + menuOption.label + "</a>";
							else menuOption.label;
						}
						var li = new JQ("<li>" + icon + label + "</li>")
							.appendTo(selfElement)
							.click(function(evt: JQEvent): Void {
									if(self.options.wrapLabelInAtag) {evt.stopPropagation();}
									menuOption.action(evt, selfElement);
								});
						if(menuOption.iconJq != null) {
							li.prepend(menuOption.iconJq);
						}
					}

					selfElement.on("contextmenu", function(evt: JQEvent): Bool { return false; });

		        	self._super();
		        },

		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.m3menu", JQ.ui.menu, defineWidget());
	}
}