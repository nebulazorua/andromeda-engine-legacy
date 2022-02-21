package ui;

import flixel.addons.ui.FlxInputText;
import openfl.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.errors.Error;

class Inputbox extends FlxInputText {
  public var loseFocusOnEnter:Bool=true;
  private override function filter(text:String):String
  {
    if (forceCase == FlxInputText.UPPER_CASE)
    {
      text = text.toUpperCase();
    }
    else if (forceCase == FlxInputText.LOWER_CASE)
    {
      text = text.toLowerCase();
    }

    if (filterMode != FlxInputText.NO_FILTER)
    {
      var pattern:EReg;
      switch (filterMode)
      {
        case FlxInputText.ONLY_ALPHA:
          pattern = ~/[^a-zA-Z]*/g;
        case FlxInputText.ONLY_NUMERIC:
          pattern = ~/[^0-9.+-]*/g;
        case FlxInputText.ONLY_ALPHANUMERIC:
          pattern = ~/[^a-zA-Z0-9]*/g;
        case FlxInputText.CUSTOM_FILTER:
          pattern = customFilterPattern;
        default:
          throw new Error("FlxInputText: Unknown filterMode (" + filterMode + ")");
      }
      text = pattern.replace(text, "");
    }
    return text;
  }

  private override function onKeyDown(e:KeyboardEvent):Void
	{
		var key:Int = e.keyCode;

		if (hasFocus)
		{
			// Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
			if (key == 16 || key == 17 || key == 220 || key == 27)
			{
				return;
			}
			// Left arrow
			else if (key == 37)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text; // forces scroll update
				}
			}
			// Right arrow
			else if (key == 39)
			{
				if (caretIndex < text.length)
				{
					caretIndex++;
					text = text; // forces scroll update
				}
			}
			// End key
			else if (key == 35)
			{
				caretIndex = text.length;
				text = text; // forces scroll update
			}
			// Home key
			else if (key == 36)
			{
				caretIndex = 0;
				text = text;
			}
			// Backspace
			else if (key == 8)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.BACKSPACE_ACTION);
				}
			}
			// Delete
			else if (key == 46)
			{
				if (text.length > 0 && caretIndex < text.length)
				{
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.DELETE_ACTION);
				}
			}
			// Enter
			else if (key == 13)
			{
				onChange(FlxInputText.ENTER_ACTION);
        if(loseFocusOnEnter){
          hasFocus = false;
          if (focusLost != null)
            focusLost();
        }
			}
			// Actually add some text
			else
			{
				if (e.charCode == 0) // non-printable characters crash String.fromCharCode
				{
					return;
				}
        var char = String.fromCharCode(e.charCode);
        if(e.shiftKey || Keyboard.capsLock)
          char = char.toUpperCase();

				var newText:String = filter(char);

				if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength))
				{
					text = insertSubstring(text, newText, caretIndex);
					caretIndex++;
					onChange(FlxInputText.INPUT_ACTION);
				}
			}
		}
	}

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
    if(visible==false)hasFocus=false;
  }

}
