-- My xmonad configuration.
-- Forked from the xmonad configuration of Derek Taylor (DistroTube)
-- For more information on Xmonad, visit: https://xmonad.org

------------------------------------------------------------------------
-- IMPORTS
------------------------------------------------------------------------
    -- Base
import XMonad
-- import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
-- import Data.Maybe (isJust)
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
-- import XMonad.ManageHook

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableThreeColumns
-- import XMonad.Layout.LayoutBuilder
-- import XMonad.Layout.Tabbed


    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Renamed 
import XMonad.Layout.Spacing
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
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
import Control.Arrow (first)

    -- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
-- import XMonad.Util.Run (runProcessWithInput, safeSpawn, unsafeSpawn, spawnPipe)
import XMonad.Util.Run 
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------
myFont :: String
myFont = "xft:Hack Nerd Font:bold:pixelsize=13"

myModMask :: KeyMask
myModMask = mod4Mask       -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "st"          -- Sets default terminal

myBorderWidth :: Dimension
myBorderWidth = 3          -- Sets border width for windows

myNormColor :: String
myNormColor   = "#292d3e"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#c3a583"  -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask         -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- AUTOSTART
------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
          spawnOnce "nitrogen --set-zoom-fill /home/mashy/Pictures/apollo11.jpg"
          spawnOnce "picom -b"
          spawnOnce "/usr/local/bin/emacs --daemon &"
          setWMName "LG3D"

------------------------------------------------------------------------
-- XPROMPT SETTINGS
------------------------------------------------------------------------
myXPConfig :: XPConfig
myXPConfig = def
      { font                = "xft:Hack Nerd Font:size=9"
      , bgColor             = "#292d3e"
      , fgColor             = "#d0d0d0"
      , bgHLight            = "#c792ea"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , promptKeymap        = myXPKeymap
      -- , position            = Top
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

-- The same config minus the autocomplete feature which is annoying on
-- certain Xprompts, like the search engine prompts.
myXPConfig' :: XPConfig
myXPConfig' = myXPConfig
      { autoComplete = Nothing
      }

-- A list of all of the standard Xmonad prompts
promptList :: [(String, XPConfig -> X ())]
promptList = [ ("m", manPrompt)          -- manpages prompt
             , ("p", passPrompt)         -- get passwords (requires 'pass')
             , ("g", passGeneratePrompt) -- generate passwords (requires 'pass')
             , ("r", passRemovePrompt)   -- remove passwords (requires 'pass')
             , ("s", sshPrompt)          -- ssh prompt
             , ("x", xmonadPrompt)       -- xmonad prompt
             ]

------------------------------------------------------------------------
-- XPROMPT KEYMAP (emacs-like key bindings)
------------------------------------------------------------------------
myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     map (first $ (,) controlMask)   -- control + <key>
     [ (xK_z, killBefore)            -- kill line backwards
     , (xK_k, killAfter)             -- kill line fowards
     , (xK_a, startOfLine)           -- move to the beginning of the line
     , (xK_e, endOfLine)             -- move to the end of the line
     , (xK_m, deleteString Next)     -- delete a character foward
     , (xK_b, moveCursor Prev)       -- move cursor forward
     , (xK_f, moveCursor Next)       -- move cursor backward
     , (xK_BackSpace, killWord Prev) -- kill the previous word
     , (xK_y, pasteString)           -- paste a string
     , (xK_g, quit)                  -- quit out of prompt
     , (xK_bracketleft, quit)
     ]
     ++
     map (first $ (,) altMask)       -- meta key + <key>
     [ (xK_BackSpace, killWord Prev) -- kill the prev word
     , (xK_f, moveWord Next)         -- move a word forward
     , (xK_b, moveWord Prev)         -- move a word backward
     , (xK_d, killWord Next)         -- kill the next word
     , (xK_n, moveHistory W.focusUp')   -- move up thru history
     , (xK_p, moveHistory W.focusDown') -- move down thru history
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

------------------------------------------------------------------------
-- SEARCH ENGINES
------------------------------------------------------------------------
-- Xmonad has several search engines available to use located in
-- XMonad.Actions.Search. Additionally, you can add other search engines
-- such as those listed below.
archwiki, ebay, news, reddit :: S.SearchEngine

archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
ebay     = S.searchEngine "ebay" "https://www.ebay.com/sch/i.html?_nkw="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="

-- This is the list of search engines that I want to use. Some are from
-- XMonad.Actions.Search, and some are the ones that I added above.
searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
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
             , ("z", S.amazon)
             ]

------------------------------------------------------------------------
-- KEYBINDINGS
------------------------------------------------------------------------
-- Using Xmonad.Util.EZConfig module which allows keybindings
-- to be written in simpler, emacs-like format.
myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")      -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")        -- Restarts xmonad
        , ("M-C-S-q", io exitSuccess)                -- Quits xmonad

    -- Open my preferred terminal
        , ("M-<Return>", spawn (myTerminal))

    -- Run Prompt
        , ("M-S-<Return>", shellPrompt myXPConfig')   -- Shell Prompt

    -- Dmenu
        , ("M-d", spawn "/home/mashy/.scripts/dmenu_recency.sh")   -- Demenu recency (adapted from Manjaro i3)
        , ("M-c", spawn "/home/mashy/.scripts/dmenu_scripts.sh")   -- Dmenu launch scripts
        , ("M-p", spawn "/home/mashy/.scripts/dmenu_power.sh")     -- Dmenu power menu

    -- Ranger
        , ("M-r", spawn (myTerminal ++ " -e ranger")) -- File manager

    -- Windows
        , ("M-q", kill1)                           -- Kill the currently focused client
        -- , ("M-S-q", killAll)

        -- Floating windows
        , ("M-f", sendMessage (T.Toggle "floats"))       -- Toggles my 'floats' layout
        , ("M-<Delete>", withFocused $ windows . W.sink) -- Push floating window back to tile
        , ("M-S-<Delete>", sinkAll)                      -- Push ALL floating windows to tile

    -- Windows navigation
        , ("M-m", windows W.focusMaster)     -- Move focus to the master window
        , ("M-j", windows W.focusDown)       -- Move focus to the next window
        , ("M-k", windows W.focusUp)         -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster)    -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)      -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)        -- Swap focused window with prev window
        , ("M-<Backspace>", promote)         -- Moves focused window to master, others maintain order
        , ("M1-S-<Tab>", rotSlavesDown)      -- Rotate all windows except master and keep focus in place
        , ("M1-C-<Tab>", rotAllDown)         -- Rotate all the windows in the current stack
        , ("M-C-s", killAllOtherCopies)      -- 

        -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)                -- Switch to next layout
        , ("M-C-M1-<Up>", sendMessage Arrange)
        , ("M-C-M1-<Down>", sendMessage DeArrange)
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-<Space>", sendMessage ToggleStruts)         -- Toggles struts
        , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)      -- Toggles noborder
        , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in master pane
        , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in master pane
        , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase number of windows
        , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease number of windows

        , ("M-h", sendMessage Shrink)                       -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                       -- Expand horiz window width
        , ("M-S-h", sendMessage MirrorShrink)               -- Shrink vert window width (only works with resizeable layouts)
        , ("M-S-l", sendMessage MirrorExpand)               -- Expand vert window width (only works with resizeable layouts)

    -- Emacs
        , ("M-C-e", spawn "emacsclient -c -a ''")                           -- start emacs
        -- , ("C-e a", spawn "emacsclient -c -a '' --eval '(emms)'")           -- emms emacs audio player
        -- , ("C-e b", spawn "emacsclient -c -a '' --eval '(ibuffer)'")        -- list emacs buffers
        -- , ("C-e d", spawn "emacsclient -c -a '' --eval '(dired nil)'")      -- dired emacs file manager
        -- , ("C-e s", spawn "emacsclient -c -a '' --eval '(eshell)'")         -- eshell within emacs

    --- My Applications (Super+Alt+Key)
        , ("M-M1-a", spawn ("pavucontrol"))
        , ("M-M1-b", spawn "firefox duckduckgo.com")
        , ("M-M1-e", spawn ("termite" ++ " -e neomutt"))
        , ("M-M1-f", spawn (myTerminal ++ " -e sh ./.config/vifm/scripts/vifmrun"))
        , ("M-M1-v", spawn ("termite" ++ " -e vis"))
        , ("M-M1-m", spawn ("termite" ++ " -e ncmpcpp"))

    -- Multimedia Keys
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<Print>", spawn "scrot '%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f ~/Pictures/' ")
        ]
        -- Appending search engines to keybindings list
        ++ [("M-s " ++ k, S.promptSearch myXPConfig f) | (k,f) <- searchList ]
        ++ [("M-S-s " ++ k, S.selectSearch f) | (k,f) <- searchList ]
        ++ [("M-S-p " ++ k, f myXPConfig) | (k,f) <- promptList ]

------------------------------------------------------------------------
-- WORKSPACES
------------------------------------------------------------------------
-- My workspaces are clickable meaning that the mouse can be used to switch
-- workspaces. This requires xdotool.

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]
        
myWorkspaces :: [String]   
myWorkspaces = clickable . map xmobarEscape
               $ ["main", "dev1", "dev2", "dev3", "files", "chat", "write", "edit", "watch"]
  where                                                                      
        clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,                                        
                      let n = i ] 

------------------------------------------------------------------------
-- MANAGEHOOK
------------------------------------------------------------------------
-- Sets some rules for certain programs. Examples include forcing certain
-- programs to always float, or to always appear on a certain workspace.
-- Forcing programs to a certain workspace with a doShift requires xdotool
-- if you are using clickable workspaces. You need the className or title 
-- of the program. Use xprop to get this info.
-- note that using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ title =? "firefox"      --> doShift ( myWorkspaces !! 0)
     , className =? "vlc"      --> doShift ( myWorkspaces !! 8)
     , className =? "ParaView" --> doShift ( myWorkspaces !! 2)
     , className =? "Gimp"     --> doShift ( myWorkspaces !! 7)
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     ]

------------------------------------------------------------------------
-- LAYOUTS
------------------------------------------------------------------------
-- Makes setting the spacingRaw simpler to write. The spacingRaw
-- module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
tall     = renamed [Replace "tall"]
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
floats   = renamed [Replace "floats"]
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
threeCol = renamed [Replace "threeCol"]
           $ limitWindows 9
           $ mySpacing' 8
           $ ResizableThreeColMid 1 (3/100) (3/8) []
-- threeColR = renamed [Replace "threeColR"]
--            $ limitWindows 9
--            $ mySpacing' 8
--            $ ThreeColMid 1 (3/100) (3/8)


-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     threeCol
                                 ||| grid
                                 ||| tall
                                 -- ||| mulCol

-- myLayout = ( (layoutN 1 (relBox 0 0 0.5 1) (Just $ relBox 0 0 1 1) $ simpleTabbed)
--             $ (layoutAll (relBox 0.5 0 1 1)                         $ simpleTabbed)
--             ) |||
--             ( (layoutN 1       (relBox (1/3) 0 (1/2) 1) (Just $ relBox 0 0 1 1) $ Tall 0 0.01 0.5)
--             $ (layoutR 0.1 0.5 (relBox (2/3) 0 1     1) Nothing                 $ Tall 0 0.01 0.5)
--             $ (layoutAll       (relBox 0     0 (1/3) 1)                         $ Tall 0 0.01 0.5)
--             ) |||
--             ( (layoutN 1 (absBox (-512-200) 0 512        0) (Just $ relBox 0 0 1 1) $ simpleTabbed)
--             $ (layoutN 1 (absBox (-200)     0 0          0) Nothing                 $ simpleTabbed)
--             $ (layoutAll (absBox 0          0 (-512-200) 0)                         $ simpleTabbed)
--             ) |||
--             ( (layoutN 1 (absBox 10 0 0 (-10)) Nothing $ Tall 0 0.01 0.5)
--             $ (layoutN 1 (absBox 0 0 200 0) Nothing $ Tall 0 0.01 0.5)
--             $ (layoutAll (absBox 10 10 0 0) $ Tall 2 0.01 0.5)
--             ) ||| Full
-- myLayoutHook = myLayout
------------------------------------------------------------------------
-- MAIN
------------------------------------------------------------------------
main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc <- spawnPipe "xmobar /home/mashy/.config/xmobar/config"
  
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run 
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        , handleEventHook    = serverModeEventHookCmd 
                               <+> serverModeEventHook 
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook 
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc x 
                        , ppCurrent = xmobarColor "#ddbd94" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#ddbd94" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#c15c2e" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#5a8c93" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#d0d0d0" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
        } `additionalKeysP` myKeys 

