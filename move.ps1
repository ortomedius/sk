$cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class Clicker
{
//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646270(v=vs.85).aspx
[StructLayout(LayoutKind.Sequential)]
struct INPUT
{ 
    public int        type; // 0 = INPUT_MOUSE,
                            // 1 = INPUT_KEYBOARD
                            // 2 = INPUT_HARDWARE
    public MOUSEINPUT mi;
}

//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
[StructLayout(LayoutKind.Sequential)]
struct MOUSEINPUT
{
    public int    dx ;
    public int    dy ;
    public int    mouseData ;
    public int    dwFlags;
    public int    time;
    public IntPtr dwExtraInfo;
}

//This covers most use cases although complex mice may have additional buttons
//There are additional constants you can use for those cases, see the msdn page
const int MOUSEEVENTF_MOVED      = 0x0001 ;
const int MOUSEEVENTF_LEFTDOWN   = 0x0002 ;
const int MOUSEEVENTF_LEFTUP     = 0x0004 ;
const int MOUSEEVENTF_RIGHTDOWN  = 0x0008 ;
const int MOUSEEVENTF_RIGHTUP    = 0x0010 ;
const int MOUSEEVENTF_MIDDLEDOWN = 0x0020 ;
const int MOUSEEVENTF_MIDDLEUP   = 0x0040 ;
const int MOUSEEVENTF_WHEEL      = 0x0080 ;
const int MOUSEEVENTF_XDOWN      = 0x0100 ;
const int MOUSEEVENTF_XUP        = 0x0200 ;
const int MOUSEEVENTF_ABSOLUTE   = 0x8000 ;

const int screen_length = 0x10000 ;

//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646310(v=vs.85).aspx
[System.Runtime.InteropServices.DllImport("user32.dll")]
extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

public static void LeftClickAtPoint(int x, int y)
{
    // Move the mouse
    INPUT[] input = new INPUT[2];
    input[0].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    input[1].mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(2, input, Marshal.SizeOf(input[0]) * 2);
}



public static void RightClickAtPoint(int x, int y)
{
    //Move the mouse
    INPUT[] input = new INPUT[3];
    input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
    input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
    input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
    //Left mouse button down
    input[1].mi.dwFlags = MOUSEEVENTF_RIGHTDOWN;
    //Left mouse button up
    input[2].mi.dwFlags = MOUSEEVENTF_RIGHTUP;
    SendInput(3, input, Marshal.SizeOf(input[0]));
}

}
'@
Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing



$oldPos = [System.Windows.Forms.Cursor]::Position

while ($true) {
    # Sleep for a random duration between 1 and 2 seconds
    $sleepDuration = Get-Random -Minimum 1 -Maximum 3
    Start-Sleep -Seconds $sleepDuration

    # Get the current cursor position
    $currentPos = [System.Windows.Forms.Cursor]::Position

    # Define the maximum allowed offset from the old position in both positive and negative directions
    $maxOffset = 20

    # Generate random movement offsets for X and Y coordinates between -3 and 3 pixels
    $xOffset = Get-Random -Minimum -3 -Maximum 4
    $yOffset = Get-Random -Minimum -3 -Maximum 4

    # Calculate new cursor position with adjusted offsets
    $newX = $currentPos.X + $xOffset
    $newY = $currentPos.Y + $yOffset


    # Ensure the new cursor position does not exceed the maximum allowed offset from the old position
    if ($newX -lt ($oldPos.X - $maxOffset) -or $newX -gt ($oldPos.X + $maxOffset)) {
        $newX = $oldPos.X + [Math]::Sign($newX - $oldPos.X) * $maxOffset
    }
    if ($newY -lt ($oldPos.Y - $maxOffset) -or $newY -gt ($oldPos.Y + $maxOffset)) {
        $newY = $oldPos.Y + [Math]::Sign($newY - $oldPos.Y) * $maxOffset
    }
	


    # Bound the cursor position within the screen boundaries
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

    if ($newX -lt 0) { $newX = 0 }
    if ($newX -ge $screenWidth) { $newX = $screenWidth - 1 }
    if ($newY -lt 0) { $newY = 0 }
    if ($newY -ge $screenHeight) { $newY = $screenHeight - 1 }

    # Move the cursor to the new position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX, $newY)


    # Send a right-click at the new cursor position
    # [Clicker]::LeftClickAtPoint($newX, $newY)
}





