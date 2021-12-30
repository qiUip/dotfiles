-- My configuration file for Xmonad.
-- This version uses the Dracula theme https://draculatheme.com/.

------------------------------------
------------- Modules --------------
------------------------------------
-- Base
import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies, copyToAll, copy)
import qualified XMonad.Actions.CycleWS as WS
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.SpawnOn

-- Data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Window
import Control.Arrow (first)

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.DynamicScratchpads
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

------------------------------------
------- Basic configuration --------
------------------------------------
myFont :: String
myFont = "xft:Hack Nerd Font:bold:pixelsize=13"

myModMask :: KeyMask
myModMask = mod4Mask       -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"   -- Sets default terminal

myBorderWidth :: Dimension
myBorderWidth = 3          -- Sets border width for windows

myNormColor :: String
myNormColor   = "#44475a"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#6272a4"  -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask         -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------
---------- Startup items -----------
------------------------------------
myStartupHook :: X ()
myStartupHook = do
          spawnOnce "nitrogen --set-zoom-fill $HOME/Pictures/solar2.jpg"
          spawnOnce "picom -b"
          spawnOnce "xmodmap $HOME/.Xmodmap"
          spawnOnce "/usr/sbin/emacs --daemon &"
          setWMName "LG3D"

------------------------------------
------ Prompts configuration -------
------------------------------------
-- Prompt parameters (fonts, colours, soze, location, features etc.)
myXPConfig :: XPConfig
myXPConfig = def
     { font                = "xft:Hack Nerd Font:size=9"
     , bgColor             = "#282a36"
     , fgColor             = "#f8f8f2"
     , bgHLight            = "#c792ea"
     , fgHLight            = "#000000"
     , borderColor         = "#535974"
     , promptBorderWidth   = 0
     , promptKeymap        = myXPKeymap
     , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
     , height              = 20
     , historySize         = 256
     , historyFilter       = id
     , defaultText         = []
     , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
     , showCompletionOnTab = True
     , searchPredicate     = isPrefixOf
     , alwaysHighlight     = True
     , maxComplRows        = Nothing      -- set to Just 5 for 5 rows
     }

-- The same config minus the autocomplete feature for prompts where it is not desirable.
myXPConfig' :: XPConfig
myXPConfig' = myXPConfig
     { autoComplete = Nothing
     }

-- A list of all of the standard Xmonad prompts
promptList :: [(String, XPConfig -> X ())]
promptList = [ ("m", manPrompt)          -- manpages prompt
             , ("p", passPrompt)         -- get passwords (requires 'pass')
             , ("g", passGeneratePrompt) -- generate passwords (requires 'pass')
             , ("r", runOrRaisePrompt)   -- runs or focus on a (gui) program
             , ("s", sshPrompt)          -- ssh prompt
             , ("x", xmonadPrompt)       -- xmonad prompt
             ]

-- Calculator -- Example of a custom prompt from xmonad documentaion
promptList' :: [(String, XPConfig -> String -> X (), String)]
promptList' = [ ("c", calcPrompt, "qalc")  -- requires qalculate-gtk
              ]
calcPrompt c ans =
    inputPrompt c (trim ans) ?+ \input ->
        liftIO(runProcessWithInput "qalc" [input] "") >>= calcPrompt c
    where
        trim  = f . f
            where f = reverse . dropWhile isSpace

-- Add additional search engines.
archwiki, ebay, news, reddit, amazon, scholar :: S.SearchEngine
archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
ebay     = S.searchEngine "ebay" "https://www.ebay.com/sch/i.html?_nkw="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="
amazon   = S.searchEngine "amazon" "https://www.amazon.co.uk/s?k="
scholar  = S.searchEngine "scholar" "https://scholar.google.co.uk/scholar?hl=en&as_sdt=0%2C5&q="

-- List all the search engines and give them a key
searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("c", scholar)
             , ("d", S.duckduckgo)
             , ("e", ebay)
             , ("g", S.google)
             , ("h", S.hoogle)
             , ("n", news)
             , ("r", reddit)
             , ("s", S.stackage)
             , ("v", S.vocabulary)
             , ("w", S.wikipedia)
             , ("y", S.youtube)
             , ("z", amazon)
             ]

-- Keymaps for prompt (only)
myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     map (first $ (,) controlMask)         -- control + <key>
     [ (xK_a, startOfLine)                 -- move to the beginning of the line
     , (xK_e, endOfLine)                   -- move to the end of the line
     , (xK_w, moveCursor Prev)             -- move cursor forward
     , (xK_b, moveCursor Next)             -- move cursor backward
     , (xK_BackSpace, killWord Prev)       -- kill the previous word
     , (xK_c, pasteString)                 -- paste a string
     , (xK_q, quit)                        -- quit out of prompt
     ]
     ++
     map (first $ (,) altMask)             -- meta key + <key>
     [ (xK_BackSpace, killWord Prev)       -- kill the previous word
     , (xK_Up, moveHistory W.focusUp')     -- move up thru history
     , (xK_Down, moveHistory W.focusDown') -- move down thru history
     ]
     ++
     map (first $ (,) 0) -- <key>
     [ (xK_Return, setSuccess True >> setDone True)
     , (xK_KP_Enter, setSuccess True >> setDone True)
     , (xK_BackSpace, deleteString Prev)
     , (xK_Delete, deleteString Next)
     , (xK_Left, moveCursor Prev)
     , (xK_Right, moveCursor Next)
     , (xK_Home, startOfLine)
     , (xK_End, endOfLine)
     , (xK_Down, moveHistory W.focusUp')
     , (xK_Up, moveHistory W.focusDown')
     , (xK_Escape, quit)
     ]

------------------------------------
------------ Scratchpads -----------
------------------------------------
-- Note that alacritty requires the title to be defined manually with -t
myScratchPads = [
                  NS "term"  spawnTerm  findTerm  manageScratch
                , NS "file"  spawnFile  findFile  manageScratch
                , NS "music" spawnMusc  findMusc  manageScratch
                , NS "mail"  spawnEmail findEmail manageScratch
                , NS "bt"    spawnBT    findBT    manageScratch
                , NS "audio" spawnAudi  findAudi  manageScratch
                , NS "hmon"  spawnMon   findMon   manageScratch
                , NS "wapp"  spawnWapp  findWapp  manageScratch
                , NS "term2" spawnTerm2 findTerm2 manageScratch
                ]
                where
                  -- -- term: Terminal (alacritty)
                  spawnTerm  = "alacritty" ++ " -t scratchpad"
                  findTerm   = title =? "scratchpad"
                  -- term alt: Terminal (st)
                  spawnTerm2 = "st" ++ " -n term"
                  findTerm2 = resource =? "term"
                  -- file: File Manager (ranger)
                  spawnFile  = "alacritty -t scrafile -e ranger"
                  findFile   = title =? "scrafile"
                  -- music: Music player (ncmpcpp)
                  spawnMusc  = "alacritty -t scramusic -e ncmpcpp"
                  findMusc   = title =? "scramusic"
                  -- mail: Email client (neomutt)
                  spawnEmail  = "alacritty -t scramail -e neomutt"
                  findEmail   = title =? "scramail"
                  -- bt: Bluetooth manager (blueman)
                  spawnBT  = "blueman-manager"
                  findBT   = className =? "Blueman-manager"
                  -- audio: Audio mixer (pulseaudio)
                  spawnAudi  = "pavucontrol"
                  findAudi   = className =? "Pavucontrol"
                  -- hmon: Hardware monitor (htop)
                  spawnMon  = "alacritty -t scrahtop -e htop"
                  findMon   = title =? "scrahtop"
                  -- wapp: WhatsApp client (whatscli)
                  spawnWapp  = "alacritty -t scrawapp -e whatscli"
                  findWapp   = title =? "scrawapp"
                  manageScratch = customFloating $ center 0.3 0.5
                    where center w h = W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h

------------------------------------
----- Workspace configuration ------
------------------------------------
-- Make workspaces in xmobar clickable
myWorkspaces :: [String]
myWorkspaces = clickable . map xmobarEscape
               $ ["main", "dev1", "dev2", "dev3", "files", "chat", "write", "edit", "watch"]
  where
        clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

-- Application default workspaces
myManageHook = composeAll
               [ namedScratchpadManageHook myScratchPads
               , className =? "vlc"       --> doShift ( myWorkspaces !! 8) -- 'watch'
               , className =? "Gimp"      --> doShift ( myWorkspaces !! 7) -- 'edit'
               , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
               -- , className =? "discord"   --> doShift ( myWorkspaces !! 5) -- 'chat'
               -- , className =? "Microsoft Teams - Preview" --> doShift ( myWorkspaces !! 5) -- 'chat'
               -- , title ~? "Emacs Everywhere" --> doCenterFloat
               -- , className =? "ParaView"  --> doShift ( myWorkspaces !! 2) -- 'dev2'
               ]


------------------------------------
------- Layout configuration -------
------------------------------------
-- The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- A variation of the above except no borders are applied if fewer than two windows,
-- so that a single window has no gaps
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining layouts.
threeCol = renamed [Replace "threeCol"]
           $ limitWindows 12
           $ mySpacing' 6
           $ ResizableThreeColMid 1 (4/100) (5/12) []
grid     = renamed [Replace "grid"]
           $ limitWindows 12
           $ mySpacing' 6
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
floats   = renamed [Replace "floats"]
           $ limitWindows 20 simplestFloat
threeColDev = renamed [Replace "threeColDev"]
           $ limitWindows 20
           $ mySpacing' 6
           $ ResizableThreeColMid 2 (1/100) (5/8) [(19/10)]
tall     = renamed [Replace "tall"]
           $ limitWindows 12
           $ mySpacing' 6
           $ ResizableTall 1 (3/100) (1/2) []

-- onWorkspace spcifies the workspaces for selected layouts while all other workspaces use
-- myDefaultLHook
myLayoutHook =  onWorkspaces [(myWorkspaces !! 1),(myWorkspaces !! 2)]
                myDevLHook myDefaultLHook
             where
               -- The layout hooks
               myDefaultLHook = avoidStruts $ T.toggleLayouts floats $
                 mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
               myDevLHook = avoidStruts $
                 mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDevLayout
               -- The layouts
               myDefaultLayout = threeCol ||| tall ||| floats
               myDevLayout = threeColDev ||| threeCol ||| tall

------------------------------------
---- Keybindings configuration -----
------------------------------------
myKeys :: [(String, X ())]
myKeys =
     [ -- Xmonad
       ("M-C-r", spawn "xmonad --recompile && xmonad --restart") -- Recompiles xmonad
     , ("M-S-r", spawn "xmonad --restart")                       -- Restarts xmonad
     , ("M-C-S-q", io exitSuccess)                               -- Quits xmonad

       -- Open 'my' preferred terminal
     , ("M-<Return>", spawn (myTerminal))
     , ("M-t", spawn "st")

       -- Run applications from a prompt
     , ("<XF86Explorer> r t", prompt ("alacritty" ++ " -e") myXPConfig) -- Run a terminal application
     , ("<XF86Explorer> r g", runOrRaisePrompt            myXPConfig)   -- Run or go to a gui application

       -- Dmenu
     , ("M-d", spawn "$HOME/.scripts/dmenu_recency.sh")              -- Demenu recency (adapted from Manjaro i3)
     , ("<XF86Explorer> d", spawn "$HOME/.scripts/dmenu_recency.sh") -- Demenu recency (adapted from Manjaro i3)
     , ("<XF86Explorer> c", spawn "$HOME/.scripts/dmenu_scripts.sh") -- Dmenu launch scripts
     , ("<XF86Explorer> q", spawn "$HOME/.scripts/dmenu_power.sh")   -- Dmenu power menu
     , ("M-S-d c", spawn "$HOME/.scripts/dmenu_scripts.sh")          -- Dmenu launch scripts
     , ("M-S-d q", spawn "$HOME/.scripts/dmenu_power.sh")            -- Dmenu power menu

       -- Windows
     , ("M-q", kill1)      -- Kill the currently focused client
     , ("M-S-q", killAll)  -- Kill all windows in current layout

       -- Floating windows
     , ("M-f", sendMessage (T.Toggle "floats"))       -- Toggles my 'floats' layout
     , ("M-<Delete>", withFocused $ windows . W.sink) -- Push floating window back to tile
     , ("M-S-<Delete>", sinkAll)                      -- Push ALL floating windows to tile

       -- Windows navigation
     , ("M-m", windows W.focusMaster)     -- Move focus to the master window
     , ("M-c", windows copyToAll)         -- Copies focused window to all workspaces
     , ("M-j", windows W.focusDown)       -- Move focus to the next window
     , ("M-k", windows W.focusUp)         -- Move focus to the prev window
     , ("M-S-m", windows W.swapMaster)    -- Swap the focused window and the master window
     , ("M-S-j", windows W.swapDown)      -- Swap focused window with next window
     , ("M-S-k", windows W.swapUp)        -- Swap focused window with prev window
     , ("M-<Backspace>", promote)         -- Moves focused window to master, others maintain order
     , ("C-S-<Tab>", rotSlavesDown)       -- Rotate all windows except master and keep focus in place
     , ("M1-S-<Tab>", rotAllDown)         -- Rotate all the windows in the current stack
     , ("M-C-c", killAllOtherCopies)      -- Delete all copies of window
     , ("M-<End>", WS.nextWS)             -- Move to the next workspace
     , ("M-<Home>", WS.prevWS)            -- Move to the previous workspace
     , ("<XF86Explorer> w b", windowPrompt myXPConfig Bring allWindows) -- bring windows to this workspace
     , ("<XF86Explorer> w g", windowPrompt myXPConfig Goto allWindows)  -- go to a window in its current workspace

       -- Layouts
     , ("M-<Tab>", sendMessage NextLayout)               -- Switch to next layout
     , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
     , ("M-S-<Space>", sendMessage ToggleStruts)         -- Toggles struts (only when not using a status bar)
     , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)      -- Toggles noborder
     , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in master pane
     , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in master pane
     , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase total number of windows
     , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease total number of windows

       -- Resize windows
     , ("M-h", sendMessage Shrink)                       -- Shrink horizontal window width
     , ("M-l", sendMessage Expand)                       -- Expand horizontal window width
     , ("M-S-h", sendMessage MirrorShrink)               -- Shrink vertical window width (only works with resizable layouts)
     , ("M-S-l", sendMessage MirrorExpand)               -- Expand vertcal window width (only works with resizable layouts)

       -- Applications (teminal apps use a manual title with -t for better use with window grab and goto)
     , ("M-e", spawn "emacsclient -c -a ''")                    -- Editor (emacs)
     , ("M-r", spawn "alacritty -t ranger -e ranger")         -- File manager
     , ("M-w", spawn "alacritty -t whatscli -e whatscli")     -- Whatsapp cli
     , ("M-b", spawn "firefox")                               -- Browser
     , ("M-S-b", spawn "brave")                               -- Browser
     , ("M-C-a", spawn "pavucontrol")                         -- Audio control
     , ("M-C-e", spawn "alacritty -t neomutt -e neomutt")     -- Email
     , ("M-C-v", spawn "TERM=rxvt-256color alacritty -e vis") -- Audio visualiser
     , ("M-C-m", spawn "alacritty -e ncmpcpp")                -- Music player
     , ("M-C-d", spawnAndDo (doShift (myWorkspaces !! 5)) "discord") -- Because sometimes you wanna talk about keyboards and emacs
     , ("M-C-t", spawnAndDo (doShift (myWorkspaces !! 5)) "teams")   -- MS teams (thanks work!!!)
     , ("M-C-p", spawnAndDo (doShift (myWorkspaces !! 3)) "paraview")
     , ("M-C-S-t", spawnAndDo doCenterFloat "alacritty")
     , ("M-S-C-r", spawnAndDo doCenterFloat "alacritty -t ranger -e ranger") -- File manager
     , ("M-C-S-b", spawnAndDo (doShift (myWorkspaces !! 8)) "chromium")
     , ("M-C-S-e", spawnAndDo doCenterFloat "emacs")

       -- Multimedia Keys
     , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -1%")   -- Volume -1%
     , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1%")   -- Volume +1%
     , ("S-<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%") -- Volume -5%
     , ("S-<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%") -- Volume +5%

       -- Print screen. Requires scrot.
     , ("<Print>", spawn "scrot '%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f ~/Pictures/' ")

     , ("M-S-e", spawn "emacsclient -e \"(emacs-everywhere)\"")

       -- Scratchpads (Super+s Key) -- These are defined in the scratchpad section
     , ("M-s t", namedScratchpadAction myScratchPads "term")
     , ("M-s S-t", namedScratchpadAction myScratchPads "term2")
     , ("M-s r", namedScratchpadAction myScratchPads "file")
     , ("M-s m", namedScratchpadAction myScratchPads "music")
     , ("M-s e", namedScratchpadAction myScratchPads "mail")
     , ("M-s b", namedScratchpadAction myScratchPads "bt")
     , ("M-s p", namedScratchpadAction myScratchPads "audio")
     , ("M-s h", namedScratchpadAction myScratchPads "hmon")
     , ("M-s w", namedScratchpadAction myScratchPads "wapp")

       -- Dynamic Scratchpads *external module* (Super+s S makes a window into a scartchpad; Super+s s hides/shows the scratchpad)
     , ("M-s S-1", withFocused $ makeDynamicSP "scr1")
     , ("M-s 1", spawnDynamicSP "scr1")
     , ("M-s S-2", withFocused $ makeDynamicSP "scr2")
     , ("M-s 2", spawnDynamicSP "scr2")
     , ("M-s S-3", withFocused $ makeDynamicSP "scr3")
     , ("M-s 3", spawnDynamicSP "scr3")
     , ("M-s S-4", withFocused $ makeDynamicSP "scr4")
     , ("M-s 4", spawnDynamicSP "scr4")
     ]

  -- Appending search engine lists to keybindings list -- the search engines and their keys are in the prompts section
  ++ [("<XF86Explorer> s " ++ k, S.promptSearch myXPConfig' f) | (k,f) <- searchList ] -- Search from a prompt
  ++ [("M-S-s "            ++ k, S.selectSearch f) | (k,f) <- searchList ]             -- Search from the browser

  -- Appending prompt list to keybindings list -- the prompts and their keys for are in the prompts section
  ++ [("<XF86Explorer> p " ++ k, f myXPConfig') | (k,f) <- promptList ]
  ++ [("<XF86Explorer> p " ++ k, f myXPConfig' g) | (k,f,g) <- promptList' ]


------------------------------------
---- Main configuration & Xmobar ---
------------------------------------
main :: IO ()
main = do
    -- Launch xmobar
    xmproc <- spawnPipe "xmobar $HOME/.config/xmonad/xmobar"
    -- Launch ewmh desktop
    xmonad $ docks . ewmh $ def
        { manageHook         = manageSpawn <+> myManageHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook            = dynamicLogWithPP xmobarPP
                               { ppOutput          = hPutStrLn xmproc
                               , ppCurrent         = xmobarColor "#bd93f9" "" . wrap "[" "]"  -- Current workspace in xmobar
                               , ppVisible         = xmobarColor "#bd93f9" ""                 -- Visible but not current workspace
                               , ppHidden          = xmobarColor "#ffb86c" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                               , ppHiddenNoWindows = xmobarColor "#8be9fd" ""                 -- Hidden workspaces (no windows)
                               , ppTitle           = xmobarColor "#e6e6e6" "" . shorten 80    -- Title of active window in xmobar
                               , ppSep             =  "<fc=#bfbfbf> | </fc>"                  -- Separators in xmobar
                               , ppUrgent          = xmobarColor "#bfbfbf" "" . wrap "!" "!"  -- Urgent workspace
                               , ppExtras          = [windowCount]                            -- # of windows current workspace
                               , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                               }
        } `additionalKeysP` myKeys
